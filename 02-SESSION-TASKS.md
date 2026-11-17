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
| `Shared/SharedSettings.swift` | Wrapper on `UserDefaults(suiteName: appGroup)`: typed get/set for every key; encodes `FamilyActivitySelection` and `Set<ApplicationToken>` with `PropertyListEncoder`; after decoding a selection, rebuild it with `includeEntireCategory: true` |
| `Shared/ReportContexts.swift` | `extension DeviceActivityReport.Context { static let todaySummary = Self("todaySummary") }` (add `hourly`, `daily`, `weekly`, `monthly` now, used in Session 4) |
| `Shared/ZoneStyle.swift` | semantic system colours (`Color(.systemGreen)`, `Color(.systemOrange)`, `Color(.systemRed)`; see the spec's visual rules — no hard-coded hex), wording and SF Symbol per zone |
| `App/ProofView.swift` | Buttons: "Allow Screen Time", "Pick apps", a field for target minutes, and the embedded report |
| `UsageReport/UsageReportExtension.swift` | `@main struct … : DeviceActivityReportExtension` listing the scenes |
| `UsageReport/TodaySummaryScene.swift` | Scene that totals usage and returns a configuration |
| `UsageReport/TodayRingView.swift` | Ring: time used, target, zone colour and word |

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
DeviceActivityReport(.todaySummary, filter: filter)

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
- [ ] Ring total matches Settings › Screen Time for those apps within a minute or two
- [ ] Removing an app from the selection removes its time
- [ ] Changing the target minutes recolours the ring (proves the extension reads the App Group)
- [ ] Record the iOS version and result in `PROGRESS.md`. If the App Group read fails, stop and record it: the fallback in the spec's risk table applies.

---

## Session 3 — Onboarding, Apps screen, switches, access banner

**Goal:** the real first-run experience and home screen (requirements R1, R2, R3, R11, R12).

**[GLM] files**

| File | Contents |
| --- | --- |
| `App/AppState.swift` | `@Observable` model: authorisation status, selection, enabled tokens, master switch, target; loads and saves through `SharedSettings` |
| `App/Onboarding/OnboardingFlow.swift` | Card 1 what the app does; Card 2 plain-language "what we see / what we never see", then the system prompt; Card 3 picker with the hint "Tick Social and YouTube"; Card 4 target presets |
| `App/Apps/AppsScreen.swift` | Today ring (embedded report) on top; master switch; one row per picked app: `Label(token)` + `Toggle`; "Add or remove apps" |
| `App/Apps/AccessBanner.swift` | Shown when access is off or the selection is empty; button re-requests access and reopens the picker |
| `App/RootTabs.swift` | Tabs: Apps, Stats, Target (Stats and Target are placeholders until Sessions 4 and 5) |

**Tasks**

- [ ] Row order: stable sort so rows keep their place between launches (store an ordered array of tokens)
- [ ] Switch flip: update `enabledTokens`, light haptic, ring refreshes (the filter changes, so the report reloads)
- [ ] Master switch off: ring shows "Paused", rows dim
- [ ] On every `scenePhase == .active`: re-read `AuthorizationCenter.shared.authorizationStatus`; when access is off, show the banner
- [ ] After access is re-granted, ask the user to pick apps again (earlier tokens are void)
- [ ] Empty states: before permission, before any app picked

**Done when:** a new user completes setup in under a minute; switch states and row order survive relaunch; turning access off in Settings produces the banner on return.

---

## Session 4 — Statistics — GATE B

**Goal:** Hour, Day, Week and Month views (R4, R5) from one chart component.

**[GLM] files**

| File | Contents |
| --- | --- |
| `App/Stats/StatsScreen.swift` | Segmented control (Hour, Day, Week, Month), back/forward arrows, remembers last period; builds the filter from `PeriodMath` and embeds `DeviceActivityReport(context, filter:)` |
| `UsageReport/PeriodScene.swift` | One generic scene type, instantiated four times with a context and a bucketing rule |
| `UsageReport/PeriodChartView.swift` | Swift Charts `BarMark` per bucket coloured by zone, dashed `RuleMark` at the allowance, total and average, per-app list with `Label(token)`, time and share bar |
| `UsageReport/PeriodConfiguration.swift` | Buckets (start, minutes, zone), per-app totals, total, average, allowance |

**Segments**

| View | Filter segment | Buckets |
| --- | --- | --- |
| Hour | `.hourly(during: day)` | 24 bars; zone from running total |
| Day | `.daily(during: week)` | 7 bars |
| Week | `.weekly(during: last 8 weeks)` | 8 bars |
| Month | `.daily(during: month)` | one bar per day, summary shows average per day or per week |

**Tasks**

- [ ] Placeholder of identical size while the report loads
- [ ] Empty state when a period has no usage
- [ ] VoiceOver: each bar reads "Tuesday, 2 hours 14 minutes, Getting close"
- [ ] Month view: when iOS returns fewer days than requested, show "Showing the last N days"

**GATE B — [PERSON]**

- [ ] All four views agree with Settings › Screen Time on two iOS versions
- [ ] Note how many days of history the Month view returns; record in `PROGRESS.md`
- [ ] App icons and names appear in the per-app list (a known trouble spot inside report extensions)
- [ ] Leave the app and return: charts redraw

---

## Session 5 — Target and zones

**Goal:** the Target tab and zone treatment everywhere (R6, R7, R8).

**[GLM] files**

| File | Contents |
| --- | --- |
| `App/Target/TargetScreen.swift` | Daily/Weekly selector; presets 1, 2, 3, 4 hours a day; custom stepper in 15-minute steps; live three-zone strip; alerts switch; recaps switch |
| `App/Target/SettingsScreen.swift` | Amber threshold slider (50–95%), week start day, access status, privacy statement |

**Tasks**

- [ ] Switching Daily ↔ Weekly converts the current figure (× 7, ÷ 7) through `TargetMath`
- [ ] Every report view takes its allowance from `TargetMath` per the spec table
- [ ] Ring shows time remaining while green or amber; "Over today's target" when red
- [ ] Weekly average line on the Day view
- [ ] Zone always shown as colour + word + symbol

**Done when:** changing target, mode or amber threshold recolours ring and charts on next appearance; Core tests still pass.

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
