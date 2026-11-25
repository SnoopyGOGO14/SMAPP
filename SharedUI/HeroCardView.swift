// HeroCardView — the top card on Home and App detail: hero figure, "of Xh",
// bar with marker, one status line. Exactly the elements in the mock-ups.

import SwiftUI
import Core

public struct HeroCardView: View {
    let configuration: HomeTotalConfiguration
    /// "of 3h" on Home, "of 1h today" on App detail.
    let captionSuffix: String
    let amberFraction: Double

    @ScaledMetric(relativeTo: .largeTitle) private var heroSize: CGFloat = 54

    public init(configuration: HomeTotalConfiguration, captionSuffix: String = "", amberFraction: Double = 0.75) {
        self.configuration = configuration
        self.captionSuffix = captionSuffix
        self.amberFraction = amberFraction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(DurationFormat.fromSeconds(configuration.usedMinutes * 60))
                    .font(.system(size: heroSize, weight: .bold))
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                if let allowance = configuration.allowanceMinutes {
                    Text("of \(DurationFormat.short(minutes: allowance))\(captionSuffix)")
                        .font(.subheadline)
                        .foregroundStyle(Color("SecondaryText"))
                }
            }

            if let allowance = configuration.allowanceMinutes {
                BarView(
                    geometry: .overall(
                        usedMinutes: configuration.usedMinutes,
                        targetMinutes: allowance
                    ),
                    fill: fill,
                    height: 14
                )
                .frame(height: 24)

                // V4: zone word (zone colour) and remainder as separate
                // values — no string splitting, one separator.
                statusPartsView(allowance: allowance)
            } else {
                // No overall target: plain bar, no marker, no status line.
                BarView(
                    geometry: .perApp(
                        usedMinutes: configuration.usedMinutes,
                        targetMinutes: nil,
                        largestAppMinutes: max(configuration.usedMinutes, 60)
                    ),
                    fill: ZoneStyle.color(for: .neutral),
                    height: 14
                )
                .frame(height: 24)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var fill: Color {
        guard let allowance = configuration.allowanceMinutes else {
            return ZoneStyle.color(for: .neutral)
        }
        let zone = Core.zone(
            usedMinutes: configuration.usedMinutes,
            allowanceMinutes: Double(allowance),
            amberFraction: amberFraction
        )
        return ZoneStyle.color(for: zone == .green ? .green : (zone == .amber ? .amber : .red))
    }

    private func statusPartsView(allowance: Int) -> some View {
        let parts = Core.statusParts(
            usedMinutes: configuration.usedMinutes,
            targetMinutes: allowance,
            amberFraction: amberFraction
        )
        return HStack(spacing: 6) {
            Text(parts.word)
                .foregroundStyle(fill)
            Text("· " + parts.remainder)
                .foregroundStyle(Color("SecondaryText"))
        }
        .font(.footnote.weight(.semibold))
    }

    private var accessibilityText: String {
        let used = DurationFormat.fromSeconds(configuration.usedMinutes * 60)
        guard let allowance = configuration.allowanceMinutes else {
            return "\(used) today"
        }
        let zone = Core.zone(usedMinutes: configuration.usedMinutes, allowanceMinutes: Double(allowance), amberFraction: amberFraction)
        return "\(used) of \(DurationFormat.short(minutes: allowance)), \(ZoneStyle.word(for: zone == .green ? .green : (zone == .amber ? .amber : .red)).lowercased())"
    }
}
