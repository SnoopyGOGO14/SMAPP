// ZoneStyle — colour and wording per zone. Semantic system colours only
// (dark mode and Increase Contrast come free); neutral uses the slate
// palette asset. App and UsageReport only (no SwiftUI in UsageMonitor).

import SwiftUI
import Core

public enum ZoneStyle {

    public static func color(for zone: Core.AppZone) -> Color {
        switch zone {
        case .green: return Color(.systemGreen)
        case .amber: return Color(.systemOrange)
        case .red: return Color(.systemRed)
        case .neutral: return PaletteColors.color(at: 7) // slate
        }
    }

    /// One word per zone; empty for neutral. Sentence case, British English.
    public static func word(for zone: Core.AppZone) -> String {
        switch zone {
        case .green: return "Comfortable"
        case .amber: return "Getting close"
        case .red: return "Over target"
        case .neutral: return ""
        }
    }

    /// The colour + word pairing for a usage figure, or nil when neutral.
    public static func pairing(usedMinutes: Double, targetMinutes: Int?, amberFraction: Double) -> (color: Color, word: String)? {
        let zone = Core.appZone(usedMinutes: usedMinutes, targetMinutes: targetMinutes, amberFraction: amberFraction)
        guard zone != .neutral else { return nil }
        return (color(for: zone), word(for: zone))
    }
}
