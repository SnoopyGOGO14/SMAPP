// HourlyStats — the Daily view's stats (Z3): the busiest hour of the
// day and the count of hour-long buckets at or over 15 minutes. Pure
// Core — tested; the demo and the live scene both feed it 24 values.

import Foundation

public enum HourlyStats {

    public struct Summary: Equatable {
        /// 0–23; nil when the day is empty.
        public let busiestHour: Int?
        /// Hours whose usage reached 15 minutes.
        public let sessionsOver15: Int

        public init(busiestHour: Int?, sessionsOver15: Int) {
            self.busiestHour = busiestHour
            self.sessionsOver15 = sessionsOver15
        }
    }

    /// `hours`: per-hour minutes, index 0–23 (shorter arrays are
    /// tolerated; the index is the hour).
    public static func summarize(hours: [Double]) -> Summary {
        guard let peak = hours.indices.max(by: { hours[$0] < hours[$1] }), hours[peak] > 0 else {
            return Summary(busiestHour: nil, sessionsOver15: 0)
        }
        let sessions = hours.filter { $0 >= 15 }.count
        return Summary(busiestHour: peak, sessionsOver15: sessions)
    }

    /// "9pm" / "3am"; nil for an empty day.
    public static func hourLabel(_ hour: Int?) -> String {
        guard let hour, (0...23).contains(hour) else { return "—" }
        let suffix = hour < 12 ? "am" : "pm"
        let twelve = hour % 12 == 0 ? 12 : hour % 12
        return "\(twelve)\(suffix)"
    }
}
