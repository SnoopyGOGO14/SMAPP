// AppRowViews — the report-drawn part of a row. The host row (icon, name,
// tap) lives in the main app; these draw the time and thin bar (Home rows)
// or the time alone (All-apps rows).

import SwiftUI
import Core

/// Home row: bold time on the right, thin bar underneath.
public struct AppRowReportView: View {
    let configuration: AppRowConfiguration
    let amberFraction: Double

    public init(configuration: AppRowConfiguration, amberFraction: Double = 0.75) {
        self.configuration = configuration
        self.amberFraction = amberFraction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Spacer()
                Text(DurationFormat.short(minutes: Int(configuration.usedMinutes.rounded())))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("PrimaryText"))
            }
            BarView(
                geometry: .perApp(
                    usedMinutes: configuration.usedMinutes,
                    targetMinutes: configuration.targetMinutes,
                    largestAppMinutes: configuration.largestAppMinutes
                ),
                fill: barColor,
                height: 6
            )
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
        let minutes = Int(configuration.usedMinutes.rounded())
        let zone = Core.appZone(usedMinutes: configuration.usedMinutes, targetMinutes: configuration.targetMinutes, amberFraction: amberFraction)
        let word = ZoneStyle.word(for: zone)
        if word.isEmpty {
            return "\(minutes) minutes"
        }
        return "\(minutes) minutes, \(word.lowercased())"
    }
}

/// All-apps row: bold time only.
public struct AppTimeView: View {
    let configuration: AppTimeConfiguration

    public init(configuration: AppTimeConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        Text(DurationFormat.short(minutes: Int(configuration.usedMinutes.rounded())))
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color("PrimaryText"))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityLabel("\(Int(configuration.usedMinutes.rounded())) minutes")
    }
}
