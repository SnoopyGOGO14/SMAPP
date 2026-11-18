// NotificationManager — permission on first switch-on, recap scheduling,
// and routing a tap to the Apps tab. Apple frameworks only.

import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()
    static let openAppsTab = Notification.Name("openAppsTab")

    private let center = UNUserNotificationCenter.current()

    func requestPermissionIfNeeded() {
        Task {
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
            default:
                break
            }
            await scheduleRecapsIfNeeded()
        }
    }

    func scheduleRecapsIfNeeded() async {
        let settings = SharedSettings()
        center.removePendingNotificationRequests(withIdentifiers: Self.recapIdentifiers)
        guard settings.recapsEnabled else { return }
        let status = await center.notificationSettings()
        guard status.authorizationStatus == .authorized || status.authorizationStatus == .provisional else { return }

        // Evening recap, 21:00 local.
        let evening = UNMutableNotificationContent()
        evening.title = "Your day is ready to view"
        evening.body = "See how today went in Social Time Monitor."
        var eveningDate = DateComponents()
        eveningDate.hour = 21
        eveningDate.minute = 0
        try? await center.add(
            UNNotificationRequest(
                identifier: "recap.evening",
                content: evening,
                trigger: UNCalendarNotificationTrigger(dateMatching: eveningDate, repeats: true)
            )
        )

        // Sunday recap, 18:00 local.
        let sunday = UNMutableNotificationContent()
        sunday.title = "Your week is ready to view"
        sunday.body = "See how the week went in Social Time Monitor."
        var sundayDate = DateComponents()
        sundayDate.weekday = 1
        sundayDate.hour = 18
        sundayDate.minute = 0
        try? await center.add(
            UNNotificationRequest(
                identifier: "recap.sunday",
                content: sunday,
                trigger: UNCalendarNotificationTrigger(dateMatching: sundayDate, repeats: true)
            )
        )
    }

    private static let recapIdentifiers = ["recap.evening", "recap.sunday"]
}
