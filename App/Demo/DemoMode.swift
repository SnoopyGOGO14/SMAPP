// DemoMode — debug builds only. `-demo` replaces every embedded report
// with the matching SharedUI view fed from DemoData; `-screen <name>`
// opens one screen directly; `-card 1…4` picks the onboarding card;
// `-state` and `-period` choose the situation shown (Part 2);
// `-sheet target` opens the per-app target sheet. DemoMarker lets the
// capture workflow verify the screen it photographed, including the
// state and period suffixes. Release builds contain none of this.

import Foundation

enum DemoMode {

    enum DemoState: String {
        case `default`
        case over
        case comfortable
        case paused
        case noapps
        case notarget
        case noaccess
    }

    enum DemoPeriod: String {
        case today
        case week
        case month
    }

    static var isEnabled: Bool {
        #if DEBUG
        return CommandLine.arguments.contains("-demo")
        #else
        return false
        #endif
    }

    static var screen: String? {
        #if DEBUG
        return value(after: "-screen")
        #else
        return nil
        #endif
    }

    /// 1…4 for onboarding cards; nil otherwise.
    static var card: Int? {
        #if DEBUG
        return value(after: "-card").flatMap(Int.init)
        #else
        return nil
        #endif
    }

    static var state: DemoState {
        #if DEBUG
        return value(after: "-state").flatMap(DemoState.init(rawValue:)) ?? .default
        #else
        return .default
        #endif
    }

    static var period: DemoPeriod? {
        #if DEBUG
        return value(after: "-period").flatMap(DemoPeriod.init(rawValue:))
        #else
        return nil
        #endif
    }

    /// "target" opens the per-app target sheet over App detail.
    static var sheet: String? {
        #if DEBUG
        return value(after: "-sheet")
        #else
        return nil
        #endif
    }

    /// Rank pre-focused on Summary or App detail (e.g. `-focus 1`).
    static var focus: Int? {
        #if DEBUG
        return value(after: "-focus").flatMap(Int.init)
        #else
        return nil
        #endif
    }

    /// The marker a screen writes: "<screen>[/state][/period][/focus][/sheet]".
    static func markerFor(_ screen: String) -> String {
        var parts = [screen]
        if state != .default {
            parts.append(state.rawValue)
        }
        if let period {
            parts.append(period.rawValue)
        }
        if let focus {
            parts.append("focus\(focus)")
        }
        if sheet != nil {
            parts.append("sheet")
        }
        return parts.joined(separator: "/")
    }

    private static func value(after flag: String) -> String? {
        let arguments = CommandLine.arguments
        guard let index = arguments.firstIndex(of: flag),
              index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }
}

#if DEBUG
/// Writes the active screen's name into the app container so the
/// screenshot workflow can prove which screen it captured (F1/F2).
enum DemoMarker {
    static func mark(_ screen: String) {
        guard DemoMode.isEnabled else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("demo-screen.txt")
        try? DemoMode.markerFor(screen).write(to: url, atomically: true, encoding: .utf8)
    }
}
#endif
