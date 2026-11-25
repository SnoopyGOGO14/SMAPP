// DemoData — sample figures for demo mode. The defaults mirror
// design/reference/*.dc.html; Part 2 adds the state and period variants
// so every screen state is reviewable without an iPhone. Debug only.

#if DEBUG
import Foundation
import Core

enum DemoData {

    struct DemoApp {
        let name: String
        let initials: String
        let paletteIndex: Int
        let todayMinutes: Double
        let targetMinutes: Int?
    }

    static let apps: [DemoApp] = [
        DemoApp(name: "TikTok", initials: "Ti", paletteIndex: 0, todayMinutes: 58, targetMinutes: 60),
        DemoApp(name: "Instagram", initials: "In", paletteIndex: 1, todayMinutes: 52, targetMinutes: 45),
        DemoApp(name: "YouTube", initials: "Yo", paletteIndex: 2, todayMinutes: 31, targetMinutes: 60),
        DemoApp(name: "Facebook", initials: "Fa", paletteIndex: 3, todayMinutes: 14, targetMinutes: nil),
        DemoApp(name: "X", initials: "X", paletteIndex: 4, todayMinutes: 11, targetMinutes: 30)
    ]

    // MARK: - Home hero by state (Part 2)

    static var homeTotal: HomeTotalConfiguration {
        switch DemoMode.state {
        case .default:
            return HomeTotalConfiguration(usedMinutes: 166, allowanceMinutes: 180)
        case .over:
            // 3h 20m of 3h — red.
            return HomeTotalConfiguration(usedMinutes: 200, allowanceMinutes: 180)
        case .comfortable:
            // 1h 05m of 3h — green.
            return HomeTotalConfiguration(usedMinutes: 65, allowanceMinutes: 180)
        case .notarget:
            return HomeTotalConfiguration(usedMinutes: 166, allowanceMinutes: nil)
        case .paused, .noapps, .noaccess:
            return HomeTotalConfiguration(usedMinutes: 166, allowanceMinutes: 180)
        }
    }

    // MARK: - Rows

    static func appRow(_ app: DemoApp) -> AppRowConfiguration {
        return AppRowConfiguration(
            usedMinutes: app.todayMinutes,
            targetMinutes: app.targetMinutes,
            largestAppMinutes: 60
        )
    }


    /// A per-app total over a period: today as-is; week and month from
    /// the deterministic series so charts and rows agree.
    static func periodMinutes(_ app: DemoApp, period: DemoMode.DemoPeriod) -> Double {
        switch period.dataSet {
        case .today:
            return app.todayMinutes
        case .week:
            return weekSeries(index: app.paletteIndex).reduce(0, +)
        case .month:
            return monthSeries(index: app.paletteIndex).reduce(0, +)
        }
    }

    // MARK: - Detail by period

    /// App detail for TikTok. `period` picks the card's data; the week
    /// values are the mock's (44, 61, 38, 82, 49, 41, 58 against a
    /// 60-minute target); the month comes from the 30-day series.
    static func appDetail(period: DemoMode.DemoPeriod = .week) -> AppDetailConfiguration {
        let values: [Double]
        let labels: [String]
        let todayMinutes: Double
        switch period.dataSet {
        case .today:
            values = [58]
            labels = ["T"]
            todayMinutes = 58
        case .week:
            values = [44, 61, 38, 82, 49, 41, 58]
            labels = ["W", "T", "F", "S", "S", "M", "T"]
            todayMinutes = 58
        case .month:
            let series = monthSeries(index: 0)
            values = series
            labels = series.enumerated().map { index, _ in
                Core.DayAxis.label(for: index, inWeek: false, weekdayInitials: [], weekdayIndex: 0)
            }
            todayMinutes = series.last ?? 58
        }

        let totalSeconds = Int(values.reduce(0, +) * 60)
        let stats = Core.periodStats(
            dailyMinutes: values.map { Int($0) },
            targetMinutes: 60
        )

        let days = values.enumerated().map { index, minutes in
            AppDetailConfiguration.DayValue(
                id: index,
                label: period == .month ? labels[index] : labels[index],
                minutes: minutes,
                isToday: index == values.count - 1
            )
        }

        return AppDetailConfiguration(
            todayMinutes: todayMinutes,
            todayTargetMinutes: 60,
            periodTotalSeconds: totalSeconds,
            periodDays: days,
            periodTargetMinutes: 60,
            dailyAverageMinutes: stats.dailyAverageMinutes,
            daysWithinTarget: stats.daysWithinTarget,
            daysCounted: stats.daysCounted
        )
    }

    // MARK: - All apps by period


    // MARK: - Summary (08 plan §9)

    /// The mock's six figures: weekly 37/29/19/8/6/0.5 hrs (total
    /// 99.5), monthly 148/116/76/32/24/2, daily the shared five only
    /// (total 2h 46m), ranked largest-first.
    static func summary(period: DemoMode.DemoPeriod) -> SummaryConfiguration {
        let names = ["TikTok", "WhatsApp", "Facebook", "YouTube", "X", "Instagram"]
        let daily = [58.0, 52.0, 31.0, 14.0, 11.0]
        let weekly = [2220.0, 1740.0, 1140.0, 480.0, 360.0, 30.0]
        let monthly = [8880.0, 6960.0, 4560.0, 1920.0, 1440.0, 120.0]

        let minutes: [Double]
        let label: String
        switch period.dataSet {
        case .today:
            minutes = daily
            label = "Daily usage"
        case .week:
            minutes = weekly
            label = "Weekly usage"
        case .month:
            minutes = monthly
            label = "Monthly usage"
        }

        let total = minutes.reduce(0, +)
        let items = minutes.enumerated().map { index, value in
            SummaryItem(
                id: index,
                rank: index,
                minutes: value,
                sharePercent: (value / total * 1000).rounded() / 10,
                demoName: names[index]
            )
        }
        return SummaryConfiguration(
            periodLabel: label,
            totalMinutes: total,
            items: items
        )
    }

    // MARK: - Deterministic series

    /// Seven values in the mock's range, stable for a given app index.
    static func weekSeries(index: Int) -> [Double] {
        return (0..<7).map { day in
            Double(((index + 1) * ((day + 3) % 5) * 11 + day * 7 + 24) % 58 + 20)
        }
    }

    /// Thirty values for the month view, stable for a given app index.
    static func monthSeries(index: Int) -> [Double] {
        return (0..<30).map { day in
            Double(((index + 1) * ((day + 2) % 7) * 9 + (day % 5) * 8 + 16) % 74 + 8)
        }
    }
}
#endif
