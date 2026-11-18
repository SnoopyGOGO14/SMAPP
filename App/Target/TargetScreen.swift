// TargetScreen — overall target (daily or weekly, presets, custom
// stepper), master Monitoring switch, alerts and recaps switches, and a
// link to Settings.

import SwiftUI
import UserNotifications
import Core

struct TargetScreen: View {

    @Environment(AppState.self) private var appState
    @State private var customMinutes: Int = 180

    private static let dailyPresets = [60, 120, 180, 240]
    private static let dailyPresetTitles = ["1h", "2h", "3h", "4h"]

    var body: some View {
        @Bindable var state = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Target")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color("PrimaryText"))
                    .padding(.top, 24)

                Picker("Mode", selection: modeBinding) {
                    Text("Daily").tag(Core.TargetMode.daily)
                    Text("Weekly").tag(Core.TargetMode.weekly)
                }
                .pickerStyle(.segmented)
                .frame(height: 40)

                targetCard

                VStack(spacing: 0) {
                    Toggle(isOn: $state.monitoringEnabled) {
                        Text("Monitoring")
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(.green)
                    .padding(16)
                    .onChange(of: appState.monitoringEnabled) { _, on in
                        appState.settings.monitoringEnabled = on
                    }

                    Divider().overlay(Color("Divider"))

                    Toggle(isOn: $state.alertsEnabled) {
                        Text("Zone alerts")
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(.green)
                    .padding(16)
                    .onChange(of: appState.alertsEnabled) { _, on in
                        if on { NotificationManager.shared.requestPermissionIfNeeded() }
                        appState.settings.alertsEnabled = on
                    }

                    Divider().overlay(Color("Divider"))

                    Toggle(isOn: $state.recapsEnabled) {
                        Text("Recaps")
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(.green)
                    .padding(16)
                    .onChange(of: appState.recapsEnabled) { _, on in
                        if on { NotificationManager.shared.requestPermissionIfNeeded() }
                        appState.settings.recapsEnabled = on
                    }

                    Divider().overlay(Color("Divider"))

                    NavigationLink {
                        SettingsScreen()
                    } label: {
                        HStack {
                            Text("Settings")
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
                }
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 20)
        }
        .background(Color("Ground"))
        .navigationBarHidden(true)
        .onAppear {
            customMinutes = appState.targetMinutes ?? 180
        }
        #if DEBUG
        .onAppear { DemoMarker.mark("target") }
        #endif
    }

    #if DEBUG
    private var modeBinding: Binding<Core.TargetMode> {
        if DemoMode.isEnabled {
            return .constant(.daily)
        }
        return Binding(
            get: { appState.targetMode },
            set: { appState.setTargetMode($0) }
        )
    }
    #else
    private var modeBinding: Binding<Core.TargetMode> {
        Binding(
            get: { appState.targetMode },
            set: { appState.setTargetMode($0) }
        )
    }
    #endif

    private var targetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ForEach(Array(Self.dailyPresets.enumerated()), id: \.offset) { index, preset in
                    // V7: selected preset filled, others outlined; demo
                    // mode shows the demo state (Daily, 3h).
                    let isSelected: Bool
                    #if DEBUG
                    if DemoMode.isEnabled {
                        isSelected = preset == 180
                    } else {
                        isSelected = appState.targetMinutes == presetValue(preset)
                    }
                    #else
                    isSelected = appState.targetMinutes == presetValue(preset)
                    #endif
                    Button(Self.dailyPresetTitles[index]) {
                        let weekly = appState.targetMode == .weekly
                        let value = weekly ? Core.TargetMath.toWeekly(fromDailyMinutes: preset) : preset
                        appState.setTargetMinutes(value)
                        customMinutes = value
                    }
                    .buttonStyle(.preset(isSelected))
                }
            }

            Stepper(stepperLabel, value: $customMinutes, in: 15...5040, step: 15)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("PrimaryText"))
                .onChange(of: customMinutes) { _, newValue in
                    appState.setTargetMinutes(newValue)
                }

            Text(zonePreviewLine)
                .font(.footnote)
                .foregroundStyle(Color("SecondaryText"))
        }
        .padding(22)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
    }

    private var stepperLabel: String {
        #if DEBUG
        // V7: demo shows the demo figure ("3h a day"), not "No target".
        if DemoMode.isEnabled {
            return "3h a day"
        }
        #endif
        return appState.targetMinutes.map { DurationFormat.short(minutes: $0) } ?? "No target"
    }

    private func presetValue(_ dailyMinutes: Int) -> Int? {
        if appState.targetMode == .weekly {
            return Core.TargetMath.toWeekly(fromDailyMinutes: dailyMinutes)
        }
        return dailyMinutes
    }

    private var zonePreviewLine: String {
        guard let target = appState.targetMinutes else { return "No target set" }
        let amberAt = Int((Double(target) * appState.settings.amberFraction).rounded())
        return "Amber from \(DurationFormat.short(minutes: amberAt)) of \(DurationFormat.short(minutes: target))"
    }
}
