// DurationFormat — short duration strings, British English.
// Rule (recorded in PROGRESS.md as a Session 1 decision):
//   below an hour → minutes only          46  → "46m"
//   exact hours   → hours only            60  → "1h", 600 → "10h"
//   mixed         → both                  134 → "2h 14m"
//   zero          →                        0  → "0m"
// "46m left" is the ring's remaining-time string while green or amber.

import Foundation

public enum DurationFormat {

    public static func short(minutes: Int) -> String {
        let m = max(0, minutes)
        let hours = m / 60
        let remainder = m % 60
        if hours == 0 { return "\(remainder)m" }
        if remainder == 0 { return "\(hours)h" }
        return "\(hours)h \(remainder)m"
    }

    /// "46m left" — shown on the ring while in green or amber.
    public static func left(minutes: Int) -> String {
        return short(minutes: minutes) + " left"
    }

    /// X4: one truncation rule for seconds. Home's row and the detail
    /// hero must give the same text for the same seconds — 3,520 s is
    /// "58m" everywhere (58.67 minutes truncated, never rounded up).
    public static func fromSeconds(_ seconds: TimeInterval) -> String {
        return short(minutes: Int(seconds / 60))
    }
}
