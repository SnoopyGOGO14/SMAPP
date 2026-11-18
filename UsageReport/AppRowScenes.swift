// AppRowScene — the per-row report for Home. The app filters each
// report to a single app; the data itself names the app, so the scene
// looks up that token's per-app target and palette slot.

import DeviceActivity
import SwiftUI
import FamilyControls
import ManagedSettings
import Core

struct AppRowScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .appRow
    let content: (AppRowConfiguration) -> AppRowReportView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> AppRowConfiguration {
        let settings = SharedSettings()
        let byToken = await Aggregator.secondsByToken(data)
        let used = byToken.values.reduce(0, +)
        let token = byToken.keys.first
        // Neutral bars scale against a fixed 60-minute reference because a
        // single-token filter cannot see the day's largest app (deviation
        // logged in PROGRESS.md; matches the mock within 0.4 percentage
        // points for the sample data).
        return AppRowConfiguration(
            usedMinutes: used / 60,
            targetMinutes: token.flatMap { settings.target(for: $0) },
            largestAppMinutes: 60
        )
    }
}
