// Configurations — plain, DeviceActivity-free structs handed to the
// SharedUI views. The report scenes build them from real activity data;
// demo mode (Block L) builds the same structs from sample figures.

import Foundation

public struct HomeTotalConfiguration: Equatable {
    /// Minutes used over the interval the app filtered (today, or the week
    /// so far in weekly mode).
    public let usedMinutes: Double
    /// Allowance for the hero bar; nil hides the marker and status line.
    public let allowanceMinutes: Int?

    public init(usedMinutes: Double, allowanceMinutes: Int?) {
        self.usedMinutes = usedMinutes
        self.allowanceMinutes = allowanceMinutes
    }
}

public struct AppRowConfiguration: Equatable {
    public let usedMinutes: Double
    /// This app's daily target; nil = neutral bar without a marker.
    public let targetMinutes: Int?
    /// Reference for a neutral bar's scale (fixed 60-minute reference in v1).
    public let largestAppMinutes: Double

    public init(usedMinutes: Double, targetMinutes: Int?, largestAppMinutes: Double) {
        self.usedMinutes = usedMinutes
        self.targetMinutes = targetMinutes
        self.largestAppMinutes = largestAppMinutes
    }
}


public struct AppDetailConfiguration: Equatable {
    public struct DayValue: Equatable, Identifiable {
        /// Unique per period (0-based index) — labels repeat (T/T, S/S).
        public let id: Int
        /// Visible axis label; empty for unlabelled positions in month view.
        public let label: String
        /// The focused line's name (W7): "Sun" for weeks, "12 Nov" for
        /// months; falls back to `label` when empty.
        public let title: String
        public let minutes: Double
        public let isToday: Bool

        public init(id: Int, label: String, minutes: Double, isToday: Bool, title: String = "") {
            self.id = id
            self.label = label
            self.title = title
            self.minutes = minutes
            self.isToday = isToday
        }
    }

    /// Today's card.
    public let todayMinutes: Double
    public let todayTargetMinutes: Int?
    /// Period card.
    public let periodTotalSeconds: Int
    public let periodDays: [DayValue]
    public let periodTargetMinutes: Int?
    public let dailyAverageMinutes: Int
    public let daysWithinTarget: Int
    public let daysCounted: Int

    public init(
        todayMinutes: Double,
        todayTargetMinutes: Int?,
        periodTotalSeconds: Int,
        periodDays: [DayValue],
        periodTargetMinutes: Int?,
        dailyAverageMinutes: Int,
        daysWithinTarget: Int,
        daysCounted: Int
    ) {
        self.todayMinutes = todayMinutes
        self.todayTargetMinutes = todayTargetMinutes
        self.periodTotalSeconds = periodTotalSeconds
        self.periodDays = periodDays
        self.periodTargetMinutes = periodTargetMinutes
        self.dailyAverageMinutes = dailyAverageMinutes
        self.daysWithinTarget = daysWithinTarget
        self.daysCounted = daysCounted
    }
}

