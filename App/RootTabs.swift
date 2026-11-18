// RootTabs — Apps, Stats, Target. Each tab gets its own NavigationStack;
// rows navigate to App detail by token value.

import SwiftUI
import FamilyControls

struct RootTabs: View {

    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeScreen()
            }
            .tabItem { Label("Apps", systemImage: "square.grid.2x2") }
            .tag(0)

            NavigationStack {
                AllAppsScreen()
            }
            .tabItem { Label("Stats", systemImage: "circle.circle") }
            .tag(1)

            NavigationStack {
                TargetScreen()
            }
            .tabItem { Label("Target", systemImage: "flag") }
            .tag(2)
        }
        .tint(Color("PrimaryText"))
        .onReceive(NotificationCenter.default.publisher(for: NotificationManager.openAppsTab)) { _ in
            selection = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: AppState.openTargetTab)) { _ in
            selection = 2
        }
    }
}
