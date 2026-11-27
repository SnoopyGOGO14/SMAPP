// DiagnosticsScreen — debug only (Part 1): the Gate A checklist the
// phone fills in itself. Host sections (access, selection, App Group
// echo, monitoring, notifications, build) plus the embedded
// `diagnostics` report — the extension's read-back, the data path and
// the tap test. "Copy report" puts everything the host knows on the
// pasteboard with blanks for the report-drawn values.

import SwiftUI
import DeviceActivity
import FamilyControls
import UserNotifications
import Core

#if DEBUG
struct DiagnosticsScreen: View {

    @Environment(AppState.self) var appState
    @State var lastChecked: String = ""
    @State var hostEcho: Bool?
    @State var writtenTimestamp: String = ""
    @State var activitiesCount: Int = 0
    @State var notificationStatusText: String = "unknown"
    @State var stopwatchStart: Date?
    @State var stopwatchElapsed: TimeInterval?
        // Demo mode opens with sample values so `-screen diagnostics`
    // captures something meaningful (Part 1.5).
    @State var showDemoReport: Bool = DemoMode.isEnabled

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                accessSection
                selectionSection
                appGroupSection
                reportSection
                embeddedRowsSection
                monitoringSection
                notificationsSection
                buildSection
                copyButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color("Ground"))
        .navigationTitle("Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DemoMarker.mark("diagnostics")
            refresh()
        }
    }

    // MARK: - Host sections

    private var accessSection: some View {
        diagnosticsCard("Screen Time access") {
            valueRow("Status", "\(appState.authorizationStatus)")
            valueRow("Last checked", lastChecked)
        }
    }

    private var selectionSection: some View {
        diagnosticsCard("Selection") {
            valueRow("Chosen apps", "\(appState.orderedTokens.count)")
            valueRow("Enabled apps", "\(appState.enabledTokens.count)")
            valueRow("Per-app targets", "\(appState.appTargets.count)")
            valueRow("Stored selection decoded", appState.settings.selection != nil ? "yes" : "no")
        }
    }

    private var appGroupSection: some View {
        diagnosticsCard("App Group (host side)") {
            valueRow("Wrote + read back", hostEcho.map { $0 ? "match" : "MISMATCH" } ?? "not checked")
            valueRow("Timestamp", writtenTimestamp)
        }
    }

    private var reportSection: some View {
        diagnosticsCard("Sealed report (extension side)") {
            if showDemoReport {
                DiagnosticsReportView(
                    configuration: DiagnosticsConfiguration(
                        appGroupTimestamp: writtenTimestamp.isEmpty ? "12:00:00" : writtenTimestamp,
                        targetMinutes: 180,
                        todaySeconds: 3440,
                        appCount: 5,
                        daySegments: 7
                    )
                )
            } else {
                DeviceActivityReport(
                    .diagnostics,
                    filter: Filters.diagnostics(enabled: appState.enabledTokens)
                )
                .frame(minHeight: 260)
            }
            Toggle("Demo values (no live report)", isOn: $showDemoReport)
                .font(.footnote)
                .tint(.green)
            // Part 2: set this from the report's "Day segments" number;
            // it gates the Monthly tab (monthlyRequiresHistory switch).
            Stepper(
                "Day segments seen: \(appState.settings.historyDays)",
                value: Binding(
                    get: { appState.settings.historyDays },
                    set: { appState.settings.historyDays = $0 }
                ),
                in: 0...35
            )
            .font(.footnote)
            .foregroundStyle(Color("SecondaryText"))
        }
    }

    private var embeddedRowsSection: some View {
        diagnosticsCard("Embedded rows (time by eye)") {
            if stopwatchStart == nil {
                Text("Start the stopwatch, then watch the rows below fill in.")
                    .font(.footnote)
                    .foregroundStyle(Color("SecondaryText"))
                Button("Start stopwatch") {
                    stopwatchStart = Date()
                }
                .buttonStyle(.primaryActionCompact)
            } else if let elapsed = stopwatchElapsed {
                valueRow("Elapsed to rows filled", String(format: "%.1f s", elapsed))
                Button("Restart") {
                    stopwatchStart = Date()
                    stopwatchElapsed = nil
                }
                .buttonStyle(.primaryActionCompact)
            } else {
                Text("Timing… tap Stop when the rows are drawn.")
                    .font(.footnote)
                    .foregroundStyle(Color("SecondaryText"))
                Button("Stop") {
                    stopwatchElapsed = Date().timeIntervalSince(stopwatchStart ?? Date())
                }
                .buttonStyle(.primaryActionCompact)
            }
            ForEach(appState.enabledTokens.prefix(5), id: \.self) { token in
                DeviceActivityReport(.appRow, filter: Filters.appRow(token: token))
                    .frame(height: 44)
                    .allowsHitTesting(false)
            }
            if stopwatchStart != nil, stopwatchElapsed == nil {
                Text(String(format: "%.1f s", Date().timeIntervalSince(stopwatchStart ?? Date())))
                    .font(.footnote.monospaced())
                    .foregroundStyle(Color("SecondaryText"))
            }
        }
    }

    private var monitoringSection: some View {
        diagnosticsCard("Monitoring") {
            valueRow("Activities", "\(activitiesCount)")
            valueRow("Last checkpoint", appState.settings.lastCheckpoint.map { "\($0.percent)% \($0.date)" } ?? "none")
            valueRow("Last alert", appState.settings.lastAlert.map { "\($0.percent)% at \($0.intervalStart)" } ?? "none")
            valueRow("Last error", appState.settings.lastMonitoringError ?? "none")
        }
    }

    private var notificationsSection: some View {
        diagnosticsCard("Notifications") {
            valueRow("Permission", notificationStatusText)
            Button("Send test alert (10 s)") { scheduleTestNotification() }
                .buttonStyle(.primaryActionCompact)
        }
    }

    private var buildSection: some View {
        diagnosticsCard("Build") {
            valueRow("App version", BuildInfo.appVersion)
            valueRow("Commit", BuildInfo.commit)
            valueRow("iOS", ProcessInfo.processInfo.operatingSystemVersionString)
            valueRow("Device", deviceModelName)
        }
    }

    private var copyButton: some View {
        Button("Copy report") {
            UIPasteboard.general.string = Core.DiagnosticsLogic.report(
                facts: hostFacts,
                hostTimestamp: writtenTimestamp.isEmpty ? lastChecked : writtenTimestamp
            )
        }
        .buttonStyle(.primaryAction)
    }

    // MARK: - Support

    private var hostFacts: Core.DiagnosticsLogic.HostFacts {
        return Core.DiagnosticsLogic.HostFacts(
            accessApproved: appState.hasAccess ? true : (appState.authorizationStatus == .denied ? false : nil),
            accessDenied: appState.authorizationStatus == .denied,
            chosenApps: appState.orderedTokens.count,
            enabledApps: appState.enabledTokens.count,
            perAppTargets: appState.appTargets.count,
            selectionDecoded: appState.settings.selection != nil,
            appGroupEcho: hostEcho ?? false,
            monitoringActivities: activitiesCount,
            monitoringError: appState.settings.lastMonitoringError,
            lastCheckpoint: appState.settings.lastCheckpoint.map { "\($0.date) — \($0.percent)%" },
            notificationsAuthorized: notificationStatusText == "authorized" ? true : (notificationStatusText == "denied" ? false : nil),
            notificationsDenied: notificationStatusText == "denied",
            appVersion: BuildInfo.appVersion,
            commit: BuildInfo.commit
        )
    }
}
#endif
