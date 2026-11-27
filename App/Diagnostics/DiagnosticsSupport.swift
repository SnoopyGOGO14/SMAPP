// DiagnosticsSupport — the Diagnostics screen's card builders and
// refresh logic, split out to keep both files under 250 lines.

import SwiftUI
import DeviceActivity
import FamilyControls
import UserNotifications
import Core

#if DEBUG
extension DiagnosticsScreen {

    func diagnosticsCard<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("MutedText"))
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 18))
    }

    func valueRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color("SecondaryText"))
            Spacer()
            Text(value)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
                .lineLimit(2)
        }
    }

    func refresh() {
        lastChecked = dateFormatter.string(from: Date())
        // App Group echo: write, read back.
        let stamp = dateFormatter.string(from: Date())
        appState.settings.diagnosticsTimestamp = stamp
        writtenTimestamp = stamp
        hostEcho = appState.settings.diagnosticsTimestamp == stamp
        // Monitoring.
        activitiesCount = DeviceActivityCenter().activities.count
        // Notifications.
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let status: String
            switch settings.authorizationStatus {
            case .authorized: status = "authorized"
            case .denied: status = "denied"
            case .notDetermined: status = "not determined"
            case .provisional: status = "provisional"
            case .ephemeral: status = "ephemeral"
            @unknown default: status = "unknown"
            }
            notificationStatusText = status
        }
    }

    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Diagnostics test"
        content.body = "If you can read this, local notifications work."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(
            identifier: "diagnostics.test.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    var deviceModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(Character(UnicodeScalar(UInt8(value))))
        }
    }
}
#endif

