// PeriodMath — the date interval shown for each Stats period at a given
// back/forward offset. Offset 0 is the period containing `now`; −1 is the
// previous period; −12 is twelve periods back.
// Calendar and `now` are injectable so tests are deterministic.
// weekStartsOn is 1 (Sunday) … 7 (Saturday), matching Calendar.firstWeekday.

import Foundation

public enum Period: String, CaseIterable, Codable {
    case hour
    case day
    case week
    case month
}

public enum PeriodMath {

    public static func dateInterval(
        for period: Period,
        offset: Int = 0,
        calendar: Calendar = .current,
        weekStartsOn: Int? = nil,
        now: Date = Date()
    ) -> DateInterval {
        var cal = calendar
        if let weekStartsOn = weekStartsOn {
            cal.firstWeekday = min(max(weekStartsOn, 1), 7)
        }
        switch period {
        case .hour:
            return shiftedInterval(of: .hour, offset: offset, now: now, calendar: cal)
        case .day:
            return shiftedInterval(of: .day, offset: offset, now: now, calendar: cal)
        case .week:
            return shiftedInterval(of: .weekOfYear, offset: offset, now: now, calendar: cal)
        case .month:
            return shiftedInterval(of: .month, offset: offset, now: now, calendar: cal)
        }
    }

    private static func shiftedInterval(
        of component: Calendar.Component,
        offset: Int,
        now: Date,
        calendar: Calendar
    ) -> DateInterval {
        guard let current = calendar.dateInterval(of: component, for: now) else {
            return DateInterval(start: now, duration: 0)
        }
        guard offset != 0 else { return current }
        guard
            let anchor = calendar.date(byAdding: component, value: offset, to: current.start),
            let shifted = calendar.dateInterval(of: component, for: anchor)
        else {
            return current
        }
        return shifted
    }
}
