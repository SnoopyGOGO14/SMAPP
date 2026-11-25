# Social Time Monitor — iPhone App Build Spec (v2)

Version 2 · 17 November 2026 · supersedes the two earlier plan files in this folder. Build order and tasks: see `02-SESSION-TASKS.md`. Checklists: see `03-ENGINEER-CHECKLISTS.md`.

## Summary

A native iPhone app that shows how long the user actually spends on screen in TikTok, Instagram, Facebook, X, YouTube and any other app they choose, with an on/off switch per app, colour-zoned charts, and one user-set target (hours per day or per week). Working title: **Social Time Monitor**.

One platform rule shapes the whole build. On iOS the only permitted source of per-app usage time is Apple's Screen Time API, and Apple keeps that data inside a sealed extension: the app can *display* usage, but for customers outside the EU the app's own code can never read the raw numbers. The architecture below is designed around that rule, so every statistic screen is drawn inside the sealed extension and the main app handles switches, the target and settings.

Three consequences for the brief:

- **Time on screen is measured correctly.** Screen Time counts foreground use of each app, which matches the brief: scrolling and watching, as opposed to the app merely being open in the background.
- **App logos come from iOS itself.** The user picks their apps once from Apple's own picker; iOS then supplies each real icon and name. This gives the logo-and-switch layout asked for and keeps the app clear of trademark licensing.
- **Apple approval is on the critical path.** Distribution needs the Family Controls entitlement, requested separately for the app and each extension. Apply on day one.

## Product requirements

**In scope for version 1 (iPhone only)**

| # | Requirement | Detail |
| --- | --- | --- |
| R1 | Choose apps to monitor | User selects apps once from Apple's picker. Onboarding suggests ticking the Social category plus YouTube; any installed app can be added. |
| R2 | On/off switch per app | Home screen lists each chosen app as icon + name + switch. Switched-off apps are excluded from all totals and charts. |
| R3 | Master switch | One switch pauses or resumes all monitoring. |
| R4 | Usage statistics | Time on screen per app and combined, viewed by hour, day, week and month. |
| R5 | Chart views | Bar chart per period, coloured by zone; per-app breakdown under each chart. |
| R6 | User target | One number entered by the user, selectable as hours per day or hours per week. Example: 3 hours per day. |
| R7 | Colour zones | Green = comfortably inside target. Amber = approaching target. Red = over target (critical). |
| R8 | Weekly average check | In weekly mode, the average per day so far this week is compared with target ÷ 7 and zoned the same way. |
| R9 | Zone alerts | Optional local notification when usage enters amber and red. Tapping it opens the Today ring. |
| R10 | Privacy | Everything stays on the phone. No account, no server, no analytics on usage. |
| R11 | One-minute setup | Three steps: allow access, pick apps, choose a target from presets (1, 2, 3 or 4 hours a day, or custom). |
| R12 | Access health check | If Screen Time access is switched off or the app list is emptied, a banner explains and offers a one-tap fix. |
| R13 | Recaps | Optional evening and Sunday notification inviting the user to view the day or week. |
| R14 | Per-app target | Optional daily target per app, alongside the overall target. An app with no target shows a neutral bar. Set from App detail. |
| R15 | App detail screen | As `design/DESIGN-NOTES.md`: today card, period switch (Today / 7 days / Month), period card with the days-hours-minutes-seconds line and daily bars, two stats, one target button. The app's on/off switch lives here. |
| R16 | Summary page | As `08-SUMMARY-PAGE-PLAN.md`: period tabs with elapsed underline, day pills, ranked donut with three-line centre, app cards with share and hairline bar. Replaces the earlier All apps screen. Draft. |
| R17 | Focus effect and motion | Tap-to-focus on Summary (donut + cards), App detail bars (linked day text) and Home rows (press state); rings and bars draw in on appear; Reduce Motion honoured. Unproven on device. |

**Zone thresholds (default, adjustable in one constants file)**

| Zone | Rule | Colour |
| --- | --- | --- |
| Comfortable | Under 75% of target | Green |
| Approaching | 75% to 100% of target | Amber |
| Critical | Over 100% of target | Red |

**Per-app alerts are out of scope for version 1:** the six checkpoint events stay tied to the overall target only (see R9 and the monitor-extension rules).

**Out of scope for version 1:** blocking or locking apps, Android, iPad layout, accounts, cloud sync, widgets, sharing or exporting figures. Planned for version 1.1: Lock Screen and Home Screen widget showing the current zone, and a count of green days in a row.

