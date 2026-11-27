// SummaryPeriod — the periods the Summary page shows (08 plan §8):
// daily (optionally a chosen day), weekly, monthly, and yearly (built,
// hidden until a device proves a year of history). Provides each
// period's date interval, which day pill is today, and which pills lie
// in the future (disabled).

import Foundation

public enum SummaryPeriod: Equatable {
    case daily(day: Date?)
    case weekly
    case monthly

    public var rawValueString: String {
        switch self {
        case .daily: return "daily"
        case .weekly: return "weekly"
        case .monthly: return "monthly"
        }
    }

    public static func from(rawValue: String, day: Date? = nil) -> SummaryPeriod {
        switch rawValue {
        case "daily": return .daily(day: day)
        case "weekly": return .weekly
        case "monthly": return .monthly
        default: return .weekly
        }
    }

    /// The interval the report filters on.
    public func interval(calendar: Calendar = .current, weekStartsOn: Int = 2, now: Date = Date()) -> DateInterval {
        switch self {
        case .daily(let day):
            let date = day ?? now
            return calendar.dateInterval(of: .day, for: date)
                ?? DateInterval(start: calendar.startOfDay(for: date), duration: 86_400)
        case .weekly:
            let start = PeriodProgress.weekStart(weekStartsOn: weekStartsOn, now: now, calendar: calendar)
            return DateInterval(start: start, end: now)
        case .monthly:
            return calendar.dateInterval(of: .month, for: now)
                ?? DateInterval(start: calendar.startOfDay(for: now), duration: 86_400)
            return calendar.dateInterval(of: .year, for: now)
                ?? DateInterval(start: calendar.startOfDay(for: now), duration: 86_400)
        }
    }

    /// Index (0…6, Monday-first is NOT assumed — follows weekStartsOn)
    /// of today's day pill; nil when the period is not daily.
    public func todayPillIndex(weekStartsOn: Int, now: Date = Date(), calendar: Calendar = .current) -> Int? {
        switch self {
        case .daily:
            let weekday = calendar.component(.weekday, from: now)
            return ((weekday - weekStartsOn) + 7) % 7
        default:
            return nil
        }
    }

    /// Day-pill indices that lie in the future (disabled). Daily only.
    public func futurePillIndexes(weekStartsOn: Int, now: Date = Date(), calendar: Calendar = .current) -> Set<Int> {
        guard case .daily = self else { return [] }
        let todayIndex = todayPillIndex(weekStartsOn: weekStartsOn, now: now, calendar: calendar) ?? 0
        return Set((todayIndex + 1..<7))
    }

    /// The date a day pill refers to, given its index.
    public static func pillDate(index: Int, weekStartsOn: Int, now: Date = Date(), calendar: Calendar = .current) -> Date {
        let start = PeriodProgress.weekStart(weekStartsOn: weekStartsOn, now: now, calendar: calendar)
        return calendar.date(byAdding: .day, value: index, to: start) ?? start
    }

    /// The pill index a date falls on — the inverse of `pillDate`
    /// (X1: the demo's chosen day maps back to its data set).
    public static func pillIndexOf(date: Date, weekStartsOn: Int, now: Date = Date(), calendar: Calendar = .current) -> Int? {
        let start = PeriodProgress.weekStart(weekStartsOn: weekStartsOn, now: now, calendar: calendar)
        let days = calendar.dateComponents([.day], from: start, to: date).day ?? 0
        guard days >= 0, days < 7 else { return nil }
        return days
    }
}
