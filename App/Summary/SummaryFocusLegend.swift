// SummaryFocusLegend — the host-driven focus legend and the Monthly
// history caption (Part 2), split out of SummaryScreen to keep files
// under 250 lines.

import SwiftUI
import FamilyControls
import ManagedSettings
import Core

extension SummaryScreen {

    /// Part 2: Monthly's caption when the diagnostics-reported history
    /// is shorter than the month.
    var showsHistoryCaption: Bool {
        guard FeatureSwitches.monthlyRequiresHistory else { return false }
        if case .monthly = period {
            let days = appState.settings.historyDays
            return days > 0 && days < 35
        }
        return false
    }

    /// Part 2: host-driven focus — the legend the person taps (names
    /// drawn host-side, so Label(token) blanks are also covered).
    var focusLegend: some View {
        let enabled = appState.orderedTokens.filter { appState.isEnabled($0) }
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(enabled.prefix(8).enumerated()), id: \.element) { index, token in
                    Button {
                        hostFocus = hostFocus == index ? nil : index
                    } label: {
                        Label(token)
                            .font(.caption.weight(hostFocus == index ? .bold : .medium))
                            .foregroundStyle(hostFocus == index ? Color("PrimaryText") : Color("SecondaryText"))
                            .padding(.horizontal, 12)
                            .frame(height: 32)
                            .background(
                                hostFocus == index ? AnyShapeStyle(Color("PrimaryText")) : AnyShapeStyle(Color("Card")),
                                in: Capsule()
                            )
                            .overlay(Capsule().stroke(hostFocus == index ? Color.clear : Color("Divider"), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(hostFocus == index ? [.isSelected] : [])
                }
            }
        }
    }
}
