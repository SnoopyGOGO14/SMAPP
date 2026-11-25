// HoursFormat — decimal hours for the Summary page (08 plan §8,
// W5 revision):
//   under 6 minutes → "4 min"
//   6 minutes to under 10 hours → one decimal, "5.3 hrs"
//   whole hours drop the ".0" → "8 hrs", "6 hrs"; exactly one → "1 hr"
//   10 hours and over → whole hours ("37 hrs")
//   totals follow the same rule ("99.5 hrs", "8 hrs")
// Other screens keep DurationFormat's "2h 46m".

import Foundation

public enum HoursFormat {

    public static func hours(minutes: Double) -> String {
        let m = max(0, minutes)
        if m < 6 {
            return "\(Int(m.rounded())) min"
        }
        return wholeOrDecimal(hours: m / 60)
    }

    public static func total(minutes: Double) -> String {
        let m = max(0, minutes)
        return wholeOrDecimal(hours: m / 60)
    }

    /// "8 hrs" when the hour value is whole (one hour is "1 hr");
    /// "5.3 hrs" otherwise.
    private static func wholeOrDecimal(hours: Double) -> String {
        let rounded = hours.rounded()
        if abs(rounded - hours) < 0.05 {
            let whole = Int(rounded)
            if whole == 1 {
                return "1 hr"
            }
            return "\(whole) hrs"
        }
        return String(format: "%.1f hrs", hours)
    }
}