## Platform constraints

These are Apple's rules for the Screen Time API (FamilyControls, DeviceActivity, ManagedSettings). The developer should read them before writing code, because each one removes an otherwise obvious design.

| Constraint | What it means for this app |
| --- | --- |
| Usage data is sealed in the report extension | The DeviceActivityReport extension can compute and draw per-app usage, and Apple confirms it is deliberately sandboxed so that data stays out of the containing app. Network calls and writes to the shared App Group from inside it are blocked. All charts and totals are therefore SwiftUI views inside that extension. |
| The extension can still read shared settings | Developers report that App Group reads succeed while writes are dropped. The main app writes the target, the switch states and the zone thresholds; the extension reads them to colour its charts. Verify this in Session 2 before building further. |
| Apps are opaque tokens | The code never sees "TikTok" or a bundle ID. The user must select apps through `FamilyActivityPicker`; the app stores `ApplicationToken` values. Apps cannot be pre-ticked in code. |
| Icons and names via `Label(token)` | iOS renders the real icon and name for a token. Use this everywhere in place of bundled logo artwork. |
| The only usage signal the main app can receive is a threshold event | A DeviceActivityMonitor extension is woken when cumulative usage crosses a set threshold. This drives the amber and red notifications. Developers have reported over-counting in this extension on some iOS releases, so charts stay the source of truth. |
| Entitlement per bundle ID | Family Controls (Development) works at once on the developer's own devices. Family Controls (Distribution) is needed for TestFlight and the App Store, and Apple states it must be requested for the app and for every extension that uses it. |
| Physical device needed | Screen Time data and extension behaviour should be tested on real iPhones; plan for at least two iOS versions. |
| Foreground time only | Usage counts while the app is on screen. YouTube audio playing in the background or in Picture in Picture may be counted differently; test and document the observed behaviour. |
| History depth is set by iOS | The monthly view depends on how far back the system returns data. Measure this on a test device in Session 4; if it is shorter than a month, the monthly view shows whatever is available with a note. |

## Background operation and access to other apps

The app itself does no background work. iOS records time on screen for every app continuously, and the system briefly wakes our small monitor extension only when a usage line is crossed. The app never connects to TikTok, Instagram, Facebook, X or YouTube: no sign-in, no link to those accounts, nothing read from inside them.

**What runs when**

| Situation | What happens | Who does the work |
| --- | --- | --- |
| App closed, phone in use | Foreground time for every app is recorded | iOS |
| A usage line is crossed (for example 75% of target) | `UsageMonitor` is woken for a moment, posts a notification, saves a checkpoint | iOS wakes the monitor extension |
| User opens the app | Fresh figures and charts are drawn | `UsageReport` extension |
| Switch or target changed | Monitoring is restarted with the new settings | Main app |
| Phone restarted | Monitoring should carry on with the app still closed; confirm on a test device | iOS |

Background App Refresh, location, VPN profiles and accessibility services are all unused, so battery cost is negligible and the App Store privacy label stays at "no data collected".

**Permissions the user grants**

| Permission | When it is asked | Needed for | If declined |
| --- | --- | --- | --- |
| Screen Time access (`.individual`) | Onboarding, after a plain-language card explaining what is seen | Everything | Friendly explainer with a retry button |
| Notifications | The first time the user switches alerts on, never at first launch | Zone alerts and recaps | App works fully, silently |

**How the other apps are reached**

- **Identity:** apps are opaque tokens chosen in Apple's picker. Create the selection with `FamilyActivitySelection(includeEntireCategory: true)` so that ticking the whole Social category returns a token for each app in it, giving one switch per app from a single tap. That flag is lost when the selection is saved and reloaded, so set it again after decoding.
- **Websites:** the picker can also return web domain tokens (for example youtube.com in Safari). Include them in the filter if the product owner wants browser use counted.
- **This phone only:** set the report filter's devices to iPhone so that iPad or Mac use shared through iCloud stays out of the totals.
- **Access withdrawn:** the user can switch access off under Settings › Screen Time › Apps With Screen Time Access. Developers report that the status the app reads can stay "approved" afterwards, and Apple's documentation says tokens issued earlier are voided. Check status every time the app comes to the foreground, treat an empty report as a second signal, and show a banner with a one-tap route to re-allow and re-pick apps.

