// DiagnosticsConfiguration + DiagnosticsReportView — what the sealed
// report draws for the Gate A checklist (Part 1): its read-back of the
// App Group (timestamp, target), the data path (today's seconds, app
// count, day segments), and a tap counter that proves touches arrive
// inside the extension. Plain rows, debug styling only.

import SwiftUI
import Core

#if DEBUG
public struct DiagnosticsConfiguration: Equatable {
    /// The timestamp the host wrote; nil if the read failed.
    public let appGroupTimestamp: String?
    /// The overall target the extension read; nil if unread.
    public let targetMinutes: Int?
    /// Today's total seconds across the filtered apps, if known.
    public let todaySeconds: Double?
    /// Distinct apps in the results.
    public let appCount: Int
    /// Day segments returned for the (35-day) request.
    public let daySegments: Int

    public init(
        appGroupTimestamp: String?,
        targetMinutes: Int?,
        todaySeconds: Double?,
        appCount: Int,
        daySegments: Int
    ) {
        self.appGroupTimestamp = appGroupTimestamp
        self.targetMinutes = targetMinutes
        self.todaySeconds = todaySeconds
        self.appCount = appCount
        self.daySegments = daySegments
    }
}

public struct DiagnosticsReportView: View {
    let configuration: DiagnosticsConfiguration

    @State private var tapCount = 0

    public init(configuration: DiagnosticsConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXT report")
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color("MutedText"))
            row("App Group timestamp", configuration.appGroupTimestamp ?? "— none —")
            row("Target read", configuration.targetMinutes.map { "\($0) min" } ?? "— none —")
            row("Today total", configuration.todaySeconds.map { "\(Int($0)) s" } ?? "— unknown —")
            row("Apps returned", "\(configuration.appCount)")
            row("Day segments (35-day ask)", "\(configuration.daySegments)")
            Button("Tap test: \(tapCount)") {
                tapCount += 1
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color("PrimaryText"))
            .frame(maxWidth: .infinity, minHeight: 44)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("Divider"), lineWidth: 1))
            .accessibilityLabel("Tap test, \(tapCount) taps so far")
        }
        .padding(16)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color("SecondaryText"))
            Spacer()
            Text(value)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
        }
    }
}
#endif
