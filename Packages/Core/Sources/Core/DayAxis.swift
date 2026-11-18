// DayAxis — unique identity and label positions for period bar charts
// (F3: weekday initials repeat — T/T, S/S — so labels can never be
// identity). Ids are 0-based indexes; label positions say which bars
// carry a visible label (all of them for a week; days 1, 8, 15, 22 and
// 29 for a month).

import Foundation

public enum DayAxis {

    /// Unique ids for a period's days. Ids are unique by construction
    /// even when labels repeat.
    public static func ids(count: Int) -> [Int] {
        guard count > 0 else { return [] }
        return Array(0..<count)
    }

    /// Positions that carry a visible label.
    /// - A week (≤ 7 days): every position.
    /// - Longer (month): day numbers 1, 8, 15, 22 and 29 — indexes
    ///   0, 7, 14, 21, 28, clamped to the count.
    public static func labelIndexes(count: Int) -> Set<Int> {
        guard count > 0 else { return [] }
        if count <= 7 {
            return Set(0..<count)
        }
        return Set([0, 7, 14, 21, 28].filter { $0 < count })
    }

    /// The label for a position: the weekday initial for weeks, the day
    /// number (1-based) for labelled positions in longer periods, and an
    /// empty string elsewhere.
    public static func label(for position: Int, inWeek: Bool, weekdayInitials: [String], weekdayIndex: Int) -> String {
        if inWeek {
            let index = ((weekdayIndex % weekdayInitials.count) + weekdayInitials.count) % weekdayInitials.count
            return weekdayInitials[index]
        }
        return labelIndexes(count: Int.max).contains(position) ? String(position + 1) : ""
    }
}
