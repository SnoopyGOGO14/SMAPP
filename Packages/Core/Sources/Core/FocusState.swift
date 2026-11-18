// FocusState — the pure reducer behind tap-to-focus (08 plan §8):
// tap an item to focus it, tap it again (or outside) to clear; a period
// change keeps focus only if the item is still present.

import Foundation

public enum FocusState {

    /// Tap an item (id >= 0) or outside (id = nil).
    public static func next(current: Int?, tapped: Int?) -> Int? {
        guard let tapped else { return nil }
        if current == tapped { return nil }
        return tapped
    }

    /// After the period changes: keep focus only if still present.
    public static func afterPeriodChange(current: Int?, present: [Int]) -> Int? {
        guard let current else { return nil }
        return present.contains(current) ? current : nil
    }
}
