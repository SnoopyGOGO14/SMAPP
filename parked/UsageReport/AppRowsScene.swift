// AppRowsScene — Part 2's Home rows fallback (context `appRows`): one
// report drawing every enabled app's row (today's figures, host's row
// order), instead of one small report per row.

import DeviceActivity
import SwiftUI
import FamilyControls
import ManagedSettings
import Core

struct AppRowsScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .appRows
    let content: (AppRowsConfiguration) -> AppRowsView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> AppRowsConfiguration {
        let settings = SharedSettings()
        let byToken = await Aggregator.secondsByToken(data)
        let order = settings.enabledTokens.isEmpty
            ? settings.orderedTokens
            : settings.orderedTokens.filter { settings.enabledTokens.contains($0) }
        let rows = order.map { token in
            AppRowConfiguration(
                usedMinutes: (byToken[token] ?? 0) / 60,
                targetMinutes: settings.target(for: token),
                largestAppMinutes: 60
            )
        }
        return AppRowsConfiguration(rows: rows)
    }
}
