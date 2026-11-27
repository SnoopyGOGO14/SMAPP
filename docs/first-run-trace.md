# First-run trace — the live path, checked by reading (Part 5)

Only demo mode has ever been seen running. This is the one path a
first on-phone run takes, read line by line; every hop is named so a
device failure can be located in one grep. No dead-ends found; two
soft notes at the end.

## 5.1 Launch → onboarding → Home

1. `SocialTimeMonitorApp.mainContent`: `showOnboarding` is true
   (fresh App Group: `onboardingCompleted` false) → `OnboardingFlow`.
2. Card 2 "Allow Screen Time access" → `requestAuthorization()`
   (`AuthorizationCenter`, `.individual`); on grant the status refresh
   and the flow advances to page 3.
3. Card 3 "Choose apps" → `showPicker = true` → the system
   `familyActivityPicker` sheet (`.familyActivityPicker`, bound to
   `$state.selection`); on close, `onChange(of: appState.selection)`
   → `syncFromSelection()` — ordered/enabled tokens + targets persist
   to the App Group. With apps chosen the button reads "Continue" →
   page 4.
4. Card 4 preset (or "Choose my own") → `setTargetMinutes` +
   `completeOnboarding()` (marks `onboardingCompleted`, syncs again)
   → `RootTabs`.
5. `.task` on appear: `refreshAuthorizationStatus`,
   `startDayRolloverWatch`, `topUpIfMissing()` → no `.daily` activity
   running → `restart()` — `monitoringEnabled` (default true),
   `enabledTokens` (now non-empty), `targetMinutes` (set) → six
   checkpoint events registered. ✓ the monitor is live before Home
   draws.

## 5.2 Home with real tokens

- `HomeScreen`: `monitoringEnabled` true → `homeCard` →
  `reportHomeCard` → `DeviceActivityReport(.homeTotal,
  Filters.homeTotal(enabled:mode:))` — today's interval (or the week
  in weekly mode), enabled tokens, iPhone-only.
- `showsSetTargetButton`: target set → hidden. ✓
- `appsCard` → `tokensRows` → `AppUsageRow` per ordered token: the
  row is a `NavigationLink(value: token)`; inside, `AppRowShell` lays
  the label over the `appRow` report (one per row; the report has
  `.allowsHitTesting(false)` so the link receives the tap).
- Row tap → `navigationDestination(for: ApplicationToken.self)` →
  `AppDetailScreen(token:)` — writes `detailToken`, embeds the
  `appDetail` report with the `.hourly` segment on Daily.
- Empty states: no apps → the empty card + banner; no access → the
  banner with Allow → `requestAuthorization()` again.

## 5.3 Summary

`RootTabs` tab 1 → `SummaryScreen`: `liveReport` →
`DeviceActivityReport(.summary, Filters.summary(enabled:period:week))`;
period tabs (`PeriodTabsControl`); day pills on Daily (`DayPillsRow`,
UK calendar); Monthly gated by `historyDays` only if the switch is
on (default off).

## 5.4 Target change → alert

`setTargetMinutes` → App Group write → `MonitoringScheduler
.restartDebounced()` (1 s) → events rebuilt at the new thresholds →
crossing 75%/100% wakes `UsageMonitor` → sanity guard → alert ledger
→ local notification (permission is requested the first time the
owner switches Zone alerts on, on the Target tab — it is off by
default). Tapping the alert posts `openAppsTab` → RootTabs selects
the Apps tab.

## 5.5 Live vs demo — every difference

| Where | Demo mode | Live |
| --- | --- | --- |
| Onboarding | bypassed (`-screen` routes direct) | full flow, real permission prompt |
| Reports | `DemoData` configurations drawn by the same views | `DeviceActivityReport` embeds; figures arrive async |
| Access banner | only the `noapps`/`noaccess` states | `showAccessBanner` whenever access is off or no apps |
| Home hero | `HeroCardView` directly, sample figures | report with a 168 pt frame; placeholder until data lands |
| Monitor | never started (demo routing skips `.task`? — no: `.task` still runs, but demo routing replaces the view tree; `topUpIfMissing` runs identically and is harmless with no tokens selected | started at the end of onboarding |
| Marker file | written per screen (self-check) | never written (release: no demo code) |

**Two soft notes, neither a dead-end:**
1. The `.task`'s `topUpIfMissing()` also runs during onboarding (it
   stops nothing and starts nothing without tokens/target) — verified
   harmless by reading `restart()`'s guards.
2. `syncFromSelection` fires from both OnboardingFlow and HomeScreen
   on the same selection change — idempotent (the same cleanup twice).
