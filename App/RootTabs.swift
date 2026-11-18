// RootTabs — Apps, Stats, Target. Each tab gets its own NavigationStack;
// rows navigate to App detail by token value.

import SwiftUI
import FamilyControls

struct RootTabs: View {

    @State private var selection: Int
    private let initialTab: Int

    init(initialTab: Int = 0) {
        self.initialTab = initialTab
        _selection = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeScreen()
            }
            .tabItem { Label("Apps", systemImage: "square.grid.2x2") }
            .tag(0)

            NavigationStack {
                SummaryScreen()
            }
            .tabItem { Label("Summary", systemImage: "chart.donut") }
            .tag(1)

            NavigationStack {
                TargetScreen()
            }
            .tabItem { Label("Target", systemImage: "flag") }
            .tag(2)
        }
        // V2/V6: no global tint — primary buttons use PrimaryButtonStyle,
        // switches keep the system green.
        .onReceive(NotificationCenter.default.publisher(for: NotificationManager.openAppsTab)) { _ in
            selection = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: AppState.openTargetTab)) { _ in
            selection = 2
        }
    }
}
