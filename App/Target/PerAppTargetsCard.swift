// PerAppTargetsCard — Settings' per-app target list (S3): reflects
// demo data in demo mode (TikTok 1h, Instagram 45m, YouTube 1h, X
// 30m), the stored targets in live mode; every row edits (a sheet
// with presets and a stepper) and removes.

import SwiftUI
import FamilyControls
import ManagedSettings
import Core

struct PerAppTargetsCard: View {

    @Environment(AppState.self) private var appState
    /// Demo mode's targets, keyed by app name (seeded from DemoData).
    @State private var demoTargets: [String: Int] = [:]
    @State private var editing: TargetRow?

    private struct TargetRow: Identifiable {
        let id: String
        let minutes: Int
        let token: ApplicationToken?
        let demoName: String?
    }

    var body: some View {
        VStack(spacing: 0) {
            if rows.isEmpty {
                Text("No per-app targets")
                    .font(.footnote)
                    .foregroundStyle(Color("SecondaryText"))
                    .padding(16)
            } else {
                ForEach(rows) { row in
                    rowView(row)
                    if row.id != rows.last?.id {
                        Divider().overlay(Color("Divider"))
                    }
                }
            }
        }
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
        .sheet(item: $editing) { row in
            if let token = row.token {
                AppTargetSheet(token: token)
            } else if let name = row.demoName {
                DemoTargetEditSheet(
                    name: name,
                    minutes: row.minutes
                ) { newMinutes in
                    if let newMinutes {
                        demoTargets[name] = newMinutes
                    } else {
                        demoTargets.removeValue(forKey: name)
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .onAppear {
            #if DEBUG
            if DemoMode.isEnabled {
                demoTargets = Dictionary(
                    uniqueKeysWithValues: DemoData.apps.compactMap { app in
                        app.targetMinutes.map { (app.name, $0) }
                    }
                )
            }
            #endif
        }
    }

    // MARK: - Rows

    private var rows: [TargetRow] {
        #if DEBUG
        if DemoMode.isEnabled {
            return DemoData.apps.compactMap { app in
                demoTargets[app.name].map { minutes in
                    TargetRow(id: app.name, minutes: minutes, token: nil, demoName: app.name)
                }
            }
        }
        #endif
        return appState.appTargets.map { target in
            TargetRow(
                id: "token-\(target.minutes)-\(target.token.hashValue)",
                minutes: target.minutes,
                token: target.token,
                demoName: nil
            )
        }
    }

    private func rowView(_ row: TargetRow) -> some View {
        HStack(spacing: 12) {
            if let token = row.token {
                Label(token)
                    .font(.subheadline)
                    .foregroundStyle(Color("PrimaryText"))
            } else if let name = row.demoName, let app = DemoData.apps.first(where: { $0.name == name }) {
                DemoTile(position: app.paletteIndex, initials: app.initials, size: 28)
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("PrimaryText"))
            }
            Spacer()
            Text(DurationFormat.short(minutes: row.minutes))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
            Button("Edit") {
                editing = row
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color("PrimaryText"))
            .buttonStyle(.borderless)
            Button("Remove") {
                remove(row)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color("SecondaryText"))
            .buttonStyle(.borderless)
        }
        .padding(16)
    }

    private func remove(_ row: TargetRow) {
        #if DEBUG
        if DemoMode.isEnabled, let name = row.demoName {
            demoTargets.removeValue(forKey: name)
            return
        }
        #endif
        if let token = row.token {
            appState.setTarget(token, minutes: nil)
        }
    }
}

/// The demo row's editor: presets, a stepper, save and remove —
/// mirroring the live sheet's layout (debug only).
#if DEBUG
struct DemoTargetEditSheet: View {
    let name: String
    @State private var minutes: Int
    let onDone: (Int?) -> Void

    private static let presets = [30, 45, 60, 90]
    private static let presetTitles = ["30m", "45m", "1h", "1h 30m"]

    init(name: String, minutes: Int, onDone: @escaping (Int?) -> Void) {
        self.name = name
        _minutes = State(initialValue: minutes)
        self.onDone = onDone
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily target \u{00B7} \(name)")
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))

            HStack(spacing: 8) {
                ForEach(Array(Self.presets.enumerated()), id: \.offset) { index, preset in
                    Button(Self.presetTitles[index]) {
                        minutes = preset
                    }
                    .buttonStyle(.preset(minutes == preset))
                }
            }

            Stepper(DurationFormat.short(minutes: minutes), value: $minutes, in: 15...480, step: 15)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("PrimaryText"))

            Button("Save") {
                onDone(minutes)
            }
            .buttonStyle(.primaryAction)

            Button("Remove target") {
                onDone(nil)
            }
            .font(.subheadline)
            .foregroundStyle(Color.red)
        }
        .padding(24)
    }
}
#endif
