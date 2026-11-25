// AppRowViews — the report-drawn part of a row. The host row (icon, name,
// tap) lives in the main app; these draw the time and thin bar (Home rows)
// or the time alone (All-apps rows).

import SwiftUI
import Core

/// Home row: bold time on the right, thin bar underneath.
public struct AppRowReportView: View {
    let configuration: AppRowConfiguration
    let amberFraction: Double
    /// X6: the bar's leading inset — the width of the tile/icon column,
    /// so the bar starts at the app-name column. 46 matches the demo
    /// tile (36 + 10 spacing); live rows' Label icon column is close.
    var barLeadingInset: CGFloat = 46

    public init(configuration: AppRowConfiguration, amberFraction: Double = 0.75, barLeadingInset: CGFloat = 46) {
        self.configuration = configuration
        self.amberFraction = amberFraction
        self.barLeadingInset = barLeadingInset
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                // X4: one truncation rule — 3,520 s reads "58m" here and
                // on the Home rows, never "59m".
                Text(DurationFormat.fromSeconds(configuration.usedMinutes * 60))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("PrimaryText"))
            }
            .frame(minHeight: 24, alignment: .center)
            BarView(
                geometry: .perApp(
                    usedMinutes: configuration.usedMinutes,
                    targetMinutes: configuration.targetMinutes,
                    largestAppMinutes: configuration.largestAppMinutes
                ),
                fill: barColor,
                height: 6
            )
            // X6: the bar starts at the text column (clear of the tile)
            // and ends at the row's trailing edge.
            .padding(.leading, barLeadingInset)
            .frame(height: 16)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityText)
    }

    private var barColor: Color {
        let zone = Core.appZone(
            usedMinutes: configuration.usedMinutes,
            targetMinutes: configuration.targetMinutes,
            amberFraction: amberFraction
        )
        return ZoneStyle.color(for: zone)
    }

    private var rowAccessibilityText: String {
        let minutes = Int(configuration.usedMinutes)
        let zone = Core.appZone(usedMinutes: configuration.usedMinutes, targetMinutes: configuration.targetMinutes, amberFraction: amberFraction)
        let word = ZoneStyle.word(for: zone)
        if word.isEmpty {
            return "\(minutes) minutes"
        }
        return "\(minutes) minutes, \(word.lowercased())"
    }
}

