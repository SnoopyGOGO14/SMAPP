// Palette — the eight categorical donut colours from DESIGN-NOTES.md
// (chosen to avoid green, orange and red). An app's colour is
// palette[index(for: its position in orderedTokens)].

import Foundation

public enum Palette {
    /// Names of the colour assets in the app's asset catalogue.
    public static let names: [String] = [
        "DonutTeal",    // #26C6C6
        "DonutPink",    // #F0569A
        "DonutBlue",    // #4C8DFF
        "DonutViolet",  // #A47BFF
        "DonutSilver",  // #C9D2E0
        "DonutSky",     // #7FD4FF
        "DonutOrchid",  // #D873F5
        "DonutSlate"    // #8B95A7
    ]

    public static let count = 8

    /// Wraps at 8 and tolerates negative positions.
    public static func index(for position: Int) -> Int {
        return ((position % count) + count) % count
    }
}
