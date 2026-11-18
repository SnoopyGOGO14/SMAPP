// PrimaryButtonStyle — one shared style for primary actions (V2):
// fill PrimaryText, label Ground, full width, 50 pt (44 compact),
// radius 16. No system blue anywhere.

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {

    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .footnote.weight(.semibold) : .headline)
            .foregroundStyle(Color("Ground"))
            .frame(maxWidth: .infinity)
            .frame(height: compact ? 34 : 50)
            .background(
                Color("PrimaryText"),
                in: RoundedRectangle(cornerRadius: compact ? 12 : 16)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primaryAction: PrimaryButtonStyle { PrimaryButtonStyle() }
    static var primaryActionCompact: PrimaryButtonStyle { PrimaryButtonStyle(compact: true) }
}

// PresetButtonStyle — selection tiles (V7): selected is filled with
// PrimaryText and a Ground label; unselected is outlined.

struct PresetButtonStyle: ButtonStyle {

    var selected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color(selected ? "Ground" : "PrimaryText"))
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(
                selected ? AnyShapeStyle(Color("PrimaryText")) : AnyShapeStyle(.clear),
                in: Capsule()
            )
            .overlay(
                Capsule().stroke(
                    selected ? Color.clear : Color("Divider"),
                    lineWidth: 1
                )
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == PresetButtonStyle {
    static func preset(_ selected: Bool) -> PresetButtonStyle {
        PresetButtonStyle(selected: selected)
    }
}
