// PeriodProgress — the fraction of the day, week (from weekStartsOn)
// or month that has elapsed at a given moment. Drives the underline
// bar on the active period tab (pure clock arithmetic; no usage data).

import Foundation

public enum PeriodProgress {

    /// 0…1 through the current day.
    public static func dayFraction(now: Date = Date(), calendar: Calendar = .current) -> Double {
        let start = calendar.startOfDay(for: now)
        let elapsed = now.timeIntervalSince(start)
        return clamp(elapsed / 86_400)
    }

    /// 0…1 through the current calendar week.
    public static func weekFraction(weekStartsOn: Int, now: Date = Date(), calendar: Calendar = .current) -> Double {
        let start = weekStart(weekStartsOn: weekStartsOn, now: now, calendar: calendar)
        let elapsed = now.timeIntervalSince(start)
        return clamp(elapsed / (7 * 86_400))
    }

    /// 0…1 through the current calendar month.
    public static func monthFraction(now: Date = Date(), calendar: Calendar = .current) -> Double {
        guard let month = calendar.dateInterval(of: .month, for: now) else { return 0 }
        let elapsed = now.timeIntervalSince(month.start)
        return clamp(elapsed / month.duration)
    }

    public static func weekStart(weekStartsOn: Int, now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today)
        var daysBack = weekday - weekStartsOn
        if daysBack < 0 { daysBack += 7 }
        return calendar.date(byAdding: .day, value: -daysBack, to: today) ?? today
    }

    private static func clamp(_ value: Double) -> Double {
        return min(max(value, 0), 1)
    }
}
