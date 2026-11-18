// OnboardingFlow — four plain cards: what the app does; what the app sees
// and never sees (then the system prompt); pick apps; choose a target.

import SwiftUI
import FamilyControls
import Core

struct OnboardingFlow: View {

    @Environment(AppState.self) private var appState
    @State private var page: Int
    @State private var showPicker = false
    @State private var requesting = false

    init(startingCard: Int = 0) {
        _page = State(initialValue: min(max(startingCard, 0), 3))
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                introCard.tag(0)
                permissionCard.tag(1)
                pickerCard.tag(2)
                targetCard.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .background(Color("Ground").ignoresSafeArea())
        .familyActivityPicker(isPresented: $showPicker, selection: pickerBinding)
        .onChange(of: appState.selection) { _, _ in
            appState.syncFromSelection()
        }
        #if DEBUG
        .onAppear { DemoMarker.mark("onboarding") }
        #endif
    }

    private var pickerBinding: Binding<FamilyActivitySelection> {
        @Bindable var state = appState
        return $state.selection
    }

    private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
            content()
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var introCard: some View {
        card("Social Time Monitor") {
            Text("See how long you really spend on social apps, set one target, and get a gentle nudge as you approach it.")
                .font(.body)
                .foregroundStyle(Color("SecondaryText"))
            Button("Continue") { withAnimation { page = 1 } }
                .font(.headline)
                .buttonStyle(.borderedProminent)
        }
    }

    private var permissionCard: some View {
        card("What the app sees") {
            VStack(alignment: .leading, spacing: 12) {
                Text("It sees the time each app is on screen.")
                Text("It never sees your messages, photos or content, and nothing leaves your phone.")
            }
            .font(.body)
            .foregroundStyle(Color("SecondaryText"))

            Button(requesting ? "Waiting…" : "Allow Screen Time access") {
                requesting = true
                Task {
                    await appState.requestAuthorization()
                    requesting = false
                    withAnimation { page = 2 }
                }
            }
            .font(.headline)
            .buttonStyle(.borderedProminent)
            .disabled(requesting)
        }
    }

    private var pickerCard: some View {
        card("Choose your apps") {
            Text("Tip: tick the Social category and YouTube — most people are done in two taps.")
                .font(.body)
                .foregroundStyle(Color("SecondaryText"))
            Button(appState.orderedTokens.isEmpty ? "Choose apps" : "Continue") {
                if appState.orderedTokens.isEmpty {
                    showPicker = true
                } else {
                    withAnimation { page = 3 }
                }
            }
            .font(.headline)
            .buttonStyle(.borderedProminent)
        }
    }

    private var targetCard: some View {
        card("Set a target") {
            VStack(spacing: 8) {
                ForEach(Array([60, 120, 180, 240].enumerated()), id: \.offset) { index, minutes in
                    Button(["1 hour a day", "2 hours a day", "3 hours a day", "4 hours a day"][index]) {
                        appState.setTargetMinutes(minutes)
                        appState.completeOnboarding()
                    }
                    .font(.headline)
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}