**Apple's newer direct-data route (iOS 26.4 and later)**

Apple now offers a second route: a "Family Controls App and Website Usage" capability and `DeviceActivityData.activityData(filteredBy:using:)`, which hand usage figures straight to the app. Apple's documentation limits customer use to devices located in the EU with an EU Apple Account; elsewhere, including the UK, the call throws an error. Version 1 therefore keeps the sealed-extension design and leaves this capability switched off.

Two traps for the developer:

- Development builds get direct data access in any region, so the route appears to work on a UK test phone and then fails for App Store customers.
- Developers report that adding the capability changes the consent prompt on iOS 26.4 and later, and that Apple's own Screen Time pane stops showing new usage while the app holds that access.

A later EU edition could use this route for a home-screen widget and unlimited history.

**Rules for the monitor extension**

- **Keep it tiny.** Developers report a memory ceiling of about 6 MB. Import Foundation and UserNotifications only; no SwiftUI, Swift Charts or database code.
- **Count from the start of the day.** Build every event with `includesPastActivity: true` (iOS 17.4 and later), so changing a switch at 4 pm keeps the morning's usage in the count.
- **Six checkpoints, one schedule.** Events at 25, 50, 75, 100, 125 and 150% of target on a repeating midnight-to-midnight schedule. Each one saves `lastCheckpoint` (date and percentage) to the App Group, giving the main app an approximate reading for recap messages.
- **Sanity guard.** Apple has acknowledged an issue on iOS 26.x where threshold events fire early, often at the first pick-up of the day. Ignore any event whose usage figure exceeds the time elapsed since midnight, word alerts as "about", and have every alert open the Today ring, which always shows the accurate figure.

## Architecture

Swift and SwiftUI throughout, minimum iOS 17.4, one Xcode project with three targets sharing one App Group.

| Target | Type | Responsibility | Frameworks |
| --- | --- | --- | --- |
| `SocialTimeMonitor` | Main app | Onboarding, permission, app picker, switches, target entry, settings, hosts the report views, schedules monitoring | SwiftUI, FamilyControls, DeviceActivity, UserNotifications |
| `UsageReport` | DeviceActivityReport extension | Reads usage, applies switch filter, computes totals and zones, draws every chart and figure | DeviceActivity, SwiftUI, Swift Charts, ManagedSettings (tokens) |
| `UsageMonitor` | DeviceActivityMonitor extension | Receives threshold events, posts amber and red notifications, records last zone reached | DeviceActivity, UserNotifications |
| `Shared` | Swift package or shared group | Settings model, zone calculator, colour palette, App Group keys | Foundation, SwiftUI |

**Data flow**

1. User grants Screen Time permission: `AuthorizationCenter.shared.requestAuthorization(for: .individual)`.
2. User picks apps in `FamilyActivityPicker`, bound to `FamilyActivitySelection(includeEntireCategory: true)`. The selection is encoded and saved to App Group `UserDefaults`.
3. Each switch updates an `enabledTokens` set in the same store. Master switch sets `monitoringEnabled`.
4. User sets the target. Main app saves `targetMode` (daily or weekly) and `targetMinutes`.
5. Main app builds a `DeviceActivityFilter` (segment, date interval, iPhone only, enabled application tokens) and embeds `DeviceActivityReport(context, filter:)` in its screens.
6. iOS launches `UsageReport`, which receives the activity results, reads the target from the App Group, and renders the view shown inside the main app.
7. Main app calls `DeviceActivityCenter().startMonitoring` with a repeating schedule and six checkpoint events (25% to 150% of target) on the enabled tokens, each with `includesPastActivity: true`. Restarts are debounced by one second, so flipping several switches triggers a single restart.
8. When a checkpoint is crossed, `UsageMonitor.eventDidReachThreshold` saves `lastCheckpoint` and, at 75% and 100%, posts a local notification.
9. Every time the app returns to the foreground it re-checks authorisation and shows the access banner if needed.

**Report contexts** (one `DeviceActivityReportScene` each): `homeTotal`, `appRow`, `appDetail`, `summary`. `homeTotal` and `appRow` use `.daily(during: today)`; `appDetail` and `summary` use the interval for the chosen period (`.daily` segments for the 7-day and month views). The `summary` context draws the ranked donut, centre text and app cards in one report.

**Storage:** App Group `UserDefaults` only. No database and no network layer are needed in version 1.

