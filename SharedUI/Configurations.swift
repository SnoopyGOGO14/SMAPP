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

public struct AppTimeConfiguration: Equatable {
    public let usedMinutes: Double

    public init(usedMinutes: Double) {
        self.usedMinutes = usedMinutes
    }
}

public struct AppDetailConfiguration: Equatable {
    public struct DayValue: Equatable {
        /// Weekday initial, e.g. "T".
        public let label: String
        public let minutes: Double
        public let isToday: Bool

        public init(label: String, minutes: Double, isToday: Bool) {
            self.label = label
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

public struct AllAppsConfiguration: Equatable {
    public struct Segment: Equatable {
        public let paletteIndex: Int
        public let minutes: Double

        public init(paletteIndex: Int, minutes: Double) {
            self.paletteIndex = paletteIndex
            self.minutes = minutes
        }
    }

    public let totalMinutes: Double
    /// Overall allowance for the "of 3h" caption; nil hides it.
    public let allowanceMinutes: Int?
    public let segments: [Segment]

    public init(totalMinutes: Double, allowanceMinutes: Int?, segments: [Segment]) {
        self.totalMinutes = totalMinutes
        self.allowanceMinutes = allowanceMinutes
        self.segments = segments
    }
}
