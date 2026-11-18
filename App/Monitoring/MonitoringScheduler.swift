// MonitoringScheduler — starts and restarts DeviceActivity monitoring.
// Daily mode: one repeating midnight-to-midnight activity with the six
// checkpoint events. Weekly mode: a second activity spanning the user's
// week with thresholds as percentages of the weekly target (spec § Rules
// for the monitor extension). Restarts are debounced to one second.

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

@MainActor
final class MonitoringScheduler {

    static let shared = MonitoringScheduler()

    private let center = DeviceActivityCenter()
    private var restartTask: Task<Void, Never>?

    /// Coalesce several rapid settings changes into one restart.
    func restartDebounced() {
        restartTask?.cancel()
        restartTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled else { return }
            self?.restart()
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

        // Daily activity: always on, drives the checkpoints and recaps.
        let dailySchedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        do {
            try center.startMonitoring(
                .daily,
                during: dailySchedule,
                events: Self.events(tokens: tokens, targetMinutes: dailyTarget)
            )
        } catch {
            // Recorded by the caller's logger; monitoring continues on the
            // next settings change.
        }

        // Weekly activity (weekly mode only): thresholds on the weekly target.
        if mode == .weekly {
            let weekStart = settings.weekStartsOn
            let weekEnd = ((weekStart + 5) % 7) + 1
            let weeklySchedule = DeviceActivitySchedule(
                intervalStart: DateComponents(weekday: weekStart, hour: 0, minute: 0),
                intervalEnd: DateComponents(weekday: weekEnd, hour: 23, minute: 59),
                repeats: true
            )
            do {
                try center.startMonitoring(
                    .weekly,
                    during: weeklySchedule,
                    events: Self.events(tokens: tokens, targetMinutes: target)
                )
            } catch {
                // See above.
            }
        } else {
            center.stopMonitoring([.weekly])
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
