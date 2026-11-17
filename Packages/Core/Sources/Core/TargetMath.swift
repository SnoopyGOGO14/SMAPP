// TargetMath — daily/weekly target conversion and the allowance each view
// compares usage against. Spec table: "Which allowance each view compares
// against". targetMinutes is expressed in the given mode's units: daily
// minutes in daily mode (e.g. 180), weekly minutes in weekly mode (e.g. 1260).

import Foundation

public enum TargetMode: String, CaseIterable, Codable {
    case daily
    case weekly
}

/// The views from the spec's allowance table.
public enum AllowanceView: String, CaseIterable, Codable {
    case todayRing
    case hourlyBars
    case dailyBars
    case weeklyBars
    case monthly
    case weeklyAverageLine
}

public enum TargetMath {

    /// Daily minutes → weekly minutes (× 7). Spec: switching to weekly
    /// multiplies the current figure by 7.
    public static func toWeekly(fromDailyMinutes dailyMinutes: Int) -> Int {
        return max(0, dailyMinutes * 7)
    }

    /// Weekly minutes → daily minutes (÷ 7, rounded to nearest).
    public static func toDaily(fromWeeklyMinutes weeklyMinutes: Int) -> Int {
        return max(0, Int((Double(weeklyMinutes) / 7.0).rounded()))
    }

    /// The allowance (minutes) a view compares usage against, per the spec table.
    public static func allowanceMinutes(
        view: AllowanceView,
        mode: TargetMode,
        targetMinutes: Int
    ) -> Int {
        switch (view, mode) {
        case (.todayRing, .daily):
            return targetMinutes
        case (.todayRing, .weekly):
            return targetMinutes
        case (.hourlyBars, .daily):
            return targetMinutes
        case (.hourlyBars, .weekly):
            return weeklyPerDay(targetMinutes)
        case (.dailyBars, .daily):
            return targetMinutes
        case (.dailyBars, .weekly):
            return weeklyPerDay(targetMinutes)
        case (.weeklyBars, .daily):
            return targetMinutes * 7
        case (.weeklyBars, .weekly):
            return targetMinutes
        case (.monthly, .daily):
            return targetMinutes
        case (.monthly, .weekly):
            return targetMinutes
        case (.weeklyAverageLine, .daily):
            return targetMinutes
        case (.weeklyAverageLine, .weekly):
            return weeklyPerDay(targetMinutes)
        }
    }

    /// Average minutes per day so far this week (R8).
    public static func weekToDateAverage(totalMinutes: Int, daysElapsed: Int) -> Double {
        guard daysElapsed > 0 else { return 0 }
        return Double(totalMinutes) / Double(daysElapsed)
    }

    private static func weeklyPerDay(_ weeklyMinutes: Int) -> Int {
        return Int((Double(weeklyMinutes) / 7.0).rounded())
    }
}
