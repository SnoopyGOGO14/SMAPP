// DurationParts — exact breakdown of a duration in seconds into
// days, hours, minutes and seconds, and the "0d 6h 13m 40s" line used
// on the App detail period card.

import Foundation

public struct DurationParts: Equatable {
    public let days: Int
    public let hours: Int
    public let minutes: Int
    public let seconds: Int

    public init(seconds: Int) {
        let total = max(0, seconds)
        days = total / 86400
        hours = (total % 86400) / 3600
        minutes = (total % 3600) / 60
        self.seconds = total % 60
    }

    /// "0d 6h 13m 40s" — every unit shown, including zeros.
    public var line: String {
        return "\(days)d \(hours)h \(minutes)m \(seconds)s"
    }
}
