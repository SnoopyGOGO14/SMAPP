// SummaryBuild + SummaryScene + SummaryFocusScene — the Summary's
// configuration building, shared by the normal scene (context
// `summary`, taps inside the report) and the host-driven focus
// fallback (contexts `summary.f0` … `summary.f7`, Part 2).

import DeviceActivity
import SwiftUI
import FamilyControls
import ManagedSettings
import Core

enum SummaryBuild {
    /// The ranked configuration from real activity; `initialFocus`
    /// carries the host-driven focus when the context name has one.
    static func configuration(
        _ data: DeviceActivityResults<DeviceActivityData>
    ) async -> SummaryConfiguration {
        let settings = SharedSettings()
        let byToken = await Aggregator.secondsByToken(data)

        // Rank by time; orderedTokens order breaks ties.
        let order = settings.orderedTokens
        let entries: [(position: Int, seconds: Double, token: ApplicationToken)]
        if order.isEmpty {
            entries = byToken.map { token, seconds in
                (0, seconds, token)
            }
        } else {
            entries = order.compactMap { token in
                guard let seconds = byToken[token], seconds > 0 else { return nil }
                return (order.firstIndex(of: token) ?? 0, seconds, token)
            }
        }

        let ranked = Core.Ranking.rank(
            apps: entries.map { ($0.position, $0.seconds) }
        )

        let items = ranked.compactMap { rankedApp -> SummaryItem? in
            guard let entry = entries.first(where: { $0.position == rankedApp.position }) else {
                return nil
            }
            return SummaryItem(
                id: rankedApp.rank,
                rank: rankedApp.rank,
                minutes: rankedApp.seconds / 60,
                sharePercent: rankedApp.sharePercent,
                token: entry.token,
                position: entry.position
            )
        }

        let total = items.reduce(0.0) { $0 + $1.minutes }
        let label = settings.summaryPeriod.rawValueString + " usage"

        return SummaryConfiguration(
            periodLabel: label,
            totalMinutes: total,
            items: items
        )
    }
}

struct SummaryScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .summary
    let content: (SummaryConfiguration) -> SummaryView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> SummaryConfiguration {
        return await SummaryBuild.configuration(data)
    }
}
