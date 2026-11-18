// HoursFormat — decimal hours for the Summary page (08 plan §8):
//   under 6 minutes → "4 min"
//   6 minutes to under 10 hours → one decimal, "5.3 hrs"
//   10 hours and over → whole, "37 hrs"
//   totals always one decimal, "99.5 hrs"
// Other screens keep DurationFormat's "2h 46m".

import Foundation

public enum HoursFormat {

    public static func hours(minutes: Double) -> String {
        let m = max(0, minutes)
        if m < 6 {
            return "\(Int(m.rounded())) min"
        }
        if m < 600 {
            return String(format: "%.1f hrs", m / 60)
        }
        return "\(Int((m / 60).rounded())) hrs"
    }

    public static func total(minutes: Double) -> String {
        let m = max(0, minutes)
        return String(format: "%.1f hrs", m / 60)
    }
}
