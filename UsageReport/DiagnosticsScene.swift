// DiagnosticsScene — the Gate A checklist's extension side (Part 1):
// reads the App Group back (timestamp, target) and walks the results
// the host filtered (today's seconds, app count, day segments over the
// 35-day request). Demo mode builds the same configuration from sample
// values.

import DeviceActivity
import SwiftUI
import FamilyControls
import ManagedSettings
import Core

#if DEBUG
struct DiagnosticsScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .diagnostics
    let content: (DiagnosticsConfiguration) -> DiagnosticsReportView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> DiagnosticsConfiguration {
        let settings = SharedSettings()
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        var todaySeconds: Double = 0
        var appCount = 0
        var segmentCount = 0
        var seenTokens = Set<ApplicationToken>()

        for await device in data {
            for await segment in device.activitySegments {
                segmentCount += 1
                let isToday = segment.dateInterval.start == todayStart
                for await category in segment.categories {
                    for await app in category.applications {
                        if let token = app.application.token, !seenTokens.contains(token) {
                            seenTokens.insert(token)
                            appCount += 1
                        }
                        if isToday {
                            todaySeconds += app.totalActivityDuration
                        }
                    }
                }
            }
        }

        return DiagnosticsConfiguration(
            appGroupTimestamp: settings.diagnosticsTimestamp,
            targetMinutes: settings.targetMinutes,
            todaySeconds: segmentCount > 0 ? todaySeconds : nil,
            appCount: appCount,
            daySegments: segmentCount
        )
    }
}
#endif
