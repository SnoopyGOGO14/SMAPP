# Social Time Monitor — session tasks for the builder (GLM)

Nine sessions, done in order. Each one is sized for a single working session. Read `00-README-START-HERE.md` (standing rules) and `01-BUILD-SPEC-v2.md` first, then `PROGRESS.md`, then the one session you are on.

Legend: **[GLM]** = the coding model does it. **[PERSON]** = needs the Apple portal, Xcode's interface or the physical iPhone. **GATE** = stop for a device check before the next session.

## Names used throughout

| Item | Value (replace `YOURORG` once, in `project.yml`) |
| --- | --- |
| App bundle ID | `com.YOURORG.socialtimemonitor` |
| Report extension bundle ID | `com.YOURORG.socialtimemonitor.UsageReport` |
| Monitor extension bundle ID | `com.YOURORG.socialtimemonitor.UsageMonitor` |
| App Group | `group.com.YOURORG.socialtimemonitor` |
| Minimum iOS | 17.4 |
| Languages | Swift 5.9 or later, SwiftUI, Swift Charts |

## Folder layout to create

```
SMAPP/
  project.yml                  XcodeGen project definition (three targets)
  PROGRESS.md                  running log, updated every session
  Packages/Core/               Swift package, Foundation only, runs under `swift test`
    Sources/Core/              Zone, TargetMath, DurationFormat, Checkpoint, SettingsKeys, PeriodMath
    Tests/CoreTests/
  Shared/                      iOS-only sources compiled into more than one target
    SharedSettings.swift       all targets
    ReportContexts.swift       app + UsageReport
    ZoneStyle.swift            app + UsageReport (SwiftUI; keep out of UsageMonitor)
  App/                         main app target
  UsageReport/                 DeviceActivityReport extension
  UsageMonitor/                DeviceActivityMonitor extension
  Config/                      Info.plist and .entitlements per target, PrivacyInfo.xcprivacy
```

---

## Session 0 — Scaffold

**Goal:** a project that generates, compiles and installs an empty app with both extensions embedded.

