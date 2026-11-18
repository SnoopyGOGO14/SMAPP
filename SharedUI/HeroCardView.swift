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
                Text(DurationFormat.short(minutes: Int(configuration.usedMinutes.rounded())))
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

                // F8: zone word in the zone colour, remainder secondary.
                statusLineParts(allowance: allowance)
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

    private func statusLineParts(allowance: Int) -> some View {
        let zone = Core.zone(
            usedMinutes: configuration.usedMinutes,
            allowanceMinutes: Double(allowance),
            amberFraction: amberFraction
        )
        let word = ZoneStyle.word(for: appZone(from: zone))
        let full = Core.statusLine(
            usedMinutes: configuration.usedMinutes,
            targetMinutes: allowance,
            amberFraction: amberFraction
        )
        let remainder = full == word ? "" : full.replacingOccurrences(of: word + " ", with: "· ")
        return HStack(spacing: 4) {
            Text(word)
                .foregroundStyle(fill)
            Text(remainder)
                .foregroundStyle(Color("SecondaryText"))
        }
        .font(.footnote.weight(.semibold))
    }

    private func appZone(from zone: Core.Zone) -> Core.AppZone {
        switch zone {
        case .green: return .green
        case .amber: return .amber
        case .red: return .red
        }
    }

    private var accessibilityText: String {
        let used = DurationFormat.short(minutes: Int(configuration.usedMinutes.rounded()))
        guard let allowance = configuration.allowanceMinutes else {
            return "\(used) today"
        }
        let zone = Core.zone(usedMinutes: configuration.usedMinutes, allowanceMinutes: Double(allowance), amberFraction: amberFraction)
        return "\(used) of \(DurationFormat.short(minutes: allowance)), \(ZoneStyle.word(for: zone == .green ? .green : (zone == .amber ? .amber : .red)).lowercased())"
    }
}
