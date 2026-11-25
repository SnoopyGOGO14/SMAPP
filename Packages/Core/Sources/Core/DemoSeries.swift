// DemoSeries — one coherent set of demo figures (W4): Home's five
// per-app daily minutes, TikTok's approved mock week (the design's
// 44, 61, 38, 82, 49, 41, 58 — with 40 s on today, W8), and the
// derived month series whose last day matches the hero (W9). DemoData
// builds every screen from these so Summary, Home and App detail can
// no longer disagree; the numbers are pure Core and tested.

import Foundation

public enum DemoSeries {

    /// Home's five apps in palette order (TikTok, Instagram, YouTube,
    /// Facebook, X): 58/52/31/14/11 — the approved mock, total 2h 46m.
    public static let dailyMinutes: [Double] = [58, 52, 31, 14, 11]

    /// TikTok's approved mock week — the series App detail draws —
    /// with the design's 40 s on today.
    public static let tikTokWeek: [Double] = [44, 61, 38, 82, 49, 41, 58 + 40.0 / 60]

    public static var dailyTotal: Double {
        return dailyMinutes.reduce(0, +)
    }

    /// A stable per-app week: palette slot 0 (TikTok) gets the
    /// approved mock; other slots get a deterministic series in the
    /// same range.
    public static func week(index: Int) -> [Double] {
        if index == 0 {
            return tikTokWeek
        }
        return (0..<7).map { day in
            Double(((index + 1) * ((day + 3) % 5) * 11 + day * 7 + 24) % 58 + 20)
        }
    }

    public static func weekTotal(index: Int) -> Double {
        return week(index: index).reduce(0, +)
    }

    /// Thirty days per app; the last day is the app's daily figure
    /// plus 40 s (W9: today's bar and hero must match across periods).
    public static func month(index: Int) -> [Double] {
        var series = (0..<30).map { day in
            Double(((index + 1) * ((day + 2) % 7) * 9 + (day % 5) * 8 + 16) % 74 + 8)
        }
        let today = index < dailyMinutes.count ? dailyMinutes[index] : (dailyMinutes.last ?? 0)
        series[series.count - 1] = today + 40.0 / 60
        return series
    }

    public static func monthTotal(index: Int) -> Double {
        return month(index: index).reduce(0, +)
    }
}
