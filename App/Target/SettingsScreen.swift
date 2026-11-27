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
                // S1: the navigation title carries the name — no
                // second in-page heading above it.
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

                    // S2: labelled on the left, value in PrimaryText —
                    // the last system-blue control is gone.
                    HStack {
                        Text("Week starts on")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Picker("Week starts on", selection: $weekStartIndex) {
                            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                                Text(day).tag(index + 1)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color("PrimaryText"))
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

                    // F6: monitoring health, visible with a retry.
                    HStack {
                        Text("Monitoring")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        if let error = appState.settings.lastMonitoringError {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Not running")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.red)
                                Button("Try again") {
                                    MonitoringScheduler.shared.restart()
                                }
                                .buttonStyle(.primaryActionCompact)
                            }
                        } else {
                            Text("Running")
                                .font(.subheadline)
                                .foregroundStyle(Color.green)
                        }
                    }
                    .padding(16)

                    Divider().overlay(Color("Divider"))

                    #if DEBUG
                    if FeatureSwitches.alertsKillSwitch {
                        Divider().overlay(Color("Divider"))
                        Text("Alerts paused: under test")
                            .font(.footnote)
                            .foregroundStyle(Color("SecondaryText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    }
                    #endif

                    Button("Add or remove apps") { showPicker = true }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("PrimaryText"))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.horizontal, 16)
                        .onChange(of: appState.selection) { _, _ in
                            appState.syncFromSelection()
                        }
                }
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))

                PerAppTargetsCard()

                #if DEBUG
                NavigationLink {
                    DiagnosticsScreen()
                } label: {
                    HStack {
                        Text("Diagnostics (Gate A checklist)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("PrimaryText"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(Color("SecondaryText"))
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
                #endif

                Text("Privacy")
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
                // S4: plain words, no jargon.
                Text("Everything stays on this phone. No account, no server, no analytics. Your usage figures never leave it.")
                    .font(.footnote)
                    .foregroundStyle(Color("SecondaryText"))
            }
            .padding(.horizontal, 20)
        }
        .background(Color("Ground"))
        .navigationTitle("Settings")
        .familyActivityPicker(isPresented: $showPicker, selection: $state.selection)
        .onAppear {
            #if DEBUG
            // Z4: Settings never wrote its marker — every settings
            // capture read the previous screen's stale file.
            DemoMarker.mark("settings")
            #endif
            amberPercent = appState.settings.amberFraction * 100
            weekStartIndex = appState.settings.weekStartsOn
        }
    }

}
