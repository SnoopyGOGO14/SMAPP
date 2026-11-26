// RankColors + card style — the Summary skin (08 plan §5). Rank
// colours are by usage rank (largest = Rank1), never by app identity.
// Cards: hairline 8 pt radius in dark, soft-shadow 12 pt in light.

import SwiftUI
import Core

/// B7: every Summary-page ASSUMED default is one switch here, so a
/// changed owner answer is a one-line change. The alternatives are
/// listed in REVIEW.md ("Summary-page decisions").
public enum SummaryDefaults {
    /// X2 (decision changed, round 4): colour by the user's row order
    /// (position) — an app keeps one colour on every screen and in
    /// every period. Rank colouring made TikTok change colour per tab.
    public static let colourByRank = false
    /// Yearly tab hidden until a device proves a year of history.
    public static let showYearly = false
    /// The mock's footer strip above the tab bar (default: off).
    public static let showFooterStrip = false
    /// Rank palette: `rank` = Rank1–8 (default); `donut` = the Home
    /// donut's categorical set.
    public static let palette: Palette = .rank
    /// Space Grotesk for display figures (needs the font bundled) vs
    /// the system font (default).
    public static let useSpaceGrotesk = false

    public enum Palette {
        case rank
        case donut
    }
}

/// Display fonts for the Summary page. System by default; Space
/// Grotesk when `SummaryDefaults.useSpaceGrotesk` is flipped (font
/// file must then be bundled — open licence; `Font.custom` falls back
/// to system if it is missing, so flipping early is safe).
public enum SummaryFonts {
    public static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        if SummaryDefaults.useSpaceGrotesk {
            return Font.custom("Space Grotesk", size: size).weight(weight)
        }
        return .system(size: size, weight: weight)
    }
}

public enum RankColors {
    /// Colour for a row-order position (X2's default, Y1's fix): the
    /// app keeps this colour on every screen and in every period.
    public static func color(position: Int) -> Color {
        let index = Core.Palette.index(for: position)
        switch SummaryDefaults.palette {
        case .rank:
            return Color("Rank\(index + 1)")
        case .donut:
            return PaletteColors.color(at: index)
        }
    }

    /// Colour for a card/segment: by rank or by row order (position),
    /// in the chosen palette set.
    public static func color(_ rank: Int, position: Int = 0) -> Color {
        if !SummaryDefaults.colourByRank {
            return color(position: position)
        }
        let index = Core.Palette.index(for: rank)
        switch SummaryDefaults.palette {
        case .rank:
            return Color("Rank\(index + 1)")
        case .donut:
            return PaletteColors.color(at: index)
        }
    }
}

public struct SummaryCardModifier: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Divider"), lineWidth: 1))
        } else {
            content
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
}

extension View {
    /// The Summary card look for the current appearance.
    public func summaryCard() -> some View {
        modifier(SummaryCardModifier())
    }
}

/// The focus treatment shared by donut segments and cards (plan §6):
/// focused keeps full opacity, gains emphasis, siblings drop to 22%.
public struct FocusItemModifier: ViewModifier {

    let focused: Bool
    let anyFocused: Bool
    /// Extra emphasis scale for the focused item; 1 for cards.
    var emphasis: CGFloat = 1.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        let dimmed = anyFocused && !focused
        let duration = reduceMotion ? 0.15 : 0.3
        return content
            .scaleEffect(focused && !reduceMotion ? emphasis : 1.0)
            .opacity(dimmed ? 0.22 : 1.0)
            .overlay(
                Group {
                    if focused {
                        RoundedRectangle(cornerRadius: colorScheme == .dark ? 8 : 12)
                            .stroke(Color("Focus"), lineWidth: 1.5)
                            .shadow(color: Color("Focus").opacity(reduceMotion ? 0 : 0.35), radius: 6)
                    }
                }
            )
            .animation(.easeInOut(duration: duration), value: focused)
            .animation(.easeInOut(duration: duration), value: anyFocused)
    }
}

extension View {
    public func focusItem(focused: Bool, anyFocused: Bool, emphasis: CGFloat = 1.0) -> some View {
        modifier(FocusItemModifier(focused: focused, anyFocused: anyFocused, emphasis: emphasis))
    }
}
