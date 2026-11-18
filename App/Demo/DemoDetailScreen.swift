// DemoDetailScreen — the App detail screen fed from DemoData, for
// screenshot capture. Honours -period and -sheet target (Part 2).
// Debug builds only.

#if DEBUG
import SwiftUI
import Core

struct DemoDetailScreen: View {

    @State private var period: DemoMode.DemoPeriod
    @State private var showTargetSheet = false
    private let demoFocus: Int?

    init() {
        _period = State(initialValue: DemoMode.period ?? .week)
        _showTargetSheet = State(initialValue: DemoMode.sheet == "target")
        demoFocus = DemoMode.focus
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                periodSwitch

                AppDetailCardView(configuration: DemoData.appDetail(period: period), initialFocus: demoFocus)

                Button {
                    showTargetSheet = true
                } label: {
                    Text("Target 1h a day · Change")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("PrimaryText"))
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.plain)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Divider"), lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color("Ground"))
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 10) {
                    Image("DemoIcon01Solid")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("TikTok")
                        .font(.headline)
                        .foregroundStyle(Color("PrimaryText"))
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color("PrimaryText"))
                }
                .accessibilityLabel("Back")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle("Monitor", isOn: .constant(true))
                    .toggleStyle(.switch)
                    .tint(.green)
                    .labelsHidden()
            }
        }
        .onAppear { DemoMarker.mark("detail") }
        .sheet(isPresented: $showTargetSheet) {
            DemoTargetSheet()
                .presentationDetents([.medium])
        }
    }

    private var periodSwitch: some View {
        Picker("Period", selection: $period) {
            Text("Today").tag(DemoMode.DemoPeriod.today)
            Text("7 days").tag(DemoMode.DemoPeriod.week)
            Text("Month").tag(DemoMode.DemoPeriod.month)
        }
        .pickerStyle(.segmented)
        .frame(height: 40)
    }
}

/// The per-app target sheet over demo detail (read-only sample).
private struct DemoTargetSheet: View {
    @State private var minutes = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily target")
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))

            HStack(spacing: 8) {
                ForEach(Array([30, 45, 60, 90].enumerated()), id: \.offset) { index, preset in
                    Button(["30m", "45m", "1h", "1h 30m"][index]) {
                        minutes = preset
                    }
                    .buttonStyle(.preset(minutes == preset))
                }
            }

            Stepper(DurationFormat.short(minutes: minutes), value: $minutes, in: 15...480, step: 15)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("PrimaryText"))

            Text("Remove target")
                .font(.subheadline)
                .foregroundStyle(Color.red)
        }
        .padding(24)
    }
}
#endif
