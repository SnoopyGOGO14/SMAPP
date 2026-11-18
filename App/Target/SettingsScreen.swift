// SettingsScreen — amber point, week start, Screen Time access status,
// edit app selection, per-app targets list, privacy statement.

import SwiftUI
import FamilyControls
import Core

struct SettingsScreen: View {

    @Environment(AppState.self) private var appState
    @State private var amberPercent: Double = 75
    @State private var weekStartIndex: Int = 1
    @State private var showPicker = false

    private let weekDays = Calendar.current.weekdaySymbols

    var body: some View {
        @Bindable var state = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color("PrimaryText"))
                    .padding(.top, 24)

                VStack(spacing: 0) {
                    Stepper(
                        "Amber from \(Int(amberPercent))%",
                        value: $amberPercent,
                        in: 50...95,
                        step: 5
                    )
                    .padding(16)
                    .onChange(of: amberPercent) { _, newValue in
                        appState.settings.amberFraction = newValue / 100
                    }

                    Divider().overlay(Color("Divider"))

                    Picker("Week starts on", selection: $weekStartIndex) {
                        ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                            Text(day).tag(index + 1)
                        }
                    }
                    .padding(16)
                    .onChange(of: weekStartIndex) { _, newValue in
                        appState.settings.weekStartsOn = newValue
                    }
                }
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))

                VStack(spacing: 0) {
                    HStack {
                        Text("Screen Time access")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(appState.hasAccess ? "Allowed" : "Off")
                            .font(.subheadline)
                            .foregroundStyle(appState.hasAccess ? Color.green : Color.red)
                    }
                    .padding(16)

                    Divider().overlay(Color("Divider"))

                    Button("Add or remove apps") { showPicker = true }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.horizontal, 16)
                        .onChange(of: appState.selection) { _, _ in
                            appState.syncFromSelection()
                        }
                }
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))

                appTargetsCard

                Text("Privacy")
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
                Text("Everything stays on this phone. No account, no server, no analytics. Usage figures are drawn by a sealed Apple extension and never leave it.")
                    .font(.footnote)
                    .foregroundStyle(Color("SecondaryText"))
            }
            .padding(.horizontal, 20)
        }
        .background(Color("Ground"))
        .navigationTitle("Settings")
        .familyActivityPicker(isPresented: $showPicker, selection: $state.selection)
        .onAppear {
            amberPercent = appState.settings.amberFraction * 100
            weekStartIndex = appState.settings.weekStartsOn
        }
    }

    private var appTargetsCard: some View {
        VStack(spacing: 0) {
            if appState.appTargets.isEmpty {
                Text("No per-app targets")
                    .font(.footnote)
                    .foregroundStyle(Color("SecondaryText"))
                    .padding(16)
            } else {
                ForEach(Array(appState.appTargets.enumerated()), id: \.offset) { _, target in
                    HStack {
                        Label(target.token)
                            .font(.subheadline)
                            .foregroundStyle(Color("PrimaryText"))
                        Spacer()
                        Text(DurationFormat.short(minutes: target.minutes))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color("PrimaryText"))
                    }
                    .padding(16)
                    Divider().overlay(Color("Divider"))
                }
            }
        }
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
    }
}
