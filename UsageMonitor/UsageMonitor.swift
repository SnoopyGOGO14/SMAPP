// UsageMonitor — woken by the system when a checkpoint is crossed.
// Parses the percentage from the event name, runs the sanity guard
// (iOS 26.x early-fire issue), saves lastCheckpoint, and posts a local
// notification at 75% and 100%. Foundation, DeviceActivity and
// UserNotifications only — the ~6 MB memory ceiling allows no more.

import Foundation
import DeviceActivity
import UserNotifications
import Core
import os

final class UsageMonitor: DeviceActivityMonitor {

    private let logger = Logger(subsystem: "com.YOURORG.socialtimemonitor", category: "UsageMonitor")
    private let settings = SharedSettings()

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)

        guard let percent = Self.percent(from: event.rawValue) else {
            logger.debug("unrecognised event \(event.rawValue, privacy: .public)")
            return
        }

        let mode = settings.targetMode
        let isWeekly = activity == .weekly
        guard let target = effectiveTarget(for: mode, isWeekly: isWeekly) else { return }

        let elapsed = Self.minutesSinceIntervalStart(
            weekly: isWeekly,
            weekStartsOn: settings.weekStartsOn
        )

        // Sanity guard: drop events that fire before real usage could have.
        guard Core.Checkpoint.isPlausible(
            percent: percent,
            targetMinutes: target,
            minutesSinceIntervalStart: elapsed
        ) else {
            logger.notice("dropped early event pct \(percent) at \(elapsed) minutes")
            return
        }

        settings.lastCheckpoint = Core.Checkpoint(date: Date(), percent: percent)

        guard settings.alertsEnabled, percent == 75 || percent == 100 else { return }
        postAlert(percent: percent, weekly: isWeekly)
    }

    // MARK: - Helpers

    private func effectiveTarget(for mode: Core.TargetMode, isWeekly: Bool) -> Int? {
        guard let target = settings.targetMinutes else { return nil }
        if isWeekly {
            return mode == .weekly ? target : Core.TargetMath.toWeekly(fromDailyMinutes: target)
        }
        return mode == .daily ? target : Core.TargetMath.toDaily(fromWeeklyMinutes: target)
    }

    private static func percent(from name: String) -> Int? {
        guard name.hasPrefix("pct.") else { return nil }
        return Int(name.dropFirst(4))
    }

    /// Minutes elapsed since the interval began: midnight for the daily
    /// schedule, the week's first day 00:00 for the weekly schedule.
    private static func minutesSinceIntervalStart(weekly: Bool, weekStartsOn: Int) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: Date())
        let nowMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        guard weekly else { return nowMinutes }

        let today = components.weekday ?? 1
        var daysElapsed = today - weekStartsOn
        if daysElapsed < 0 { daysElapsed += 7 }
        return daysElapsed * 24 * 60 + nowMinutes
    }

    private func postAlert(percent: Int, weekly: Bool) {
        let content = UNMutableNotificationContent()
        let noun = weekly ? "week's" : "today's"
        if percent == 75 {
            content.title = "About three-quarters of \(noun) target used"
        } else {
            content.title = "\(weekly ? "This week's" : "Today's") target reached"
        }
        content.body = "Figures are approximate — open the app for the accurate total."
        content.sound = .default
        content.categoryIdentifier = "zone"
        content.userInfo = ["open": "apps"]

        let request = UNNotificationRequest(
            identifier: "zone.\(percent).\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
