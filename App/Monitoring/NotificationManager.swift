// NotificationManager — requests notification permission on the first
// switch-on, and owns the tab-routing notification name. Apple
// frameworks only. (Recaps are parked; docs/later.md.)

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
        }
    }
}
