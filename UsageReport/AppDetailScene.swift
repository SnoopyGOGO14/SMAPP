// AppDetailScene — today's card plus the chosen period card and the two
// stats, for the single app the app filtered on.

import DeviceActivity
import SwiftUI
import FamilyControls
import Core

struct AppDetailScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .appDetail
    let content: (AppDetailConfiguration) -> AppDetailCardView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> AppDetailConfiguration {
        let settings = SharedSettings()
        let calendar = Calendar.current
        let byToken = await Aggregator.dailySecondsByToken(data)
        let token = settings.detailToken ?? byToken.keys.first

        let daily = (token.flatMap { byToken[$0] } ?? [])
            .sorted { $0.dayStart < $1.dayStart }

        // Fill any gap days between the first and last day with zeros so
        // the bar chart shows every day of the period.
        var daySeconds: [(start: Date, seconds: TimeInterval)] = []
        if let first = daily.first, let last = daily.last {
            var cursor = first.dayStart
            var index = 0
            while cursor <= last.dayStart {
                if index < daily.count && daily[index].dayStart == cursor {
                    daySeconds.append((cursor, daily[index].seconds))
                    index += 1
                } else {
                    daySeconds.append((cursor, 0))
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
                cursor = next
            }
        }

        let todayStart = calendar.startOfDay(for: Date())
        let todaySeconds = daily.last(where: { $0.dayStart == todayStart })?.seconds
            ?? daySeconds.last(where: { $0.start == todayStart })?.seconds
            ?? 0
        let periodSeconds = daySeconds.reduce(0) { $0 + $1.seconds }

        let target = token.flatMap { settings.target(for: $0) }
        let stats = Core.periodStats(
            dailyMinutes: daySeconds.map { Int(($0.seconds / 60).rounded()) },
            targetMinutes: target ?? Int.max
        )

        let formatter = DateFormatter()
        let initials = calendar.veryShortWeekdaySymbols.map { symbol in
            String(symbol.prefix(1))
        }

        let days = daySeconds.enumerated().map { index, entry in
            AppDetailConfiguration.DayValue(
                label: initials[calendar.component(.weekday, from: entry.start) - 1],
                minutes: entry.seconds / 60,
                isToday: entry.start == todayStart
            )
        }

        return AppDetailConfiguration(
            todayMinutes: todaySeconds / 60,
            todayTargetMinutes: target,
            periodTotalSeconds: Int(periodSeconds),
            periodDays: days,
            periodTargetMinutes: target,
            dailyAverageMinutes: stats.dailyAverageMinutes,
            daysWithinTarget: target == nil ? 0 : stats.daysWithinTarget,
            daysCounted: stats.daysCounted
        )
    }
}
