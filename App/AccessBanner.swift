// AccessBanner — one line and one button when Screen Time access is off
// or no apps are chosen. Shown on every tab (overlaid at the top).

import SwiftUI

struct AccessBanner: View {

    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(.footnote)
                .foregroundStyle(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(actionTitle, action: action)
                .font(.footnote.weight(.semibold))
                .buttonStyle(.primaryAction)
                .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 16))
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
    }
}
