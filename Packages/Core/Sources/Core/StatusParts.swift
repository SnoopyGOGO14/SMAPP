// StatusParts — the status line as two values (zone word, remainder) so
// views never split a formatted string (V4: a split produced
// "Getting close · · 14m left").

import Foundation

public struct StatusParts: Equatable {
    /// "Comfortable" / "Getting close" / "Over target"; empty when neutral.
    public let word: String
    /// "14m left" / "by 7m"; empty when neutral.
    public let remainder: String

    public init(word: String, remainder: String) {
        self.word = word
        self.remainder = remainder
    }

    public var isEmpty: Bool {
        return word.isEmpty && remainder.isEmpty
    }
}

public func statusParts(
    usedMinutes: Double,
    targetMinutes: Int?,
    amberFraction: Double
) -> StatusParts {
    guard let target = targetMinutes, target > 0 else {
        return StatusParts(word: "", remainder: "")
    }
    let zone = Core.zone(
        usedMinutes: usedMinutes,
        allowanceMinutes: Double(target),
        amberFraction: amberFraction
    )
    switch zone {
    case .green:
        return StatusParts(
            word: "Comfortable",
            remainder: DurationFormat.left(minutes: Int((Double(target) - usedMinutes).rounded()))
        )
    case .amber:
        return StatusParts(
            word: "Getting close",
            remainder: DurationFormat.left(minutes: Int((Double(target) - usedMinutes).rounded()))
        )
    case .red:
        return StatusParts(
            word: "Over target",
            remainder: "by " + DurationFormat.short(minutes: Int((usedMinutes - Double(target)).rounded()))
        )
    }
}
