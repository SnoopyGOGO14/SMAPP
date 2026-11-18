// AlertLedger — decides whether a checkpoint alert should be sent, so a
// monitoring restart never repeats an alert already delivered for the
// same interval (F4). Rule: a higher percentage in the same interval
// sends; an equal or lower one does not; a new interval always sends.

import Foundation

public struct AlertRecord: Codable, Equatable {
    /// The interval the alert belonged to (day start, or week start).
    public let intervalStart: Date
    /// The checkpoint percentage that was alerted.
    public let percent: Int

    public init(intervalStart: Date, percent: Int) {
        self.intervalStart = intervalStart
        self.percent = percent
    }
}

public enum AlertLedger {

    public static func shouldSend(last: AlertRecord?, interval: Date, percent: Int) -> Bool {
        guard let last else { return true }
        if last.intervalStart != interval { return true }
        return percent > last.percent
    }
}
