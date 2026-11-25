// SummaryText — the Summary donut's centre as pure logic (B3): the
// three lines for the unfocused ring (period label, total, top app)
// and for focus (that app's name, time, share), one function, tested
// for every period and focus on and off. Names arrive as display
// strings: demo mode passes the sample names; live mode passes "App"
// (a token is not readable as text — the sandbox's rule, cards render
// Label(token)).

import Foundation

public enum SummaryText {

    public struct Lines: Equatable {
        /// Small-caps top line: the period label, or the focused app.
        public let label: String
        /// Middle line: the total, or the focused app's time.
        public let value: String
        /// Bottom line: top app + its time, or the focused share.
        public let third: String
    }

    /// The centre's three lines. `focused` wins when present.
    public static func centre(
        periodLabel: String,
        totalMinutes: Double,
        top: (name: String, minutes: Double)?,
        focused: (name: String, minutes: Double, sharePercent: Double)?
    ) -> Lines {
        if let focused {
            return Lines(
                label: focused.name,
                value: HoursFormat.hours(minutes: focused.minutes),
                third: shareLine(focused.sharePercent)
            )
        }
        let third: String
        if let top {
            third = "\(top.name.uppercased()) \(HoursFormat.hours(minutes: top.minutes).uppercased())"
        } else {
            third = ""
        }
        return Lines(
            label: periodLabel,
            value: HoursFormat.total(minutes: totalMinutes),
            third: third
        )
    }

    /// "37.2% OF TOTAL" — one formatting rule, one decimal place.
    public static func shareLine(_ sharePercent: Double) -> String {
        return String(format: "%.1f%% OF TOTAL", sharePercent)
    }
}
