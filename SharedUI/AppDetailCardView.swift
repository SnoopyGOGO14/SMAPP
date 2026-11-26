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
                if configuration.hourly {
                    // Z3: the Daily view's stats — busiest hour, plus
                    // sessions only when the data supports them.
                    StatCard(
                        label: "Busiest hour",
                        value: Core.HourlyStats.hourLabel(configuration.busiestHour)
                    )
                    if configuration.sessionsOver15 > 0 {
                        StatCard(
                            label: "Sessions over 15 min",
                            value: "\(configuration.sessionsOver15)"
                        )
                    }
                } else {
                    StatCard(label: "Daily average", value: DurationFormat.short(minutes: configuration.dailyAverageMinutes))
                    StatCard(
                        label: "Within target",
                        // Z3: the plural is fixed ("1 day").
                        value: "\(configuration.daysWithinTarget) of \(configuration.daysCounted) \(configuration.daysCounted == 1 ? "day" : "days")"
                    )
                }
            }
            .frame(minHeight: 64)
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Z2: the label wraps to a second line at accessibility
            // sizes — never truncates ("Daily aver…").
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("SecondaryText"))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
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