## Data model and zone logic

**Shared settings (App Group `UserDefaults`, written by the main app, except `lastCheckpoint`)**

| Key | Type | Purpose |
| --- | --- | --- |
| `selection` | `Data` (encoded `FamilyActivitySelection`) | Every app the user has picked |
| `enabledTokens` | `Data` (encoded `Set<ApplicationToken>`) | Apps whose switch is on |
| `monitoringEnabled` | `Bool` | Master switch |
| `targetMode` | `String` (`daily` or `weekly`) | Which target applies |
| `targetMinutes` | `Int` | Target in minutes for the chosen mode |
| `amberFraction` | `Double` (default 0.75) | Where amber begins |
| `alertsEnabled` | `Bool` | Zone notifications on or off |
| `weekStartsOn` | `Int` | Week start day, Monday by default, follows device locale |
| `recapsEnabled` | `Bool` | Evening and Sunday recap notifications on or off |
| `orderedTokens` | `Data` (encoded `[ApplicationToken]`) | Row order and donut colour index |
| `appTargets` | `Data` (encoded array of token + minutes) | Optional daily target per app |
| `detailToken` | `Data` (encoded `ApplicationToken`) | App whose detail screen is open |
| `statsPeriod` | `String` (`today`, `week`, `month`) | Period chosen on App detail |
| `summaryPeriod` | `String` (`daily`, `weekly`, `monthly`, `yearly`) | Period chosen on Summary |
| `summaryDay` | `Double` (days since epoch at midnight) | Day pill chosen on Summary (Daily view) |
| `lastCheckpoint` | `Data` (date + percentage) | Written by `UsageMonitor` only; approximate reading for recaps |

**Zone calculator (in `Shared`, unit tested, used by both extensions)**

```swift
enum Zone { case green, amber, red }

func zone(usedMinutes: Double, allowanceMinutes: Double, amberFraction: Double) -> Zone {
    guard allowanceMinutes > 0 else { return .green }
    let ratio = usedMinutes / allowanceMinutes
    if ratio > 1.0 { return .red }
    if ratio >= amberFraction { return .amber }
    return .green
}
```

**Which allowance each view compares against**

| View | Daily mode | Weekly mode |
| --- | --- | --- |
| Today ring | Today's total vs daily target | Week-to-date total vs weekly target |
| Hourly bars | Running total through the day vs daily target | Running total vs weekly target ÷ 7 |
| Daily bars | Each day vs daily target | Each day vs weekly target ÷ 7 |
| Weekly bars | Each week vs daily target × 7 | Each week vs weekly target |
| Monthly | Average per day vs daily target | Average per week vs weekly target |
| Weekly average line | Week-to-date ÷ days elapsed vs daily target | Same, vs weekly target ÷ 7 |

Per-app rows show time and share of total only; zones apply to the combined total, since the target is one figure across all monitored apps.

## Screen specification

Three tabs: **Apps**, **Summary**, **Target**. Home (Apps tab) and App detail follow **`design/DESIGN-NOTES.md`** (18 November, simplified); the Stats tab is the **Summary page** per `08-SUMMARY-PAGE-PLAN.md` (25 November: it replaced the earlier All apps screen). Exact sizes, spacing, copy and colours live in `design/reference/*.dc.html` and `SKINS/`. Build exactly what those notes show; nothing extra.

| Screen | Contents | Built in |
| --- | --- | --- |
| Onboarding (4 cards) | What the app does; what the app sees and never sees, then the system prompt; app picker (hint: tick Social and YouTube); target presets | Main app |
| Home (Apps tab) | Per `DESIGN-NOTES.md`: "Today" + date, `homeTotal` report card, card of app rows (icon, name, time, thin bar via `appRow`) | Report card + row time/bar in `UsageReport`; rows and navigation in main app |
| App detail | Per `DESIGN-NOTES.md`: back, icon, name, on/off switch, `appDetail` report (today card, period card, two stats), target button | Report in `UsageReport`; chrome in main app |
| Summary (Stats tab) | Per `08-SUMMARY-PAGE-PLAN.md` §3: period tabs with elapsed underline, day pills (Daily), one `summary` report (ranked donut with three-line centre, app cards with share and hairline bar), focus on tap | Donut + cards in `UsageReport`; tabs and pills in main app |
| Target | Overall target: Daily or Weekly selector, presets 1h–4h a day, custom stepper (15-minute steps), live three-zone strip; master Monitoring switch; alerts switch; recaps switch; link to Settings | Main app |
| Settings (from Target) | Amber threshold slider, week start day, permission status, privacy statement | Main app |

