// MonitoringScheduler — starts and restarts DeviceActivity monitoring.
// Daily mode: one repeating midnight-to-midnight activity with the six
// checkpoint events. Weekly mode: a second activity spanning the user's
// calendar week with thresholds on the weekly target (and the daily
// activity posts no alerts — F5). Restart only when a setting that
// affects monitoring changes, or to top up a missing activity (F4);
// failures are logged and recorded for Settings (F6).

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core
import os

@MainActor
final class MonitoringScheduler {

    static let shared = MonitoringScheduler()

    private let center = DeviceActivityCenter()
    private var restartTask: Task<Void, Never>?
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.YOURORG.socialtimemonitor",
        category: "MonitoringScheduler"
    )

    /// Coalesce several rapid settings changes into one restart.
    func restartDebounced() {
        restartTask?.cancel()
        restartTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled else { return }
            self?.restart()
        }
    }

    /// F4: on launch, only start monitoring if an expected activity is
    /// missing — never restart unconditionally.
    func topUpIfMissing() {
        let settings = SharedSettings()
        let running = (try? center.activities) ?? []
        let expected: Set<DeviceActivityName> = settings.targetMode == .weekly
            ? [.daily, .weekly]
            : [.daily]
        if !expected.isSubset(of: running) {
            restart()
        }
    }

    func restart() {
        let settings = SharedSettings()
        let enabled = settings.enabledTokens
        guard settings.monitoringEnabled, !enabled.isEmpty, let target = settings.targetMinutes else {
            stop()
            return
        }

        let tokens = Set(enabled)
        let mode = settings.targetMode
        let dailyTarget = mode == .daily ? target : Core.TargetMath.toDaily(fromWeeklyMinutes: target)

        // Daily activity: always on; checkpoints for recaps, alerts only
        // in daily mode (F5).
        let dailySchedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        start(.daily, during: dailySchedule,
              events: Self.events(tokens: tokens, targetMinutes: dailyTarget))

        // Weekly activity (weekly mode only): the calendar week.
        if mode == .weekly {
            let weekStart = settings.weekStartsOn
            let weekEnd = ((weekStart + 5) % 7) + 1
            let weeklySchedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: 0, minute: 0, weekday: weekStart),
                intervalEnd: DateComponents(hour: 23, minute: 59, weekday: weekEnd),
                repeats: true
            )
            start(.weekly, during: weeklySchedule,
                  events: Self.events(tokens: tokens, targetMinutes: target))
        } else {
            center.stopMonitoring([.weekly])
        }
    }

    private func start(
        _ name: DeviceActivityName,
        during schedule: DeviceActivitySchedule,
        events: [DeviceActivityEvent.Name: DeviceActivityEvent]
    ) {
        do {
            try center.startMonitoring(name, during: schedule, events: events)
            SharedSettings().lastMonitoringError = nil
        } catch {
            // F6: visible, not swallowed.
            logger.error("startMonitoring \(name.rawValue, privacy: .public) failed: \(String(describing: error), privacy: .public)")
            SharedSettings().lastMonitoringError = "\(name.rawValue): \(error) — \(Date())"
        }
    }

    func stop() {
        center.stopMonitoring([.daily, .weekly])
    }

    /// Six checkpoint events at 25–150% of the target, named "pct.<n>".
    static func events(tokens: Set<ApplicationToken>, targetMinutes: Int) -> [DeviceActivityEvent.Name: DeviceActivityEvent] {
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for percent in Core.Checkpoint.checkpointPercents {
            let minutes = Core.Checkpoint.thresholdMinutes(percent: percent, targetMinutes: targetMinutes)
            events[.init("pct.\(percent)")] = DeviceActivityEvent(
                applications: tokens,
                categories: [],
                webDomains: [],
                threshold: DateComponents(hour: minutes / 60, minute: minutes % 60),
                includesPastActivity: true
            )
        }
        return events
    }
}
