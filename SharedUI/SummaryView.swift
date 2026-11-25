// AppShareCard + SummaryView — the Summary page's cards and their
// composition with the donut (08 plan §3/§6). One shared focus
// selection joins donut and cards. Cards focus; they do not navigate.

import SwiftUI
import UIKit
import FamilyControls
import ManagedSettings
import Core

struct AppShareCard: View {

    let item: SummaryItem
    @Binding var focusedRank: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 10) {
                    Circle()
                        .fill(RankColors.color(item.rank, position: item.position))
                        .frame(width: 10, height: 10)
                    name
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("PrimaryText"))
                }
                Spacer()
                HStack(spacing: 12) {
                    Text(String(format: "%.1f%%", item.sharePercent))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Color("MutedText"))
                    Text(Core.HoursFormat.hours(minutes: item.minutes))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("PrimaryText"))
                        .frame(minWidth: 64, alignment: .trailing)
                }
            }

            // Hairline bar filled to the app's share in its colour.
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color("BarTrack"))
                    Rectangle()
                        .fill(RankColors.color(item.rank, position: item.position))
                        .frame(width: proxy.size.width * min(item.sharePercent / 100, 1))
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 12))
        .focusItem(focused: focusedRank == item.rank, anyFocused: focusedRank != nil)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeInOut(duration: 0.3)) {
                focusedRank = Core.FocusState.next(current: focusedRank, tapped: item.rank)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(nameText), \(Core.HoursFormat.hours(minutes: item.minutes)), \(Int(item.sharePercent.rounded())) percent")
    }

    @ViewBuilder private var name: some View {
        if let token = item.token {
            Label(token)
                .foregroundStyle(Color("PrimaryText"))
        } else {
            Text(item.demoName)
        }
    }

    private var nameText: String {
        return item.demoName.isEmpty ? "App" : item.demoName
    }
}

/// The full Summary content: donut + cards, one focus selection.
public struct SummaryView: View {

    let configuration: SummaryConfiguration
    var initialFocus: Int? = nil

    @State private var focusedRank: Int?

    public init(configuration: SummaryConfiguration, initialFocus: Int? = nil) {
        self.configuration = configuration
        self.initialFocus = initialFocus
    }

    public var body: some View {
        VStack(spacing: 16) {
            RankedDonutView(
                configuration: configuration,
                focusedRank: $focusedRank,
                initialFocus: initialFocus
            )
            ForEach(configuration.items) { item in
                AppShareCard(item: item, focusedRank: $focusedRank)
            }
            footerStrip
        }
    }

    /// B7: the mock's footer strip, off by default (one switch).
    @ViewBuilder
    private var footerStrip: some View {
        if SummaryDefaults.showFooterStrip {
            HStack {
                Text("Social Monitoring Stats")
                    .font(.caption2.weight(.medium))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(Color("MutedText"))
                Spacer()
            }
            .padding(.top, 8)
            .accessibilityHidden(true)
        }
    }
}