The per-app on/off switch lives on **App detail** (not on the Home row); the master switch lives on the **Target** tab.

**Visual rules**

- Zone colours: always the semantic system colours — `Color(.systemGreen)`, `Color(.systemOrange)`, `Color(.systemRed)` — never hard-coded hex. Semantic colours pick up Apple's dark-mode and Increase Contrast variants automatically. Amber uses *orange*, not yellow, so the green→amber→red ordering stays readable for the most common colour-vision deficiencies. The donut palette is the eight categorical colours in `DESIGN-NOTES.md`, as named asset colours.
- Every zone also carries a word, so meaning never rests on colour alone.
- Empty states: before permission, before any app is picked, and before any usage is recorded each get one friendly line and one button.
- The report views load asynchronously; show a placeholder of the same size so the layout holds steady.
- Build every screen with Dynamic Type and VoiceOver from the first pass — retrofitting accessibility inside the report extension is the most expensive place to do it.
- Times read "2h 14m" everywhere (whole hours drop the minutes: "1h", "10h"); the status line reads "Getting close · 14m left".

**Build efficiencies**

- One `Aggregator` walks the activity results for all scenes; scenes compute configurations, views only render.
- One `SharedSettings` type in `Shared` is the single reader and writer of App Group keys for all three targets.
- Zone colours, wording and symbols live in one `ZoneStyle` file used by the app and `UsageReport`.

## Build phases

Durations are estimates for one experienced iOS developer; Apple's entitlement review runs in parallel and has its own timetable.

| Phase | Est. | Tasks | Done when |
| --- | --- | --- | --- |
| 0. Foundations | 2–3 days | Bundle IDs for app and both extensions; App Group; Family Controls (Development) on all three; submit the Family Controls (Distribution) request for all three bundle IDs; three targets and `Shared` module | Project builds to a physical iPhone; entitlement requests submitted |
| 1. Proof of data path | 4–5 days | Bare permission request and picker; `UsageReport` extension with `todaySummary` context; filter by enabled tokens, iPhone only; read target from App Group inside the extension; render the Today ring | Ring matches iOS Settings › Screen Time for the same apps within a minute or two; removing an app removes its time |
| 2. Onboarding and switches | 4–5 days | Onboarding cards with plain-language permission card; category-aware picker; Apps screen rows with `Label(token)` and switches; master switch; access health banner | Setup completes in under a minute; switch states survive relaunch; banner appears when access is switched off |
| 3. Statistics | 5–7 days | One `PeriodChartView` for Hour, Day, Week, Month; period navigation; totals, averages, per-app list; measure history depth | All four views render correct figures on two iOS versions; empty and loading states in place |
| 4. Target and zones | 3–4 days | Target screen with presets; `Zone` calculator with unit tests; zone colouring, target line, time remaining and weekly average in all report views | Changing the target recolours every view; unit tests cover boundaries at 75% and 100% |
| 5. Alerts and background checks | 4–5 days | `UsageMonitor` extension within the memory ceiling; six checkpoint events with `includesPastActivity`; debounced restart; sanity guard; local notifications and recaps; test with app closed, after restart, and across midnight | Amber and red alerts arrive with the app closed; monitoring survives a phone restart; no alert fires before real usage reaches the line on the test devices |
| 6. Polish and release | 5–7 days | Accessibility (Dynamic Type, VoiceOver labels on charts), dark mode, app icon, privacy text, privacy manifest, TestFlight round, App Store listing and review notes | TestFlight build approved by the product owner; submitted for review |

Total: roughly 5 to 7 working weeks of development.

**Order matters:** Phase 1 is the technical proof and comes before any interface polish. If the ring shows correct, filtered, target-coloured data on a real device, the remaining phases are straightforward interface work. `02-SESSION-TASKS.md` splits these phases into build sessions.

## Testing, release and open decisions

**Test plan**

- Unit tests: zone calculator, target conversions (daily to weekly and back), week boundaries.
- Device tests: compare each view with iOS Settings › Screen Time; toggle switches mid-day; change target mid-day; cross midnight and week start; revoke and re-grant permission; reinstall.
- Known platform quirks to check on each iOS version: report view staying blank after returning from background, and threshold events firing early.

