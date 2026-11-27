// DemoMode — debug builds only. `-demo` replaces every embedded report
// with the matching SharedUI view fed from DemoData; `-screen <name>`
// opens one screen directly; `-card 1…4` picks the onboarding card;
// `-state` and `-period` choose the situation shown (Part 2);
// `-sheet target` opens the per-app target sheet. Parsing is
// `Core.DemoArguments` (B3): an invalid value is reported in the
// marker instead of silently falling back. DemoMarker lets the capture
// workflow verify the screen it photographed, including state, period
// and focus suffixes. Release builds contain none of this.

import Foundation
import Core

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
        // Summary-period aliases (08 plan §9): daily/weekly/monthly draw
        // from the same data sets so one enum serves both screens.
        case daily
        case weekly
        case monthly

        /// The data set this period draws from — a narrow 3-case enum,
        /// so DemoData's switches stay exhaustive (run 27).
        enum DataSet {
            case today
            case week
            case month
        }

        var dataSet: DataSet {
            switch self {
            case .today, .daily: return .today
            case .week, .weekly: return .week
            case .month, .monthly: return .month
            }
        }
    }

    #if DEBUG
    private static let parsed = Core.DemoArguments.parse(CommandLine.arguments)
    #endif

    static var isEnabled: Bool {
        #if DEBUG
        return parsed.isEnabled
        #else
        return false
        #endif
    }

    static var screen: String? {
        #if DEBUG
        return parsed.screen
        #else
        return nil
        #endif
    }

    /// 1…4 for onboarding cards; nil otherwise.
    static var card: Int? {
        #if DEBUG
        return parsed.card
        #else
        return nil
        #endif
    }

    static var state: DemoState {
        #if DEBUG
        return DemoState(rawValue: parsed.state ?? "default") ?? .default
        #else
        return .default
        #endif
    }

    static var period: DemoPeriod? {
        #if DEBUG
        return parsed.period.flatMap(DemoPeriod.init(rawValue:))
        #else
        return nil
        #endif
    }

    /// "target" opens the per-app target sheet over App detail.
    static var sheet: String? {
        #if DEBUG
        return parsed.sheet
        #else
        return nil
        #endif
    }

    /// Rank pre-focused on Summary or App detail (e.g. `-focus 1`).
    static var focus: Int? {
        #if DEBUG
        return parsed.focus
        #else
        return nil
        #endif
    }

    /// 0…6: the day pill pre-selected on Summary's Daily view (W1).
    static var day: Int? {
        #if DEBUG
        return parsed.day
        #else
        return nil
        #endif
    }

    /// "end" scrolls the screen to its bottom (X9's capture).
    static var scroll: String? {
        #if DEBUG
        return parsed.scroll
        #else
        return nil
        #endif
    }

    /// Part 2's fallback demonstration mode (single value).
    static var mode: String? {
        #if DEBUG
        return parsed.mode
        #else
        return nil
        #endif
    }

    /// Applies `-mode` to the feature switches (2.3), so each fallback
    /// can be captured later. Debug only.
    static func applyModeSwitches() {
        #if DEBUG
        guard isEnabled else { return }
        switch mode {
        case "appGroupFallback":
            FeatureSwitches.appGroupContextFallback = true
        case "singleRows":
            FeatureSwitches.homeRowsMode = .single
        case "hostFocus":
            FeatureSwitches.summaryFocusMode = .hostDriven
        case "shortHistory":
            FeatureSwitches.monthlyRequiresHistory = true
        case "alertsOff":
            FeatureSwitches.alertsKillSwitch = true
        default:
            break
        }
        #endif
    }

    /// The marker a screen writes: "<screen>[/state][/period][/day]
    /// [/focus][/sheet][/scroll]". X1: the chosen day is in the marker
    /// so the workflow proves the argument took effect; X9: the scroll
    /// position too. B3: invalid arguments surface as "/invalid(...)".
    static func markerFor(_ screen: String) -> String {
        var parts = [screen]
        if state != .default {
            parts.append(state.rawValue)
        }
        if let period {
            parts.append(period.rawValue)
        }
        if let day {
            parts.append("day\(day)")
        }
        if let focus {
            parts.append("focus\(focus)")
        }
        if sheet != nil {
            parts.append("sheet")
        }
        if let scroll {
            parts.append(scroll)
        }
        #if DEBUG
        if !parsed.invalid.isEmpty {
            parts.append("invalid(" + parsed.invalid.joined(separator: ",") + ")")
        }
        #endif
        return parts.joined(separator: "/")
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
