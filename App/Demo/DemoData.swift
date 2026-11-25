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
            // W4: the same total the Summary's Daily view adds up.
            return HomeTotalConfiguration(usedMinutes: Core.DemoSeries.dailyTotal, allowanceMinutes: 180)
        case .over:
            // 3h 20m of 3h — red.
            return HomeTotalConfiguration(usedMinutes: 200, allowanceMinutes: 180)
        case .comfortable:
            // 1h 05m of 3h — green.
            return HomeTotalConfiguration(usedMinutes: 65, allowanceMinutes: 180)
        case .notarget:
            return HomeTotalConfiguration(usedMinutes: Core.DemoSeries.dailyTotal, allowanceMinutes: nil)
        case .paused, .noapps, .noaccess:
            return HomeTotalConfiguration(usedMinutes: Core.DemoSeries.dailyTotal, allowanceMinutes: 180)
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


    /// A per-app total over a period (W4): today from the app's daily
    /// figure; week and month from the same per-app series App detail
    /// draws (`Core.DemoSeries`).
    static func periodMinutes(_ app: DemoApp, period: DemoMode.DemoPeriod) -> Double {
        switch period.dataSet {
        case .today:
            return app.todayMinutes
        case .week:
            return Core.DemoSeries.weekTotal(index: app.paletteIndex)
        case .month:
            return Core.DemoSeries.monthTotal(index: app.paletteIndex)
        }
    }

    // MARK: - Detail by period

    /// App detail for TikTok, drawn from `Core.DemoSeries` (W4/W8/W9):
    /// the design's week series with 40 s on today, the month series
    /// ending on the same today figure, and per-day titles for the
    /// focused line (W7).
    static func appDetail(period: DemoMode.DemoPeriod = .week) -> AppDetailConfiguration {
        let values: [Double]
        let labels: [String]
        let titles: [String]
        let todayMinutes: Double
        switch period.dataSet {
        case .today:
            values = [Core.DemoSeries.dailyMinutes[0] + 40.0 / 60]
            labels = ["T"]
            titles = ["Today"]
            todayMinutes = values[0]
        case .week:
            let series = Core.DemoSeries.week(index: 0)
            values = series
            labels = ["W", "T", "F", "S", "S", "M", "T"]
            titles = ["Wed", "Thu", "Fri", "Sat", "Sun", "Mon", "Tue"]
            // W9: today's figure is identical across periods.
            todayMinutes = series.last ?? Core.DemoSeries.dailyMinutes[0]
        case .month:
            let series = Core.DemoSeries.month(index: 0)
            values = series
            labels = series.enumerated().map { index, _ in
                Core.DayAxis.label(for: index, inWeek: false, weekdayInitials: [], weekdayIndex: 0)
            }
            titles = series.enumerated().map { index, _ in
                Self.monthTitle(index)
            }
            todayMinutes = series.last ?? Core.DemoSeries.dailyMinutes[0]
        }

        let totalSeconds = Int(values.reduce(0, +) * 60)
        let stats = Core.periodStats(
            dailyMinutes: values.map { Int($0) },
            targetMinutes: 60
        )

        let days = values.enumerated().map { index, minutes in
            AppDetailConfiguration.DayValue(
                id: index,
                label: labels[index],
                minutes: minutes,
                isToday: index == values.count - 1,
                title: titles[index]
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

    /// "12 Nov" — a date in the current month at the day the index
    /// represents (W7, month focus line).
    private static func monthTitle(_ index: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        var comps = Calendar.current.dateComponents([.year, .month], from: Date())
        comps.day = min(index + 1, 28)
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }

    // MARK: - Summary (08 plan §9)

    /// W4: one coherent data set — daily = Home's five figures; weekly
    /// and monthly built from the same per-app series App detail draws
    /// (`Core.DemoSeries`). Ranked largest-first.
    static func summary(period: DemoMode.DemoPeriod) -> SummaryConfiguration {
        let apps = DemoData.apps
        let minutes: [Double]
        let label: String
        switch period.dataSet {
        case .today:
            minutes = apps.map { $0.todayMinutes }
            label = "Daily usage"
        case .week:
            minutes = apps.map { Core.DemoSeries.weekTotal(index: $0.paletteIndex) }
            label = "Weekly usage"
        case .month:
            minutes = apps.map { Core.DemoSeries.monthTotal(index: $0.paletteIndex) }
            label = "Monthly usage"
        }

        let total = minutes.reduce(0, +)
        // Rank by time (largest first); position keeps palette order.
        let items = minutes.enumerated()
            .sorted { $0.element > $1.element }
            .enumerated()
            .map { rank, entry in
                SummaryItem(
                    id: rank,
                    rank: rank,
                    minutes: entry.element,
                    sharePercent: total > 0 ? (entry.element / total * 1000).rounded() / 10 : 0,
                    demoName: apps[entry.offset].name,
                    position: entry.offset
                )
            }
        return SummaryConfiguration(
            periodLabel: label,
            totalMinutes: total,
            items: items
        )
    }
}
#endif
