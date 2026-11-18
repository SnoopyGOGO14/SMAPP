// AppTargetSheet — per-app target: presets, a 15-minute stepper, remove.

import SwiftUI
import FamilyControls
import Core

struct AppTargetSheet: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let token: ApplicationToken

    @State private var minutes: Int = 60

    private static let presets = [30, 45, 60, 90]
    private static let presetTitles = ["30m", "45m", "1h", "1h 30m"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily target")
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))

            HStack(spacing: 8) {
                ForEach(Array(Self.presets.enumerated()), id: \.offset) { index, preset in
                    Button(Self.presetTitles[index]) {
                        minutes = preset
                    }
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.bordered)
                    .tint(minutes == preset ? Color.accentColor : Color("SecondaryText"))
                }
            }

            Stepper(
                DurationFormat.short(minutes: minutes),
                value: $minutes,
                in: 15...480,
                step: 15
            )
            .font(.title3.weight(.semibold))
            .foregroundStyle(Color("PrimaryText"))

            Button("Remove target") {
                appState.setTarget(token, minutes: nil)
                dismiss()
            }
            .font(.subheadline)
            .foregroundStyle(Color.red)

            Button("Save") {
                appState.setTarget(token, minutes: minutes)
                dismiss()
            }
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .presentationDetents([.medium])
        .onAppear {
            minutes = appState.target(for: token) ?? 60
        }
    }
}
