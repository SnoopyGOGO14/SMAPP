// PeriodCardView — App detail's period card: the days-hours-minutes-
// seconds total on one line, one bar per day in zone colours (unique
// identity per day — F3), one dashed target rule across the chart, and
// today's bar outlined. Custom bars instead of Swift Charts so the
// outline and the single rule are exact.

import SwiftUI
import UIKit
import Core

public struct PeriodCardView: View {
    let configuration: AppDetailConfiguration
    let amberFraction: Double
    /// Day index pre-focused (demo `-focus n`).
    var initialFocus: Int? = nil

    @ScaledMetric(relativeTo: .title) private var totalSize: CGFloat = 30
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var focusedDayID: Int?
    @State private var appliedInitialFocus = false

    public init(configuration: AppDetailConfiguration, amberFraction: Double = 0.75, initialFocus: Int? = nil) {
        self.configuration = configuration
        self.amberFraction = amberFraction
        self.initialFocus = initialFocus
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Linked text: the total, or the focused day ("Thu · 1h 01m").
            Text(linkedText)
                .font(.system(size: totalSize, weight: .bold))
                .foregroundStyle(Color("PrimaryText"))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: reduceMotion ? 0.15 : 0.3), value: focusedDayID)

            bars

            labels
        }
        .padding(20)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
        .onAppear {
            if !appliedInitialFocus {
                appliedInitialFocus = true
                if let initialFocus, initialFocus < configuration.periodDays.count {
                    focusedDayID = initialFocus
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var linkedText: String {
        if let id = focusedDayID,
           let day = configuration.periodDays.first(where: { $0.id == id }) {
            // W7: the short weekday name ("Sun"), or "12 Nov" on month —
            // single initials were ambiguous (two S days, two T days).
            let name = day.title.isEmpty ? (day.label.isEmpty ? "Day" : day.label) : day.title
            return "\(name) · \(DurationFormat.short(minutes: Int(day.minutes.rounded())))"
        }
        return DurationParts(seconds: configuration.periodTotalSeconds).line
    }

    private var bars: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let width = proxy.size.width
            let count = max(configuration.periodDays.count, 1)
            let slot = width / Double(count)
            let barWidth = min(slot * 0.44, 22)

            // V3: one scale maximum; every bar rises from the baseline.
            let maximum = Core.ChartGeometry.maximum(
                targetMinutes: configuration.periodTargetMinutes,
                tallestMinutes: configuration.periodDays.map(\.minutes).max() ?? 0
            )
            let ruleFraction = Core.ChartGeometry.ruleFraction(
                targetMinutes: configuration.periodTargetMinutes,
                maximum: maximum
            )

            ZStack(alignment: .bottom) {
                // Bars share the baseline; tapping one focuses it (08 §6).
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(configuration.periodDays) { day in
                        let fraction = Core.ChartGeometry.heightFraction(
                            minutes: day.minutes,
                            maximum: maximum
                        )
                        let focused = focusedDayID == day.id
                        RoundedRectangle(cornerRadius: 7)
                            .fill(barColor(for: day))
                            .frame(width: barWidth, height: max(fraction * height, day.minutes > 0 ? 3 : 0))
                            .overlay(
                                Group {
                                    if focused {
                                        RoundedRectangle(cornerRadius: 7)
                                            .stroke(Color("Focus"), lineWidth: 2)
                                    } else if day.isToday {
                                        RoundedRectangle(cornerRadius: 7)
                                            .stroke(Color("PrimaryText"), lineWidth: 2)
                                    }
                                }
                            )
                            .opacity(focusedDayID == nil || focused ? 1 : 0.22)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.easeInOut(duration: reduceMotion ? 0.15 : 0.3)) {
                                    focusedDayID = Core.FocusState.next(current: focusedDayID, tapped: day.id)
                                }
                            }
                    }
                }

                if let ruleFraction {
                    // One dashed rule across the whole chart, at the
                    // target's height above the shared baseline.
                    Path { path in
                        let y = height - ruleFraction * height
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(
                        Color("PrimaryText"),
                        style: StrokeStyle(lineWidth: 2, dash: [5, 4])
                    )
                    .opacity(0.8)
                }
            }
        }
        .frame(height: 104)
    }

    private var labels: some View {
        HStack(spacing: 0) {
            ForEach(configuration.periodDays) { day in
                Text(day.label)
                    .font(.caption2)
                    .fontWeight(day.isToday ? .bold : .regular)
                    .foregroundStyle(day.isToday ? Color("PrimaryText") : Color("SecondaryText"))
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
            }
        }
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
