// AppDetailCardView — the report-drawn part of App detail: today card,
// period card, two stats. Back/title/switch/period control are main-app
// chrome.

import SwiftUI
import Core

public struct AppDetailCardView: View {
    let configuration: AppDetailConfiguration
    let amberFraction: Double
    var initialFocus: Int? = nil

    public init(configuration: AppDetailConfiguration, amberFraction: Double = 0.75, initialFocus: Int? = nil) {
        self.configuration = configuration
        self.amberFraction = amberFraction
        self.initialFocus = initialFocus
    }

    public var body: some View {
        VStack(spacing: 12) {
            HeroCardView(
                configuration: HomeTotalConfiguration(
                    usedMinutes: configuration.todayMinutes,
                    allowanceMinutes: configuration.todayTargetMinutes
                ),
                captionSuffix: " today",
                amberFraction: amberFraction
            )

            PeriodCardView(
                configuration: configuration,
                amberFraction: amberFraction,
                initialFocus: initialFocus
            )

            HStack(spacing: 12) {
                StatCard(label: "Daily average", value: DurationFormat.short(minutes: configuration.dailyAverageMinutes))
                StatCard(label: "Within target", value: "\(configuration.daysWithinTarget) of \(configuration.daysCounted) days")
            }
            .frame(height: 64)
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("SecondaryText"))
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 18))
    }
}
