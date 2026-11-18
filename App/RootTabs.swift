// RootTabs — Apps, Stats, Target. Each tab gets its own NavigationStack;
// rows navigate to App detail by token value.

import SwiftUI
import FamilyControls

struct RootTabs: View {

    var body: some View {
        TabView {
            NavigationStack {
                HomeScreen()
            }
            .tabItem { Label("Apps", systemImage: "square.grid.2x2") }

            NavigationStack {
                AllAppsScreen()
            }
            .tabItem { Label("Stats", systemImage: "circle.circle") }

            NavigationStack {
                TargetScreen()
            }
            .tabItem { Label("Target", systemImage: "flag") }
        }
        .tint(Color("PrimaryText"))
    }
}
