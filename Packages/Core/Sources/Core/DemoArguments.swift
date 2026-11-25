// DemoArguments — pure parsing of demo launch arguments (B3): one
// place decides which -screen/-state/-period/-focus/-sheet/-card
// values are legal, so a typo in the capture manifest cannot silently
// fall back to a default screen. An invalid value is reported, not
// swallowed: DemoMarker appends it to the screen marker and the
// self-checking capture workflow records the mismatch. Compiled into
// every configuration (no #if DEBUG: Xcode's DEBUG propagation into
// SwiftPM products should not be load-bearing); release builds never
// call it — DemoMode's accessors are the debug gate.

import Foundation

public struct DemoArguments: Equatable {

    public let isEnabled: Bool
    public let screen: String?
    public let state: String?
    public let period: String?
    public let focus: Int?
    public let sheet: String?
    /// 1…4 for onboarding cards.
    public let card: Int?
    /// Flags that carried values outside the legal sets.
    public let invalid: [String]

    /// The legal values. DemoMode.swift's enums must carry the same
    /// cases; `tools/preflight.sh` section 6 cross-checks the two.
    public static let screens = ["home", "summary", "detail", "target", "onboarding", "settings"]
    public static let states = ["default", "over", "comfortable", "paused", "noapps", "notarget", "noaccess"]
    public static let periods = ["today", "week", "month", "daily", "weekly", "monthly"]
    public static let sheets = ["target"]

    /// Parses `-demo -screen home -state over -period weekly -focus 1
    /// -sheet target -card 2` style arguments. Unknown flags are
    /// ignored; known flags with invalid values land in `invalid`.
    public static func parse(_ arguments: [String]) -> DemoArguments {
        var screen: String?
        var state: String?
        var period: String?
        var focus: Int?
        var sheet: String?
        var card: Int?
        var invalid: [String] = []
        var enabled = false

        var index = 0
        while index < arguments.count {
            let flag = arguments[index]
            let value = index + 1 < arguments.count ? arguments[index + 1] : nil
            switch flag {
            case "-demo":
                enabled = true
                index += 1
            case "-screen":
                if let value, Self.screens.contains(value) {
                    screen = value
                } else if let value {
                    invalid.append("screen=\(value)")
                }
                index += 2
            case "-state":
                if let value, Self.states.contains(value) {
                    state = value
                } else if let value {
                    invalid.append("state=\(value)")
                }
                index += 2
            case "-period":
                if let value, Self.periods.contains(value) {
                    period = value
                } else if let value {
                    invalid.append("period=\(value)")
                }
                index += 2
            case "-focus":
                if let value, let n = Int(value), (1...8).contains(n) {
                    focus = n
                } else if let value {
                    invalid.append("focus=\(value)")
                }
                index += 2
            case "-sheet":
                if let value, Self.sheets.contains(value) {
                    sheet = value
                } else if let value {
                    invalid.append("sheet=\(value)")
                }
                index += 2
            case "-card":
                if let value, let n = Int(value), (1...4).contains(n) {
                    card = n
                } else if let value {
                    invalid.append("card=\(value)")
                }
                index += 2
            default:
                index += 1
            }
        }

        return DemoArguments(
            isEnabled: enabled,
            screen: screen,
            state: state,
            period: period,
            focus: focus,
            sheet: sheet,
            card: card,
            invalid: invalid
        )
    }
}
