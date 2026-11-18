// AppUsageRow — the host row: icon and name from Label(token), the report
// drawing time and thin bar, and the NavigationLink to App detail. The
// embedded report has hit testing off so the whole row is tappable.

import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

struct AppUsageRow: View {

    let token: ApplicationToken
    var dimmed: Bool = false

    var body: some View {
        NavigationLink(value: token) {
            HStack(spacing: 14) {
                Label(token)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("PrimaryText"))
                    .labelStyle(.titleAndIcon)
                    .frame(minWidth: 96, alignment: .leading)

                DeviceActivityReport(
                    .appRow,
                    filter: Filters.appRow(token: token)
                )
                .allowsHitTesting(false)
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .opacity(dimmed ? 0.45 : 1)
        }
        .buttonStyle(HomeRowStyle())
    }
}

/// Home rows: a gold Focus border while pressed (08 plan §6).
struct HomeRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("Focus"), lineWidth: configuration.isPressed ? 1.5 : 0)
                    .opacity(configuration.isPressed ? 1 : 0)
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
