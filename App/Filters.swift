// Filters — builds one DeviceActivityFilter per report context:
// iPhone only, enabled tokens (or a single token), segment and interval
// from Core.PeriodMath / the 7-day window the design shows.

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

enum Filters {

    private static func weekStartsOnToday(calendar: Calendar, days: Int, now: Date = Date()) -> DateInterval {
        let today = calendar.startOfDay(for: now)
        let start = calendar.date(byAdding: .day, value: -(days - 1), to: today) ?? today
        return DateInterval(start: start, end: min(now, calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: today) ?? now)))
    }

    static func interval(for period: Core.Period, calendar: Calendar = .current, now: Date = Date()) -> DateInterval {
        switch period {
        case .hour, .day:
            return calendar.dateInterval(of: .day, for: now)
                ?? DateInterval(start: calendar.startOfDay(for: now), duration: 86_400)
        case .week:
            return weekStartsToday(calendar: calendar, now: now)
        case .month:
            return PeriodMath.dateInterval(for: .month, calendar: calendar, now: now)
        }
    }

    private static func weekStartsToday(calendar: Calendar, now: Date) -> DateInterval {
        return weekStartsOnToday(calendar: calendar, days: 7, now: now)
    }

    private static func make(
        segment: DeviceActivityFilter.SegmentInterval,
        tokens: [ApplicationToken]
    ) -> DeviceActivityFilter {
        return DeviceActivityFilter(
            segment: segment,
            users: .all,
            devices: .init([.iPhone]),
            applications: Set(tokens),
            categories: [],
            webDomains: []
        )
    }

    /// Home card. Daily mode: today against the daily target. Weekly mode:
    /// the last seven days against the weekly target (spec allowance table).
    static func homeTotal(enabled: [ApplicationToken], mode: Core.TargetMode) -> DeviceActivityFilter {
        let interval = interval(for: mode == .daily ? .day : .week)
        return make(segment: .daily(during: interval), tokens: enabled)
    }

    /// One Home row: that app today.
    static func appRow(token: ApplicationToken) -> DeviceActivityFilter {
        return make(segment: .daily(during: interval(for: .day)), tokens: [token])
    }

    /// One All-apps row: that app over the chosen period.
    static func appTime(token: ApplicationToken, period: Core.Period) -> DeviceActivityFilter {
        return make(segment: .daily(during: interval(for: period)), tokens: [token])
    }

    /// App detail: that app, daily segments over the chosen period.
    static func appDetail(token: ApplicationToken, period: Core.Period) -> DeviceActivityFilter {
        return make(segment: .daily(during: interval(for: period)), tokens: [token])
    }

    /// All apps donut: enabled apps over the chosen period.
    static func allApps(enabled: [ApplicationToken], period: Core.Period) -> DeviceActivityFilter {
        return make(segment: .daily(during: interval(for: period)), tokens: enabled)
    }
}
