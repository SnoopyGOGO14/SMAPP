// RankColors + card style — the Summary skin (08 plan §5). Rank
// colours are by usage rank (largest = Rank1), never by app identity.
// Cards: hairline 8 pt radius in dark, soft-shadow 12 pt in light.

import SwiftUI
import Core

public enum RankColors {
    public static func color(_ rank: Int) -> Color {
        return Color("Rank\(Core.Palette.index(for: rank) + 1)")
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
