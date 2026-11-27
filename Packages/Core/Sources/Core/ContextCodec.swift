// ContextCodec — the App Group fallback channel (Part 2): if the
// report extension cannot read shared settings, the host encodes the
// target (and amber point) into the report *context name* — for
// example "homeTotal.t180.a75" — and the extension decodes it. Targets
// live on a 15-minute grid from 15 m to 8 h; amber on a 5% grid.
// Pure Core — tested.

import Foundation

public enum ContextCodec {

    public static let minimumTargetMinutes = 15
    public static let maximumTargetMinutes = 8 * 60
    public static let targetStep = 15
    public static let amberStep = 5

    /// Every legal target step: 15, 30, … 480.
    public static var targetSteps: [Int] {
        return stride(from: minimumTargetMinutes, through: maximumTargetMinutes, by: targetStep).map { $0 }
    }

    /// "homeTotal.t180.a75", or nil when a value is off its grid.
    /// Targets are zero-padded to three digits (t015 … t480) so the
    /// encoded names sort and match the extension's registrations.
    public static func encode(targetMinutes: Int, amberPercent: Int) -> String? {
        guard targetMinutes >= minimumTargetMinutes,
              targetMinutes <= maximumTargetMinutes,
              targetMinutes % targetStep == 0,
              amberPercent % amberStep == 0 else { return nil }
        return String(format: "homeTotal.t%03d.a%d", targetMinutes, amberPercent)
    }

    /// The values a context name carries, or nil when it carries none.
    public static func decode(_ name: String) -> (targetMinutes: Int, amberPercent: Int)? {
        let parts = name.split(separator: ".")
        guard parts.count >= 3,
              parts[0] == "homeTotal",
              parts[1].hasPrefix("t"),
              parts[2].hasPrefix("a"),
              let target = Int(parts[1].dropFirst()),
              let amber = Int(parts[2].dropFirst()) else { return nil }
        guard targetSteps.contains(target), amber % amberStep == 0 else { return nil }
        return (target, amber)
    }

    /// The context names the extension must register for the fallback:
    /// every target step at the default amber point (75%).
    public static var fallbackContextNames: [String] {
        return targetSteps.map { "homeTotal.t\($0).a75" }
    }

    /// "summary.f0" … "summary.f7" — the host-driven focus contexts.
    public static func summaryFocusContext(focus: Int) -> String? {
        guard (0...7).contains(focus) else { return nil }
        return "summary.f\(focus)"
    }

    public static func summaryFocus(from context: String) -> Int? {
        guard context.hasPrefix("summary.f") else { return nil }
        guard let focus = Int(context.dropFirst("summary.f".count)) else { return nil }
        return (0...7).contains(focus) ? focus : nil
    }
}
