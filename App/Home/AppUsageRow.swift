// AppUsageRow — a Home row. W13: the hairline bar runs under the name
// and time across the full row width, so the report (time + bar)
// spans the whole row and the host's label sits over its first line.
// Writes detailToken before the detail report appears.

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
            AppRowShell(dimmed: dimmed) {
                Label(token)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("PrimaryText"))
                    .labelStyle(.titleAndIcon)
            } report: {
                DeviceActivityReport(
                    .appRow,
                    filter: Filters.appRow(token: token)
                )
                .allowsHitTesting(false)
            }
        }
        .buttonStyle(HomeRowStyle())
    }
}

/// The row layout (W13): the report draws the time right-aligned on
/// the first line and the hairline bar beneath, both full row width;
/// the label overlays the first line's leading side. One report per
/// row is preserved (device check A9).
struct AppRowShell<Label: View, Report: View>: View {

    var dimmed: Bool = false
    private let label: Label
    private let report: Report

    init(
        dimmed: Bool = false,
        @ViewBuilder label: () -> Label,
        @ViewBuilder report: () -> Report
    ) {
        self.dimmed = dimmed
        self.label = label()
        self.report = report()
    }

    var body: some View {
        report
            .overlay(alignment: .topLeading) {
                label
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 88)
            }
            .padding(.horizontal, 16)
            .frame(height: 64, alignment: .center)
            .opacity(dimmed ? 0.45 : 1)
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
