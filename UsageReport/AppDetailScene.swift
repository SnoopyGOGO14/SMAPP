// AppDetailScene — today's card plus the chosen period card and the two
// stats, for the single app the app filtered on. Z3: on Daily the
// period card is the day hour by hour (24 hourly segments from the
// filter), with no target rule and hourly stats.

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

        let target = token.flatMap { settings.target(for: $0) }

        if settings.statsPeriod == .day {
            return hourlyConfiguration(daily: daily, target: target, calendar: calendar)
        }
        return periodConfiguration(daily: daily, target: target, calendar: calendar, settings: settings)
    }

    // MARK: - Z3: the day hour by hour

    private func hourlyConfiguration(
        daily: [Aggregator.DayTotal],
        target: Int?,
        calendar: Calendar
    ) -> AppDetailConfiguration {
        var hourSeconds = Array(repeating: 0.0, count: 24)
        for entry in daily {
            let hour = calendar.component(.hour, from: entry.dayStart)
            if (0..<24).contains(hour) {
                hourSeconds[hour] += entry.seconds
            }
        }
        let totalSeconds = hourSeconds.reduce(0, +)
        let stats = Core.HourlyStats.summarize(hours: hourSeconds.map { $0 / 60 })

        let days = hourSeconds.enumerated().map { hour, seconds in
            AppDetailConfiguration.DayValue(
                id: hour,
                label: hour % 6 == 0 ? "\(hour)" : "",
                minutes: seconds / 60,
                isToday: false,
                title: Core.HourlyStats.hourLabel(hour)
            )
        }

        var config = AppDetailConfiguration(
            todayMinutes: totalSeconds / 60,
            todayTargetMinutes: target,
            periodTotalSeconds: Int(totalSeconds),
            periodDays: days,
            // No dashed target rule on the hourly chart.
            periodTargetMinutes: nil,
            dailyAverageMinutes: Int((totalSeconds / 60 / 24).rounded()),
            daysWithinTarget: 0,
            daysCounted: 24
        )
        config.hourly = true
        config.busiestHour = stats.busiestHour
        config.sessionsOver15 = stats.sessionsOver15
        return config
    }

    // MARK: - Weeks and months

    private func periodConfiguration(
        daily: [Aggregator.DayTotal],
        target: Int?,
        calendar: Calendar,
        settings: SharedSettings
    ) -> AppDetailConfiguration {
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

        let stats = Core.periodStats(
            dailyMinutes: daySeconds.map { Int(($0.seconds / 60).rounded()) },
            targetMinutes: target ?? Int.max
        )

        let initials = calendar.veryShortWeekdaySymbols.map { symbol in
            String(symbol.prefix(1))
        }
        let inWeek = settings.statsPeriod != .month
        // W7: the focused line's name — "Sun" on weeks, "12 Nov" on
        // months (single initials were ambiguous: two S days, two T).
        let titleFormatter = DateFormatter()
        titleFormatter.dateFormat = inWeek ? "EEE" : "d MMM"

        let days = daySeconds.enumerated().map { index, entry in
            AppDetailConfiguration.DayValue(
                id: index,
                label: Core.DayAxis.label(
                    for: index,
                    inWeek: inWeek,
                    weekdayInitials: initials,
                    weekdayIndex: calendar.component(.weekday, from: entry.start) - 1
                ),
                minutes: entry.seconds / 60,
                isToday: entry.start == todayStart,
                title: titleFormatter.string(from: entry.start)
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
