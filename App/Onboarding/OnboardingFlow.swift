// OnboardingFlow — four cards (V8 layout): the ring mark centred in the
// upper third, centred title and body, one full-width primary button
// above the page dots. Card 4 is a 2 × 2 grid of target presets with
// "Choose my own" beneath.

import SwiftUI
import FamilyControls
import Core
import SharedUI

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
                card(
                    title: "Social Time Monitor",
                    body: "See how long you really spend on social apps, set one target, and get a gentle nudge as you approach it."
                ) {
                    Button("Continue") { withAnimation { page = 1 } }
                        .buttonStyle(.primaryAction)
                }
                .tag(0)

                card(
                    title: "What the app sees",
                    body: "It sees the time each app is on screen.\n\nIt never sees your messages, photos or content, and nothing leaves your phone."
                ) {
                    Button(requesting ? "Waiting…" : "Allow Screen Time access") {
                        requesting = true
                        Task {
                            await appState.requestAuthorization()
                            requesting = false
                            withAnimation { page = 2 }
                        }
                    }
                    .buttonStyle(.primaryAction)
                    .disabled(requesting)
                }
                .tag(1)

                card(
                    title: "Choose your apps",
                    body: "Tip: tick the Social category and YouTube — most people are done in two taps."
                ) {
                    Button(appState.orderedTokens.isEmpty ? "Choose apps" : "Continue") {
                        if appState.orderedTokens.isEmpty {
                            showPicker = true
                        } else {
                            withAnimation { page = 3 }
                        }
                    }
                    .buttonStyle(.primaryAction)
                }
                .tag(2)

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

    private func card<Content: View>(title: String, body text: String, @ViewBuilder button: () -> Content) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            RingMarkView(size: 96)
                .padding(.bottom, 28)
            Text(title)
                .font(.title.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryText"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer(minLength: 0)
            button()
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Card 4 (V8): 2 × 2 preset tiles with "a day" beneath, then
    /// "Choose my own". Every path completes onboarding; a custom figure
    /// can be set straight after on the Target tab.
    private var targetCard: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            RingMarkView(size: 96)
                .padding(.bottom, 28)
            Text("Set a target")
                .font(.title.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
                .padding(.bottom, 24)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Array([60, 120, 180, 240].enumerated()), id: \.offset) { index, minutes in
                    Button {
                        appState.setTargetMinutes(minutes)
                        appState.completeOnboarding()
                    } label: {
                        VStack(spacing: 2) {
                            Text(["1h", "2h", "3h", "4h"][index])
                                .font(.title2.weight(.bold))
                            Text("a day")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 84)
                        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)

            Button("Choose my own") {
                appState.setTargetMinutes(180)
                appState.completeOnboarding()
            }
            .buttonStyle(.primaryAction)
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pickerBinding: Binding<FamilyActivitySelection> {
        @Bindable var state = appState
        return $state.selection
    }
}
