// RootTabs — Apps, Summary, Target. Each tab gets its own NavigationStack;
// rows navigate to App detail by token value.

import SwiftUI
import UIKit
import FamilyControls

struct RootTabs: View {

    @State private var selection: Int
    private let initialTab: Int

    init(initialTab: Int = 0) {
        self.initialTab = initialTab
        _selection = State(initialValue: initialTab)
        // W11: selected tab = PrimaryText, unselected = SecondaryText —
        // no system blue anywhere (the design's rule).
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "SecondaryText")
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
            // W3: chart.pie (iOS 13+); "chart.donut" does not exist and
            // rendered blank.
            .tabItem { Label("Summary", systemImage: "chart.pie") }
            .tag(1)

            NavigationStack {
                TargetScreen()
            }
            .tabItem { Label("Target", systemImage: "flag") }
            .tag(2)
        }
        // W11: the selected tab's icon and label take the tint.
        .tint(Color("PrimaryText"))
        .onReceive(NotificationCenter.default.publisher(for: NotificationManager.openAppsTab)) { _ in
            selection = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: AppState.openTargetTab)) { _ in
            selection = 2
        }
    }
}