**[PERSON] in parallel (start today, Apple's review has its own timetable)**

- [ ] Apple Developer Program membership active
- [ ] Register the three bundle IDs and the App Group
- [ ] Enable Family Controls (Development) and App Groups on all three IDs
- [ ] Submit the Family Controls (Distribution) request for **each** of the three bundle IDs
- [ ] Install XcodeGen (`brew install xcodegen`); have one iPhone on iOS 17.4 or later, ideally a second on the newest iOS

**[GLM] tasks**

- [ ] Create the folder layout above and `PROGRESS.md` (sections: Done, Verified, Waiting on person, Open questions, Decisions)
- [ ] `Packages/Core/Package.swift` (library `Core`, test target `CoreTests`, platforms iOS 17 and macOS 13)
- [ ] `project.yml` with three targets: `SocialTimeMonitor` (application), `UsageReport` and `UsageMonitor` (extensions embedded in the app), all depending on package `Core`, deployment target 17.4
- [ ] `Config/*.entitlements` for each target: `com.apple.developer.family-controls` = true and `com.apple.security.application-groups` = the App Group
- [ ] `Config/UsageMonitor-Info.plist`: `NSExtension` with `NSExtensionPointIdentifier` = `com.apple.deviceactivity.monitor-extension` and `NSExtensionPrincipalClass` = `$(PRODUCT_MODULE_NAME).UsageMonitor`
- [ ] `Config/UsageReport-Info.plist`: `EXAppExtensionAttributes` with `EXExtensionPointIdentifier` = `com.apple.deviceactivityui.report-extension`
- [ ] Placeholder sources so each target compiles: `App/SocialTimeMonitorApp.swift` (one screen saying "Scaffold"), `UsageReport/UsageReportExtension.swift` (empty scene), `UsageMonitor/UsageMonitor.swift` (empty subclass)
- [ ] `.gitignore` for Xcode; `git init`; first commit

**Engineering notes**

- The report extension is an ExtensionKit extension; the monitor is a classic app extension. If XcodeGen rejects either target type, record it in `PROGRESS.md` and ask the person to add that target in Xcode (File › New › Target › "Device Activity Report Extension" / "Device Activity Monitor Extension"), then copy the generated plist values into `Config/`.
- [PERSON] should create one of each template target once in a throwaway project and compare its Info.plist with ours; Apple's template is the authority on these keys.

**Done when:** `xcodegen generate` succeeds; [PERSON] selects the signing team and the app installs on the iPhone showing "Scaffold".

---

## Session 1 — Core logic and tests

**Goal:** every calculation the app needs, proven by `swift test`, before any interface exists.

**[GLM] files in `Packages/Core/Sources/Core/`**

| File | Contents |
| --- | --- |
| `Zone.swift` | `enum Zone { green, amber, red }` and `zone(usedMinutes:allowanceMinutes:amberFraction:)` exactly as in the spec |
| `TargetMath.swift` | `enum TargetMode { daily, weekly }`; daily ↔ weekly conversion (× 7, ÷ 7); allowance for each view per the spec table "Which allowance each view compares against"; `weekToDateAverage(total:daysElapsed:)` |
| `PeriodMath.swift` | `enum Period { hour, day, week, month }`; `dateInterval(for:offset:calendar:weekStartsOn:)` returning the interval shown for a period and a back/forward offset |
| `DurationFormat.swift` | minutes → "2h 14m", "46m", "0m"; "46m left" |
| `Checkpoint.swift` | `struct Checkpoint: Codable { date, percent }`; `checkpointPercents = [25, 50, 75, 100, 125, 150]`; `thresholdMinutes(percent:targetMinutes:)`; `isPlausible(percent:targetMinutes:minutesSinceIntervalStart:)` (the sanity guard: threshold minutes must be ≤ minutes elapsed) |
| `SettingsKeys.swift` | string constants for every App Group key in the spec's data model table |

**[GLM] tests (minimum)**

- [ ] Zone boundaries: 0%, 74.9%, 75%, 100%, 100.1%, allowance 0
- [ ] Daily/weekly conversion round-trips; each row of the allowance table in both modes
- [ ] Period intervals: day across a clock change, week with Monday and Sunday starts, month lengths 28 to 31, offsets −1 and −12
- [ ] Duration strings: 0, 59, 60, 134, 600 minutes
- [ ] Sanity guard: 3-hour target, 100% event at 01:00 → implausible; at 15:00 → plausible

**Done when:** `swift test` passes in `Packages/Core`; results pasted into `PROGRESS.md`.

---

## Session 2 — Proof of data path — GATE A

**Goal:** real usage for chosen apps, coloured against a target read from the App Group, drawn by the report extension inside the app. This proves the architecture; keep the interface bare.

**[GLM] files**

| File | Contents |
| --- | --- |
| `Shared/SharedSettings.swift` | Wrapper on `UserDefaults(suiteName: appGroup)`: typed get/set for every key; encodes `FamilyActivitySelection`, `Set<ApplicationToken>` and `[ApplicationToken]` with `PropertyListEncoder`; after decoding a selection, rebuild it with `includeEntireCategory: true`; helpers `target(for token)`, `paletteIndex(for token)` |
| `Shared/ReportContexts.swift` | The five contexts: `homeTotal`, `appRow`, `appTime`, `appDetail`, `allApps` |
| `Shared/ZoneStyle.swift` | semantic system colours (`Color(.systemGreen)`, `Color(.systemOrange)`, `Color(.systemRed)`; no hard-coded hex), wording per zone, plus the `neutral` case (no target) — app and `UsageReport` only |
| `App/ProofView.swift` | Buttons: "Allow Screen Time", "Pick apps", a field for target minutes, and the embedded `homeTotal` report plus one `appRow` row |
| `UsageReport/UsageReportExtension.swift` | `@main struct … : DeviceActivityReportExtension` listing the scenes |
| `UsageReport/Aggregator.swift` | The one walker of `DeviceActivityResults<DeviceActivityData>` → segments → categories → applications; returns plain structs (seconds per token, per day) |
| `UsageReport/HomeTotalScene.swift` + view | Hero total, "of 3h", bar with marker, status line |
| `UsageReport/AppRowScene.swift` + view | Time and thin bar for one token |

**API shapes to follow**

```swift
// App: permission
try await AuthorizationCenter.shared.requestAuthorization(for: .individual)

// App: picker
@State private var selection = FamilyActivitySelection(includeEntireCategory: true)
.familyActivityPicker(isPresented: $showPicker, selection: $selection)

// App: host the report
let filter = DeviceActivityFilter(
    segment: .daily(during: todayInterval),
    users: .all,
    devices: .init([.iPhone]),
    applications: settings.enabledTokens,
    categories: [],
    webDomains: [])
DeviceActivityReport(.homeTotal, filter: filter)
// App row: same shape, filter limited to one token
DeviceActivityReport(.appRow, filter: singleAppFilter)

// Extension: a scene
struct TodaySummaryScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .todaySummary
    let content: (TodayConfiguration) -> TodayRingView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> TodayConfiguration {
        var seconds: TimeInterval = 0
        for await device in data {
            for await segment in device.activitySegments {
                for await category in segment.categories {
                    for await app in category.applications {
                        seconds += app.totalActivityDuration   // app.application.token identifies it
                    }
                }
            }
        }
        // read target + amberFraction through SharedSettings, compute Zone via Core
    }
}
```

**Engineering notes**

- Inside the report extension, App Group **reads** are expected to work and **writes** are blocked. Read only.
- Compute everything in `makeConfiguration`; keep the view a plain renderer of the configuration.
- Log with `os.Logger` in the extension; `print` output from extensions is easy to miss.

**GATE A — [PERSON] on the iPhone**

- [ ] Allow access, pick two or three apps, use one for five minutes
- [ ] Home total matches Settings › Screen Time for those apps within a minute or two
- [ ] Removing an app from the selection removes its time
- [ ] Changing the target minutes recolours the bar and moves the marker (proves the extension reads the App Group)
- [ ] Record the iOS version and result in `PROGRESS.md`. If the App Group read fails, stop and record it: the fallback in the spec's risk table applies.

---

## Session 3 — Onboarding, Home screen, access banner

**Goal:** the real first-run experience and Home screen (requirements R1, R2, R3, R11, R12; design `design/DESIGN-NOTES.md` § Home).

**[GLM] files**

| File | Contents |
| --- | --- |
| `App/AppState.swift` | `@Observable` model (use `ObservableObject` if `@Observable` causes trouble): authorisation status, selection, ordered tokens, enabled tokens, targets, period. Loads and saves through `SharedSettings` |
| `App/Onboarding/OnboardingFlow.swift` | Card 1 what the app does; Card 2 what we see / what we never see, then the system prompt; Card 3 picker with the hint "Tick Social and YouTube"; Card 4 target presets |
| `App/Home/HomeScreen.swift` | "Today" + date, embedded `homeTotal` report, card of `AppUsageRow` rows |
| `App/Home/AppUsageRow.swift` | `NavigationLink` row: `Label(token)` icon and name, embedded `appRow` report with `.allowsHitTesting(false)`. A `timeOnly` style embeds `appTime` instead and shows a palette dot |
| `App/AccessBanner.swift` | Shown when access is off or the selection is empty; one button re-requests access and reopens the picker |
| `App/RootTabs.swift` | Tabs: Apps, Stats, Target (Stats and Target are placeholders until Sessions 4 and 5) |

**Tasks**

- [ ] Row order: stable sort via `orderedTokens` so rows keep their place between launches
- [ ] The whole row opens App detail; no switch on the row (it lives on App detail)
- [ ] On every `scenePhase == .active`: re-read `AuthorizationCenter.shared.authorizationStatus`; when access is off, show the banner
- [ ] After access is re-granted, ask the user to pick apps again (earlier tokens are void)
- [ ] Empty states: before permission, before any app picked
- [ ] Editing a non-empty selection lives in Settings ("Edit app selection"), keeping Home to the designed elements

**Done when:** a new user completes setup in under a minute; row order survives relaunch; turning access off in Settings produces the banner on return.

---

## Session 4 — App detail and All apps — GATE B

**Goal:** the other two approved screens (R4, R5, R15, R16).

**[GLM] files**

| File | Contents |
| --- | --- |
| `App/Detail/AppDetailScreen.swift` | Back, `Label(token)` title, on/off switch, period switch, embedded `appDetail` report, target button. Writes `detailToken` and `statsPeriod` before the report appears |
| `App/Detail/AppTargetSheet.swift` | Stepper in 15-minute steps, presets 30m, 45m, 1h, 1h 30m, "Remove target" |
| `App/Stats/AllAppsScreen.swift` | "All apps" + date, period switch, embedded `allApps` report, card of `AppUsageRow(style: .timeOnly)` |
| `UsageReport/AppDetailScene.swift` + view | Today card (hero, bar, status line); period card (days-hours-minutes-seconds line, Swift Charts daily bars in zone colours, dashed target rule, today outlined, day initials); two stats (daily average, days within target) |
| `UsageReport/AppTimeScene.swift` + view | Time only, right-aligned |
| `UsageReport/AllAppsScene.swift` + view | Donut with Swift Charts `SectorMark`, one segment per platform, centre total and "of 3h" |

**Tasks**

- [ ] Placeholder of identical size while each report loads; plain empty state per period
- [ ] VoiceOver: donut reads total and per-app figures; bars read "Tuesday, 58 minutes, getting close"
- [ ] Month view: when iOS returns fewer days than requested, show "Showing the last N days"
- [ ] An app with no per-app target: neutral bar, no marker (Home row and detail today card)

**GATE B — [PERSON]**

- [ ] Home, App detail and All apps figures agree with Settings › Screen Time on two iOS versions
- [ ] Home with five embedded row reports loads within two seconds; tapping a row opens App detail
- [ ] Donut segment sizes match each app's share; centre total matches
- [ ] Note how many days of history the Month views return; record in `PROGRESS.md`
- [ ] App icons and names appear in the per-app list (a known trouble spot inside report extensions)
- [ ] Leave the app and return: charts redraw

---

## Session 5 — Target tab and per-app targets

**Goal:** the Target tab, overall target, per-app targets (R6, R7, R8, R14).

**[GLM] files**

| File | Contents |
| --- | --- |
| `App/Target/TargetScreen.swift` | Overall target: Daily or Weekly selector, presets 1h–4h, custom stepper (15-minute steps), live three-zone strip; master Monitoring switch; alerts switch; recaps switch; link to Settings |
| `App/Target/SettingsScreen.swift` | Amber threshold slider, week start day, "Edit app selection", access status, privacy statement |

**Tasks**

- [ ] Switching Daily ↔ Weekly converts the current figure (× 7, ÷ 7) through `TargetMath`
- [ ] Per-app targets saved to `appTargets`; `appRow` and `appDetail` take their allowance from them; no target → neutral
- [ ] Status line wording: "Getting close · 14m left", "Over target · by 7m", "Comfortable · 29m left"; empty for neutral
- [ ] Zone always shown as colour + word

**Done when:** changing any target recolours bars and status lines on next appearance; Core tests still pass.

---

## Session 6 — Monitor, scheduling, alerts, recaps — GATE C

**Goal:** the part that works while the app is closed (R9, R13).

**[GLM] files**

| File | Contents |
| --- | --- |
| `App/Monitoring/MonitoringScheduler.swift` | Builds schedule and events from settings; `startMonitoring`; debounced restart (1 second) on any change to switches, target, mode or master switch; `stopMonitoring` when paused |
| `App/Monitoring/NotificationManager.swift` | Requests notification permission the first time alerts or recaps are switched on; schedules recap notifications; routes a tap to the Apps tab |
| `UsageMonitor/UsageMonitor.swift` | `eventDidReachThreshold`: parse percent from the event name, run the sanity guard, save `lastCheckpoint`, post a notification at 75 and 100 |

**API shapes to follow**

```swift
// App
extension DeviceActivityName { static let daily = Self("daily"); static let weekly = Self("weekly") }

let schedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 0, minute: 0),
    intervalEnd: DateComponents(hour: 23, minute: 59),
    repeats: true)

var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
for percent in Checkpoint.checkpointPercents {
    let minutes = Checkpoint.thresholdMinutes(percent: percent, targetMinutes: target)
    events[.init("pct.\(percent)")] = DeviceActivityEvent(
        applications: enabledTokens,
        threshold: DateComponents(hour: minutes / 60, minute: minutes % 60),
        includesPastActivity: true)
}
try DeviceActivityCenter().startMonitoring(.daily, during: schedule, events: events)

// Extension
final class UsageMonitor: DeviceActivityMonitor {
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name,
                                         activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // percent from event.rawValue → guard → save checkpoint → notify
    }
}
```

**Engineering notes**

- Weekly mode: one activity `.weekly` whose schedule runs from the week's first day 00:00 to its last day 23:59 (add `weekday` to both `DateComponents`), thresholds as percentages of the weekly target. Confirm on device that the interval spans the week.
- Memory ceiling is about 6 MB: no SwiftUI, no Charts, decode only the keys needed, no retained collections.
- Sanity guard: the event carries no usage figure, so derive threshold minutes from the percent in its name and require that it is ≤ minutes elapsed since the interval began. Drop events that fail.
- Alert wording: "About three-quarters of today's target used" / "Today's target reached". Recap wording: "Your day is ready to view" (the main app holds no exact figure).
- Stop and restart monitoring under the same activity name; a restart with `includesPastActivity: true` keeps earlier usage in the count.

**GATE C — [PERSON]**

- [ ] With the app force-closed, amber then red alerts arrive as usage crosses each line
- [ ] Restart the phone, keep the app closed, cross a line: alert still arrives
- [ ] Flip a switch at mid-day: the count continues from the morning's usage
- [ ] First pick-up next morning: no alert before real use (the iOS 26.x early-fire issue); record what happens
- [ ] Tapping an alert opens the Today ring

---

## Session 7 — Polish and accessibility

**[GLM] tasks**

- [ ] Dynamic Type up to the largest accessibility size without clipping; ring text scales
- [ ] VoiceOver labels on ring, switches ("Instagram, monitoring on"), charts
- [ ] Dark mode check of every screen; zone colours meet contrast on both backgrounds
- [ ] All strings in a String Catalog, British English
- [ ] Haptics on switches and preset buttons; Reduce Motion respected for the ring animation
- [ ] Every empty and loading state from the spec present
- [ ] Remove `ProofView` and any debug toggles; app icon and launch screen in place (original artwork, free of third-party brand marks)

**Done when:** the person walks every screen with VoiceOver and at the largest text size.

---

## Session 8 — Release preparation — GATE D

**[GLM] tasks**

- [ ] `Config/PrivacyInfo.xcprivacy` in all three targets declaring UserDefaults use with the current required-reason codes (check Apple's "Describing use of required reason API" page for the codes covering own-app and App Group defaults); no tracking, no collected data
- [ ] `docs/AppStore/review-notes.md`: purpose (self-monitoring), `.individual` authorisation, data stays on device, how to test
- [ ] `docs/AppStore/listing.md`: name options, subtitle, description, keywords, free of third-party brand names
- [ ] `docs/AppStore/privacy-policy.md`: plain statement that nothing leaves the phone
- [ ] Version 1.0 (1); Release configuration builds clean with zero warnings

**[PERSON]**

- [ ] Confirm Family Controls (Distribution) is active on all three bundle IDs
- [ ] Archive, upload, TestFlight round with two or three testers for a full week (covers a week boundary)
- [ ] Screenshots from a real device showing the user's own app rows
- [ ] Submit for review

**GATE D:** TestFlight build approved by the product owner.

---

## After version 1 (parked)

- Lock Screen and Home Screen widget using `lastCheckpoint`
- Green-day streak
- EU edition using Apple's direct-data route (separate build flag, separate consent wording)
- Android version on `UsageStatsManager`
