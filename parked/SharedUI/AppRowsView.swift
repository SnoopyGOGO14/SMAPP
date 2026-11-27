// AppRowsConfiguration + AppRowsView — Part 2's single-report Home
// rows fallback: one report draws every row at a fixed 64 pt, the host
// overlays transparent tap areas in the same order. Rows reuse the
// per-row view (time line + full-width bar).

import SwiftUI
import Core

public struct AppRowsConfiguration: Equatable {
    public let rows: [AppRowConfiguration]

    public init(rows: [AppRowConfiguration]) {
        self.rows = rows
    }
}

public struct AppRowsView: View {
    let configuration: AppRowsConfiguration
    let amberFraction: Double

    public init(configuration: AppRowsConfiguration, amberFraction: Double = 0.75) {
        self.configuration = configuration
        self.amberFraction = amberFraction
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(configuration.rows.enumerated()), id: \.offset) { _, row in
                AppRowReportView(configuration: row, amberFraction: amberFraction)
                    .frame(height: 64)
            }
        }
    }
}
