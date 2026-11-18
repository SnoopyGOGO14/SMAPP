// PeriodCardView — App detail's period card: the days-hours-minutes-
// seconds total on one line, one bar per day in zone colours, dashed
// target rule, today outlined, day initials beneath.

import SwiftUI
import Charts
import Core

public struct PeriodCardView: View {
    let configuration: AppDetailConfiguration
    let amberFraction: Double

    @ScaledMetric(relativeTo: .title) private var totalSize: CGFloat = 30

    public init(configuration: AppDetailConfiguration, amberFraction: Double = 0.75) {
        self.configuration = configuration
        self.amberFraction = amberFraction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(DurationParts(seconds: configuration.periodTotalSeconds).line)
                .font(.system(size: totalSize, weight: .bold))
                .foregroundStyle(Color("PrimaryText"))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Chart(configuration.periodDays, id: \.label) { day in
                BarMark(
                    x: .value("Day", day.label),
                    y: .value("Minutes", day.minutes)
                )
                .foregroundStyle(barColor(for: day))
                .cornerRadius(4)

                if let target = configuration.periodTargetMinutes {
                    RuleMark(y: .value("Target", target))
                        .foregroundStyle(Color("PrimaryText"))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 4]))
                        .opacity(0.8)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 104)

            HStack(spacing: 0) {
                ForEach(configuration.periodDays, id: \.label) { day in
                    Text(day.label)
                        .font(.caption2)
                        .fontWeight(day.isToday ? .bold : .regular)
                        .foregroundStyle(day.isToday ? Color("PrimaryText") : Color("SecondaryText"))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private func barColor(for day: AppDetailConfiguration.DayValue) -> Color {
        let zone = Core.appZone(
            usedMinutes: day.minutes,
            targetMinutes: configuration.periodTargetMinutes,
            amberFraction: amberFraction
        )
        return ZoneStyle.color(for: zone)
    }

    private var accessibilityText: String {
        let total = DurationFormat.short(minutes: Int((Double(configuration.periodTotalSeconds) / 60).rounded()))
        return "Total \(total); \(configuration.daysWithinTarget) of \(configuration.daysCounted) days within target"
    }
}
