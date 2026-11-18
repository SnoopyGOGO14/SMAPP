// DemoData — the sample figures from design/reference/*.dc.html, so the
// screens render identically to the approved mock-ups in demo mode.
// Debug builds only.

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

    static var homeTotal: HomeTotalConfiguration {
        return HomeTotalConfiguration(usedMinutes: 166, allowanceMinutes: 180)
    }

    static func appRow(_ app: DemoApp) -> AppRowConfiguration {
        return AppRowConfiguration(
            usedMinutes: app.todayMinutes,
            targetMinutes: app.targetMinutes,
            largestAppMinutes: 60
        )
    }

    static func appTime(_ app: DemoApp) -> AppTimeConfiguration {
        return AppTimeConfiguration(usedMinutes: app.todayMinutes)
    }

    /// App detail for TikTok: 0d 6h 13m 40s over the week, days 44, 61,
    /// 38, 82, 49, 41, 58 against a 60-minute target (daily average 53,
    /// 5 of 7 within target).
    static var appDetail: AppDetailConfiguration {
        let week = [44.0, 61.0, 38.0, 82.0, 49.0, 41.0, 58.0]
        let labels = ["W", "T", "F", "S", "S", "M", "T"]
        let days = week.enumerated().map { index, minutes in
            AppDetailConfiguration.DayValue(
                label: labels[index],
                minutes: minutes,
                isToday: index == week.count - 1
            )
        }
        return AppDetailConfiguration(
            todayMinutes: 58,
            todayTargetMinutes: 60,
            periodTotalSeconds: 22_420,
            periodDays: days,
            periodTargetMinutes: 60,
            dailyAverageMinutes: 53,
            daysWithinTarget: 5,
            daysCounted: 7
        )
    }

    static var allApps: AllAppsConfiguration {
        let segments = apps.map { app in
            AllAppsConfiguration.Segment(
                paletteIndex: app.paletteIndex,
                minutes: app.todayMinutes
            )
        }
        return AllAppsConfiguration(
            totalMinutes: 166,
            allowanceMinutes: 180,
            segments: segments
        )
    }
}
#endif
