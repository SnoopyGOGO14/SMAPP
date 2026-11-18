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
                header

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
            Label(applicationToken: token)
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            Toggle("Monitor", isOn: Binding(
                get: { appState.isEnabled(token) },
                set: { appState.setEnabled(token, $0) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
        .padding(.trailing, 4)
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