**App Store**

- Review notes should explain that the app uses Screen Time for the user's own self-monitoring (`.individual` authorisation) and that usage data stays on the device.
- Privacy label: no data collected.
- Avoid third-party brand names and logos in the app icon, screenshots and listing text; show the user's own icon rows as rendered by iOS.

**Risks**

| Risk | Likelihood | Response |
| --- | --- | --- |
| Distribution entitlement for extensions is slow to arrive | Medium | Apply in Phase 0; continue development on the Development entitlement |
| Monthly history shorter than a month | Medium | Show available days with a note; a later version can build longer history from daily threshold events |
| Threshold alerts fire early (issue acknowledged by Apple on iOS 26.x) | Medium | Sanity guard in the monitor; word alerts as approximate; every alert opens the accurate ring |
| App keeps reading "approved" after access is switched off in Settings | Medium | Re-check on every foreground; treat an empty report as a second signal; access banner |
| Developer builds against the EU-only direct-data route by mistake | Low | Capability stays switched off; rule stated in every session brief |
| Extension cannot read App Group settings on a future iOS release | Low | Fallback: pass target and switches through the report filter and context name |
| Family Controls (Distribution) entitlement denied outright | Low | Self-monitoring with `.individual` authorisation is an accepted pattern, so denial is unlikely; if it happens, decide early between appealing and pivoting to a manual-timer companion app — a major scope change |
| No build Mac: release uploads require Xcode this hardware cannot run | High | App Store uploads require Xcode 26+ (Xcode 26.3 needs macOS Sequoia 15.6+), and from April 2027 uploads require Xcode 27, which installs only on Apple silicon Macs. The 2016 Intel MacBook Pro used for coding tops out at macOS 12 / Xcode 14.2, so it writes code and runs `swift test` only. Every Xcode build, device gate and upload needs a 2018+ or Apple silicon Mac |

**Open decisions for the product owner**

- [ ] Confirm the amber zone at 75% of target, or choose green and red only
- [ ] App name and icon
- [ ] Free, paid, or subscription
- [ ] Should websites (for example youtube.com in Safari) count towards the total in version 1? **Research verdict (docs/monitoring-analysis.md, 18 Nov): keep app-only for v1; add web domains as an opt-in v1.1 with domains shown as their own rows, never merged with app figures; never select browser app tokens alongside domains (over-counts). Private tabs and some browsers can never report domains.**
- [ ] Launch countries: UK first, or UK and EU together? An EU release opens the direct-data route for a later edition.
- [ ] Recap notifications on or off by default?

**Android later:** Android's `UsageStatsManager` gives the app direct access to usage figures, so the Android version can share the screen designs and zone logic but will use a simpler, single-app architecture.

## Sources

- [Apple Developer Forums: report extension is intentionally sandboxed](https://developer.apple.com/forums/thread/818174)
- [Apple Developer Forums: report extension writes to App Group denied](https://developer.apple.com/forums/thread/834794)
- [Apple Developer Forums: Family Controls (Distribution) needed for each extension](https://developer.apple.com/forums/thread/813073)
- [Apple Developer Forums: DeviceActivityMonitor over-counting report](https://developer.apple.com/forums/thread/763542?answerId=805014022)
- [Apple Developer Forums: Screen Time tag (current issues)](https://developer.apple.com/forums/tags/screen-time)
- [Apple documentation: activityData(filteredBy:using:), iOS 26.4, EU customer limit](https://developer.apple.com/documentation/deviceactivity/deviceactivitydata/activitydata(filteredby:using:))
- [Apple documentation: Family Controls App and Website Usage entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.family-controls.app-and-website-usage)
- [Apple documentation: FamilyActivitySelection](https://developer.apple.com/documentation/familycontrols/familyactivityselection)
- [Apple Developer Forums: early threshold events on iOS 26.x, acknowledged by Apple](https://developer.apple.com/forums/thread/809410)
- [Apple Developer Forums: includesPastActivity from iOS 17.4](https://developer.apple.com/forums/thread/762137)
- [Apple Developer Forums: monitor extension 6 MB memory limit](https://developer.apple.com/forums/thread/735454)
- [Apple Developer Forums: access withdrawal while the app is in the background](https://developer.apple.com/forums/thread/820796)
- [Apple Developer Forums: includeEntireCategory returns app tokens for a category](https://developer.apple.com/forums/thread/724419)
