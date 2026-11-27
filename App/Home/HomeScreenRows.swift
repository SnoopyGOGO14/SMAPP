// HomeScreenRows — the single-report rows fallback and the demo rows,
// split out of HomeScreen to keep files under 250 lines.

import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

extension HomeScreen {


    #if DEBUG
func demoRow(_ app: DemoData.DemoApp) -> some View {
    // W13/W14: the report (time + bar) spans the full row width;
    // the tile+name label sits over its first line. Demo rows are
    // in descending usage order, so the row index is the rank —
    // the tile colour matches the Summary's rank colours.
    AppRowShell {
        HStack(spacing: 10) {
            // Y1: the tile takes the app's row-order colour — the
            // same one its Summary dot uses.
            DemoTile(position: demoRowIndex(of: app), initials: app.initials)
            Text(app.name)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color("PrimaryText"))
}
} report: {
    AppRowReportView(configuration: DemoData.appRow(app))
}
}

func demoRowIndex(of app: DemoData.DemoApp) -> Int {
    return DemoData.apps.firstIndex(where: { $0.name == app.name }) ?? 0
}
#endif
}
