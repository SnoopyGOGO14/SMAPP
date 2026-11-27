// PeriodTabsControl — the one period control (W12): the Summary's
// text tabs with the elapsed underline, shared by Summary and App
// detail. Same wording everywhere: Daily, Weekly, Monthly. The active
// tab's underline fills with the share of the period that has elapsed
// (PeriodProgress, UK calendar).

import SwiftUI
import Core

public struct PeriodTabsControl: View {

    public struct Tab: Equatable {
        public let title: String
        /// 0…1 of the period elapsed; nil hides the underline.
        public let elapsed: Double?

        public init(title: String, elapsed: Double?) {
            self.title = title
            self.elapsed = elapsed
        }
    }

    public let tabs: [Tab]
    public let selected: String
    public let onSelect: (String) -> Void

    public init(tabs: [Tab], selected: String, onSelect: @escaping (String) -> Void) {
        self.tabs = tabs
        self.selected = selected
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabs, id: \.title) { tab in
                    tabView(tab)
                }
            }
            Rectangle()
                .fill(Color("Divider"))
                .frame(height: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Period")
    }

    private func tabView(_ tab: Tab) -> some View {
        let isActive = tab.title == selected
        return VStack(spacing: 4) {
            Button {
                onSelect(tab.title)
            } label: {
                Text(tab.title)
                    .font(.caption.weight(isActive ? .bold : .semibold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(isActive ? Color("PrimaryText") : Color("MutedText"))
                    // S5: a 12 pt gutter between tab texts (6 + 6) so
                    // they never touch at accessibility sizes, while the
                    // underline row beneath stays continuous; one line,
                    // scaled down to fit — never wrapped or hyphenated.
                    .padding(.horizontal, 6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isActive ? [.isSelected] : [])

            // The filled part shows how much of the period has elapsed.
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color("BarTrack"))
                    if isActive {
                        Rectangle()
                            .fill(Color("Rank1"))
                            .frame(width: proxy.size.width * min(max(tab.elapsed ?? 0, 0), 1))
                    }
                }
            }
            .frame(height: 2)
            .padding(.horizontal, 8)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
    }
}
