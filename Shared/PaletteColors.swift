// PaletteColors — the eight categorical donut colours from DESIGN-NOTES.md
// as named asset colours (light and dark variants in the asset catalogue).
// Compiled into the app and UsageReport.

import SwiftUI
import Core

public enum PaletteColors {

    public static func color(at index: Int) -> Color {
        let name = Core.Palette.names[Core.Palette.index(for: index)]
        return Color(name)
    }
}
