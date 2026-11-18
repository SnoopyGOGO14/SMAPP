// AppDetailScreen — back handled by the NavigationStack; icon and name,
// on/off switch, period switch, the appDetail report, target button.
// Writes detailToken and statsPeriod before the report appears.

import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

struct AppDetailScreen: View {

    @Environment(AppState.self) private var appState
    let token: ApplicationToken
    @State private var showTargetSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                periodSwitch

                DeviceActivityReport(
                    .appDetail,
                    filter: Filters.appDetail(token: token, period: appState.statsPeriod)
                )
                .frame(minHeight: 420)

                targetButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(Color("Ground"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { toolbarTitle }
            // V5: the on/off switch belongs on the title line, not in a
            // stranded band below the navigation bar.
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle("Monitor", isOn: Binding(
                    get: { appState.isEnabled(token) },
                    set: { appState.setEnabled(token, $0) }
                ))
                .toggleStyle(.switch)
                .tint(.green)
                .labelsHidden()
            }
        }
        .onAppear {
            appState.settings.detailToken = token
        }
        .sheet(isPresented: $showTargetSheet) {
            AppTargetSheet(token: token)
        }
    }

    private var toolbarTitle: some View {
        HStack(spacing: 10) {
            #if DEBUG
            if DemoMode.isEnabled {
                Image("DemoIcon01Solid")
                    .resizable()
                    .frame(width: 32, height: 32)
                Text("TikTok")
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
            } else {
                Label(token)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
            }
            #else
            Label(token)
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))
            #endif
        }
    }

    private var periodSwitch: some View {
        Picker("Period", selection: Binding(
            get: { appState.statsPeriod },
            set: { appState.setStatsPeriod($0) }
        )) {
            Text("Today").tag(Core.Period.day)
            Text("7 days").tag(Core.Period.week)
            Text("Month").tag(Core.Period.month)
        }
        .pickerStyle(.segmented)
        .frame(height: 40)
    }

    private var targetButton: some View {
        Button {
            showTargetSheet = true
        } label: {
            Text(targetButtonTitle)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.plain)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Divider"), lineWidth: 1))
    }

    private var targetButtonTitle: String {
        if let minutes = appState.target(for: token) {
            let text = DurationFormat.short(minutes: minutes)
            return "Target \(text) a day · Change"
        }
        return "Set a target"
    }
}
