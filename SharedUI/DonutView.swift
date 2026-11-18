// DonutView — the All-apps donut: one SectorMark per platform sized by
// time, palette colour by orderedTokens index, total in the centre.
// No labels on the ring (per DESIGN-NOTES.md).

import SwiftUI
import Charts
import Core

public struct DonutView: View {
    let configuration: AllAppsConfiguration

    @ScaledMetric(relativeTo: .largeTitle) private var centreSize: CGFloat = 34

    public init(configuration: AllAppsConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        ZStack {
            if configuration.segments.isEmpty {
                Circle()
                    .stroke(Color("BarTrack"), lineWidth: 34)
            } else {
                Chart(configuration.segments, id: \.paletteIndex) { segment in
                    SectorMark(
                        angle: .value("Minutes", segment.minutes),
                        innerRadius: .ratio(0.72),
                        outerRadius: .inset(0),
                        angularInset: 1
                    )
                    .cornerRadius(4)
                    .foregroundStyle(PaletteColors.color(at: segment.paletteIndex))
                }
            }

            VStack(spacing: 2) {
                Text(DurationFormat.short(minutes: Int(configuration.totalMinutes.rounded())))
                    .font(.system(size: centreSize, weight: .bold))
                    .foregroundStyle(Color("PrimaryText"))
                if let allowance = configuration.allowanceMinutes {
                    Text("of \(DurationFormat.short(minutes: allowance))")
                        .font(.footnote)
                        .foregroundStyle(Color("SecondaryText"))
                }
            }
        }
        .frame(width: 250, height: 250)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(donutAccessibilityText)
    }

    private var donutAccessibilityText: String {
        let total = DurationFormat.short(minutes: Int(configuration.totalMinutes.rounded()))
        return "Total \(total) across \(configuration.segments.count) apps"
    }
}
