// AppUsageRow — the host row: icon and name from Label(token), the report
// drawing time and thin bar, and the NavigationLink to App detail. The
// embedded report has hit testing off so the whole row is tappable.

import SwiftUI
import DeviceActivity
import FamilyControls
import Core
import SharedUI

struct AppUsageRow: View {

    enum Style {
        /// Home row: icon, name, time + thin bar report.
        case bar
        /// All-apps row: palette dot, name, time-only report.
        case timeOnly
    }

    let token: ApplicationToken
    var style: Style = .bar
    var dimmed: Bool = false

    var body: some View {
        NavigationLink(value: token) {
            HStack(spacing: 14) {
                leading
                report
            }
            .padding(.horizontal, 16)
            .frame(height: style == .bar ? 64 : 50)
            .opacity(dimmed ? 0.45 : 1)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var leading: some View {
        switch style {
        case .bar:
            Label(applicationToken: token)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("PrimaryText"))
                .labelStyle(.titleAndIcon)
                .frame(minWidth: 96, alignment: .leading)
        case .timeOnly:
            Circle()
                .fill(PaletteColors.color(at: SharedSettings().paletteIndex(for: token)))
                .frame(width: 14, height: 14)
        }
    }

    @ViewBuilder
    private var report: some View {
        switch style {
        case .bar:
            DeviceActivityReport(
                .appRow,
                filter: Filters.appRow(token: token)
            )
            .allowsHitTesting(false)
        case .timeOnly:
            DeviceActivityReport(
                .appTime,
                filter: Filters.appTime(token: token, period: SharedSettings().statsPeriod)
            )
            .allowsHitTesting(false)
        }
    }
}
