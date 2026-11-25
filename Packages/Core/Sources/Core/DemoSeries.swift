// DemoSeries — one coherent set of demo figures (W4, revised X1/X5):
// Home's five per-app daily minutes, TikTok's approved mock week (the
// design's 44, 61, 38, 82, 49, 41, 58 — with 40 s on today, W8), and
// per-day figures so the Daily view can show a *chosen* day (X1).
// Other apps' weeks and months are scaled from TikTok's so every
// period ranks the apps in the same order the daily figures do (X5).
// DemoData builds every screen from these. Pure Core — tested.

import Foundation

public enum DemoSeries {

    /// Home's five apps in palette order (TikTok, Instagram, YouTube,
    /// Facebook, X): 58/52/31/14/11 — the approved mock, total 2h 46m.
    public static let dailyMinutes: [Double] = [58, 52, 31, 14, 11]

    /// TikTok's approved mock week — the series App detail draws —
    /// with the design's 40 s on today.
    public static let tikTokWeek: [Double] = [44, 61, 38, 82, 49, 41, 58 + 40.0 / 60]

    /// The month's 30 values for TikTok; the last is today's figure.
    /// Failure class 15: the arithmetic is broken into typed
    /// sub-expressions — the one-liner's untyped literal chain timed
    /// out the type-checker (run 34).
    private static let monthBase: [Double] = (0..<30).map { day -> Double in
        let weekdayCycle: Int = (day + 2) % 7
        let fiveCycle: Int = day % 5
        let raw: Int = weekdayCycle * 9 + fiveCycle * 8 + 16
        return Double(raw % 74 + 8)
    }

    public static var dailyTotal: Double {
        return dailyMinutes.reduce(0, +)
    }

    // MARK: - Per-day figures (X1)

    /// The five apps' minutes on a given day of the demo week
    /// (0 = Monday … 6 = today). Today is Home's five figures (with
    /// TikTok's 40 s, matching the week chart's last bar); other days
    /// come from the per-app week series, so a chosen day differs.
    public static func dailyFigures(dayIndex: Int) -> [Double] {
        let index = min(max(dayIndex, 0), 6)
        guard index != 6 else {
            var today = dailyMinutes
            today[0] += 40.0 / 60
            return today
        }
        return (0..<dailyMinutes.count).map { app in
            week(index: app)[index]
        }
    }

    // MARK: - Weeks

    /// A stable per-app week: palette slot 0 (TikTok) gets the approved
    /// mock; other slots get the mock scaled to their daily figure
    /// (last day exact), so the weekly order matches the daily order
    /// (X5).
    public static func week(index: Int) -> [Double] {
        if index == 0 {
            return tikTokWeek
        }
        let app = min(max(index, 0), dailyMinutes.count - 1)
        let factor = dailyMinutes[app] / dailyMinutes[0]
        var series = (0..<6).map { day in
            (tikTokWeek[day] * factor).rounded()
        }
        series.append(dailyMinutes[app])
        return series
    }

    public static func weekTotal(index: Int) -> Double {
        return week(index: index).reduce(0, +)
    }

    // MARK: - Months

    /// Thirty days per app; the last day is the app's daily figure
    /// (W9: today's bar and hero must match across periods). Other
    /// apps' months are scaled from TikTok's, keeping the order.
    public static func month(index: Int) -> [Double] {
        let today = dailyMinutes[min(max(index, 0), dailyMinutes.count - 1)]
        let factor = today / dailyMinutes[0]
        var series = monthBase.map { value in
            (value * factor).rounded()
        }
        if index == 0 {
            series[series.count - 1] = dailyMinutes[0] + 40.0 / 60
        } else {
            series[series.count - 1] = today
        }
        return series
    }

    public static func monthTotal(index: Int) -> Double {
        return month(index: index).reduce(0, +)
    }
}
