// RankedDonutView — the Summary ring (08 plan §3/§6): continuous, no
// gaps, thickness 12% of the diameter, segments clockwise from 12
// o'clock largest-first in rank colours. Focus: the focused segment
// thickens and gains the gold outline ring; siblings dim. Centre: three
// lines (small-caps label, total, top app in its rank colour) that
// cross-fade to the focused app. On first appearance the ring draws
// clockwise over 0.6 s (skipped under Reduce Motion).

import SwiftUI
import UIKit
import Core

struct RankedDonutView: View {

    let configuration: SummaryConfiguration
    @Binding var focusedRank: Int?
    /// Pre-applied focus (demo `-focus n`); nil otherwise.
    var initialFocus: Int? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .title) private var totalSize: CGFloat = 28
    @State private var sweepProgress: Double = 0
    @State private var appliedInitialFocus = false

    private let diameter: CGFloat = 224

    var body: some View {
        ZStack {
            donutShape(items: configuration.items)
            if let rank = focusedRank,
               item(at: rank) != nil,
               let segment = segmentFractions(items: configuration.items)[safe: rank] {
                focusOutline(start: segment.start, end: segment.end)
            }
            centre
        }
        .frame(width: diameter, height: diameter)
        .contentShape(Circle())
        .onTapGesture {
            // Tap empty space inside the ring clears focus.
            if focusedRank != nil {
                withAnimation(.easeInOut(duration: 0.3)) { focusedRank = nil }
            }
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.6)) { sweepProgress = 1 }
            } else {
                sweepProgress = 1
            }
            if !appliedInitialFocus {
                appliedInitialFocus = true
                if let initialFocus {
                    focusedRank = initialFocus
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(donutAccessibilityText)
    }

    // MARK: - Ring

    private func segmentFractions(items: [SummaryItem]) -> [(start: Double, end: Double)] {
        let segments = Core.donutSegments(
            apps: items.map { (position: $0.rank, seconds: $0.minutes * 60) }
        )
        return segments.map { ($0.startAngle, $0.endAngle) }
    }

    private func donutShape(items: [SummaryItem]) -> some View {
        let fractions = segmentFractions(items: items)
        let progress = sweepProgress
        return ZStack {
            // Hairline track.
            Circle()
                .stroke(Color("BarTrack"), lineWidth: diameter * 0.12)

            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if let fraction = fractions[safe: index] {
                    let start = (fraction.start + 90) / 360 // 0 at 12 o'clock
                    let end = (fraction.end + 90) / 360
                    let cap = min(end, start + max(end - start, 0) * 1 * progress)
                    DonutArc(
                        startFraction: start,
                        endFraction: cap,
                        color: RankColors.color(item.rank),
                        lineWidth: diameter * (focusedRank == item.rank ? 0.15 : 0.12)
                    )
                    .opacity(focusedRank == nil || focusedRank == item.rank ? 1 : 0.22)
                    .animation(.easeInOut(duration: reduceMotion ? 0.15 : 0.3), value: focusedRank)
                    .onTapGesture {
                        toggleFocus(rank: item.rank)
                    }
                }
            }
        }
    }

    private func focusOutline(start: Double, end: Double) -> some View {
        DonutArc(
            startFraction: (start + 90) / 360,
            endFraction: (end + 90) / 360,
            color: Color("Focus"),
            lineWidth: diameter * 0.17
        )
        .opacity(0.9)
        .shadow(color: Color("Focus").opacity(reduceMotion ? 0 : 0.6), radius: 5)
        .allowsHitTesting(false)
    }

    private func toggleFocus(rank: Int) {
        // Light haptic (plan §6); available on iOS in both host targets.
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: reduceMotion ? 0.15 : 0.3)) {
            focusedRank = Core.FocusState.next(current: focusedRank, tapped: rank)
        }
    }

    private func item(at rank: Int) -> SummaryItem? {
        return configuration.items.first { $0.rank == rank }
    }

    // MARK: - Centre

    private var centre: some View {
        VStack(spacing: 2) {
            Text(centreLabel)
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(focusedRank == nil ? Color("SecondaryText") : Color("Focus"))
            Text(centreValue)
                .font(.system(size: totalSize, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(Color("PrimaryText"))
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(centreThird)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.2)
                .textCase(.uppercase)
                .foregroundStyle(thirdColour)
        }
        .padding(.horizontal, 44)
        .animation(.easeInOut(duration: 0.3), value: focusedRank)
        .allowsHitTesting(false)
    }

    private var centreLabel: String {
        if let rank = focusedRank, let item = item(at: rank) {
            return displayName(item)
        }
        return configuration.periodLabel
    }

    private var centreValue: String {
        if let rank = focusedRank, let item = item(at: rank) {
            return Core.HoursFormat.hours(minutes: item.minutes)
        }
        return Core.HoursFormat.total(minutes: configuration.totalMinutes)
    }

    private var centreThird: String {
        if let rank = focusedRank, let item = item(at: rank) {
            return String(format: "%.1f%% OF TOTAL", item.sharePercent)
        }
        if let top = configuration.topItem {
            return "\(displayName(top).uppercased()) \(Core.HoursFormat.hours(minutes: top.minutes).uppercased())"
        }
        return ""
    }

    private var thirdColour: Color {
        if focusedRank != nil {
            return Color("Focus")
        }
        if let top = configuration.topItem {
            return RankColors.color(top.rank)
        }
        return Color("SecondaryText")
    }

    private func displayName(_ item: SummaryItem) -> String {
        return item.demoName.isEmpty ? "App" : item.demoName
    }

    private var donutAccessibilityText: String {
        let total = Core.HoursFormat.total(minutes: configuration.totalMinutes)
        return "Total \(total) across \(configuration.items.count) apps"
    }
}

/// One annulus arc of the ring, drawn clockwise from 12 o'clock.
struct DonutArc: View {
    let startFraction: Double
    let endFraction: Double
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        Circle()
            .trim(from: startFraction, to: max(endFraction, startFraction + 0.0001))
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
            .rotationEffect(.degrees(-90))
            .padding(lineWidth / 2)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
