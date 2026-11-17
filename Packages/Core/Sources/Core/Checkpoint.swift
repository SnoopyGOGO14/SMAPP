// Checkpoint — threshold events at fixed percentages of the target.
// The system wakes UsageMonitor when cumulative usage crosses each line;
// 75% and 100% additionally post local notifications.
// isPlausible is the sanity guard for the iOS 26.x early-firing issue:
// the threshold minutes implied by the event must not exceed the minutes
// elapsed since the interval began, otherwise the event is dropped.

import Foundation

public struct Checkpoint: Codable, Equatable {
    public let date: Date
    public let percent: Int

    public init(date: Date, percent: Int) {
        self.date = date
        self.percent = percent
    }

    public static let checkpointPercents: [Int] = [25, 50, 75, 100, 125, 150]

    public static func thresholdMinutes(percent: Int, targetMinutes: Int) -> Int {
        return max(0, Int((Double(percent) / 100.0 * Double(targetMinutes)).rounded()))
    }

    /// Sanity guard: threshold minutes must be ≤ minutes elapsed since the
    /// interval began. Used by UsageMonitor before posting any notification.
    public static func isPlausible(
        percent: Int,
        targetMinutes: Int,
        minutesSinceIntervalStart: Int
    ) -> Bool {
        return thresholdMinutes(percent: percent, targetMinutes: targetMinutes)
            <= minutesSinceIntervalStart
    }
}
