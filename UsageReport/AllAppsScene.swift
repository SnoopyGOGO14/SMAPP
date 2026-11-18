// AllAppsScene — the donut. One segment per app with time, palette colour
// by orderedTokens position, total and "of Xh" in the centre.

import DeviceActivity
import SwiftUI
import FamilyControls
import Core
import SharedUI

struct AllAppsScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .allApps
    let content: (AllAppsConfiguration) -> DonutView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> AllAppsConfiguration {
        let settings = SharedSettings()
        let byToken = await Aggregator.secondsByToken(data)

        let order = settings.orderedTokens
        let tokens = order.isEmpty ? Array(byToken.keys) : order.filter { byToken[$0] != nil }

        let segments = tokens.map { token in
            AllAppsConfiguration.Segment(
                paletteIndex: settings.paletteIndex(for: token),
                minutes: (byToken[token] ?? 0) / 60
            )
        }
        .filter { $0.minutes > 0 }

        let total = segments.reduce(0.0) { $0 + $1.minutes }

        // Centre caption: the daily allowance for today's donut, the weekly
        // allowance for the week, none for the month (ASSUMED; logged).
        let allowance: Int?
        if let target = settings.targetMinutes {
            switch settings.statsPeriod {
            case .day:
                allowance = TargetMath.allowanceMinutes(view: .todayRing, mode: .daily, targetMinutes: target)
            case .week:
                allowance = TargetMath.allowanceMinutes(view: .todayRing, mode: .weekly, targetMinutes: target)
            case .month, .hour:
                allowance = nil
            }
        } else {
            allowance = nil
        }

        return AllAppsConfiguration(
            totalMinutes: total,
            allowanceMinutes: allowance,
            segments: segments
        )
    }
}
