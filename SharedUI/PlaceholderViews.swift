// PlaceholderViews — same-size placeholders while a report loads, and the
// plain "No time recorded" empty state (spec visual rules).

import SwiftUI

public struct ReportPlaceholder: View {
    let height: CGFloat

    public init(height: CGFloat) {
        self.height = height
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color("Card"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("Divider"), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            )
            .frame(height: height)
            .accessibilityLabel("Loading")
    }
}

public struct NoTimeRecordedView: View {
    public init() {}

    public var body: some View {
        Text("No time recorded")
            .font(.subheadline)
            .foregroundStyle(Color("SecondaryText"))
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
            .accessibilityElement(children: .combine)
    }
}
