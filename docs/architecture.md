# Architecture

## What draws what

Apple seals per-app usage inside the Device Activity Report extension, so
the split is:

| Element | Drawn by |
| --- | --- |
| Home hero card (total, bar, status) | `UsageReport`, context `homeTotal` |
| Home row: icon, name, tap | Main app (`Label(applicationToken:)` in a `NavigationLink`) |
| Home row: time and thin bar | `UsageReport`, context `appRow`, one small report per row, hit testing off |
| App detail: today card, period card, stats | `UsageReport`, context `appDetail` |
| All apps: donut and centre total | `UsageReport`, context `allApps` |
| All apps row: time | `UsageReport`, context `appTime` |
| Navigation, switches, targets, period pickers | Main app |

The report extension reads settings from the App Group and **writes nothing**
(the sandbox drops writes). All computation happens in `makeConfiguration`
via `Aggregator`; the `SharedUI` views only render configuration structs —
which is also what demo mode feeds.

## App Group keys

`group.com.YOURORG.socialtimemonitor` (replace YOURORG everywhere):

| Key | Written by | Read by |
| --- | --- | --- |
| `selection`, `orderedTokens`, `enabledTokens`, `appTargets` | Main app | Report extension (rows, donut colours) |
| `monitoringEnabled`, `targetMode`, `targetMinutes`, `amberFraction` | Main app | Report + monitor extensions |
| `alertsEnabled`, `recapsEnabled`, `weekStartsOn`, `statsPeriod`, `detailToken` | Main app | Extensions |
| `lastCheckpoint` | **UsageMonitor only** | Main app (recaps, future widget) |

## Monitoring flow

1. Onboarding authorises with `.individual` and picks apps
   (`FamilyActivitySelection(includeEntireCategory: true)`).
2. `MonitoringScheduler` starts a repeating midnight-to-midnight
   `DeviceActivitySchedule` with six checkpoint events (`pct.25`…`pct.150`),
   each with `includesPastActivity: true`. Weekly mode adds a second
   activity spanning the user's week with thresholds on the weekly target.
3. Any settings change restarts monitoring, debounced to one second.
4. When a checkpoint is crossed, iOS wakes `UsageMonitor`:
   it parses the percent from the event name, applies the sanity guard
   (threshold minutes must not exceed minutes elapsed — guards the iOS 26.x
   early-fire issue), saves `lastCheckpoint`, and posts a local notification
   at 75% and 100% (worded as approximate).
5. Tapping an alert opens the Apps tab; the Home card is the accurate figure.

## Zones

Green under 75% of target, amber 75–100%, red over 100% (per-app targets use
the same fractions; apps without a target are neutral). Colours are semantic
system colours; all zone wording comes from `Core.StatusLine` /
`ZoneStyle` so it stays consistent.
