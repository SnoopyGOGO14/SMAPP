// PeriodStats — the two App detail stats and the longest-day figure,
// from a list of daily totals and the app's target. "Within target"
// means the day's total did not exceed the target.

import Foundation

public struct PeriodStatsSummary: Equatable {
    public let dailyAverageMinutes: Int
    public let daysWithinTarget: Int
    public let daysCounted: Int
    public let longestDayMinutes: Int
}

public func periodStats(dailyMinutes: [Int], targetMinutes: Int) -> PeriodStatsSummary {
    guard !dailyMinutes.isEmpty else {
        return PeriodStatsSummary(
            dailyAverageMinutes: 0, daysWithinTarget: 0, daysCounted: 0, longestDayMinutes: 0
        )
    }
    let total = dailyMinutes.reduce(0, +)
    let average = Int((Double(total) / Double(dailyMinutes.count)).rounded())
    let within = dailyMinutes.filter { $0 <= targetMinutes }.count
    let longest = dailyMinutes.max() ?? 0
    return PeriodStatsSummary(
        dailyAverageMinutes: average,
        daysWithinTarget: within,
        daysCounted: dailyMinutes.count,
        longestDayMinutes: longest
    )
}
