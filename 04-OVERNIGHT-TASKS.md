# Overnight task list for GLM — 18 November 2026

Work through Blocks A to G in order. Commit after every task with a clear message. Update `PROGRESS.md` at the end of every block. Read `design/DESIGN-NOTES.md` before Block B.

## Ground rules for tonight

1. This Mac (2016, macOS 12, Swift 5.7) can run `swift test` on `Packages/Core` and nothing else. Everything in `Core` is verified locally. Everything iOS-specific is verified by the cloud build in Block A.
2. Three honesty levels, used exactly in `PROGRESS.md`: **tested** (unit tests pass), **compiles** (cloud build succeeded), **unverified on device** (every Screen Time behaviour until a person runs it on an iPhone). Device gates A to D stay open. Never record one as passed.
3. The gate rule is relaxed for tonight only: code for later sessions may be written and must compile. It is marked "unverified on device".
4. Standing rules in `00-README-START-HERE.md` still apply: usage figures drawn only in `UsageReport`; "Family Controls App and Website Usage" capability stays off; Apple frameworks only; `UsageMonitor` imports Foundation, DeviceActivity, UserNotifications only.
5. Check every Screen Time signature against Apple's documentation (add `.md` to the page address) before using it. Record each page checked.
6. Cloud build budget: **12 runs maximum tonight**. Batch changes; build after a block, never after each file. Put `[skip ci]` in the message of commits that change only Markdown, `docs/`, `design/` or `Packages/Core`.
7. Stop conditions: the same build error three times running; the build budget spent; anything that needs the person (portal, signing, a device). Record where you stopped and why, then continue with the next block that has no such dependency.
8. Simplicity is a requirement. Build exactly what `design/DESIGN-NOTES.md` shows. Add no extra labels, badges, stats or controls.

---

## Block A — Cloud build loop (do this first; it unlocks everything else)

**Goal:** every push to `main` compiles all three targets on a GitHub-hosted Mac and writes the result to a branch GLM can read over SSH.

- [ ] A1. In `project.yml`, give the app target a shared scheme (`scheme: {}` under the target) so `xcodebuild -scheme` finds it. Confirm the project `name:`; the workflow below assumes `SocialTimeMonitor`.
- [ ] A2. Create `.github/workflows/build.yml`:

```yaml
name: build
on:
  push:
    branches: [main]
    paths-ignore: ['**.md', 'docs/**', 'design/**', 'archive/**']
  workflow_dispatch:
concurrency:
  group: build-${{ github.ref }}
  cancel-in-progress: true
permissions:
  contents: write
jobs:
  build:
    runs-on: macos-26
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - name: Toolchain
        run: |
          xcodebuild -version | tee ci-toolchain.log
          brew install xcodegen
      - name: Core tests
        run: |
          set -o pipefail
          swift test --package-path Packages/Core 2>&1 | tee ci-core-tests.log
      - name: Generate project
        run: |
          set -o pipefail
          xcodegen generate 2>&1 | tee ci-xcodegen.log
      - name: Build for simulator
        run: |
          set -o pipefail
          xcodebuild build -project SocialTimeMonitor.xcodeproj -scheme SocialTimeMonitor \
            -destination 'generic/platform=iOS Simulator' \
            CODE_SIGNING_ALLOWED=NO 2>&1 | tee ci-build-full.log
      - name: Publish logs to ci-logs branch
        if: always()
        run: |
          mkdir out
          cp ci-*.log out/ 2>/dev/null || true
          grep -hE "error:|warning:|BUILD (SUCCEEDED|FAILED)|Executed .* tests|Unrecognized|not found" out/*.log > out/SUMMARY.txt 2>/dev/null || true
          echo "commit: $GITHUB_SHA status: ${{ job.status }} run: $GITHUB_RUN_NUMBER" >> out/SUMMARY.txt
          cd out
          git init -q -b ci-logs
          git config user.name ci
          git config user.email ci@users.noreply.github.com
          git add .
          git commit -qm "logs for $GITHUB_SHA"
          git push -f "https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}.git" ci-logs
```

- [ ] A3. Push. Then poll: `git fetch origin ci-logs` every 60 seconds for up to 15 minutes; read `git show origin/ci-logs:SUMMARY.txt`; confirm its `commit:` line matches the pushed commit before trusting it.
- [ ] A4. Fix until the Session 0 scaffold shows `BUILD SUCCEEDED`. Expect the first failures to be the XcodeGen target type for the report extension and the extension Info.plist keys; the log is the authority. Record the working values in `PROGRESS.md`.
- [ ] A5. Write `docs/ci.md`: how the loop works, the 12-run nightly budget, how the person can read results (repo › Actions tab, or the `ci-logs` branch).

**If no `ci-logs` branch appears after two pushes:** Actions may be disabled, out of minutes, or blocked from writing. Record it under "Waiting on the person" (ask them to open the repo's Actions tab), then do Blocks B and C fully, and write Blocks D to F as uncompiled drafts on a branch named `draft/uncompiled` instead of `main`.

**Done when:** `SUMMARY.txt` for the latest `main` commit shows the Core tests passing and `BUILD SUCCEEDED`.

---

## Block B — Bring the spec in line with the approved designs

- [ ] B1. Commit `design/DESIGN-NOTES.md`, `design/reference/*.dc.html`, this file and `SESSION-HANDOFF.md` (`[skip ci]`).
- [ ] B2. In `01-BUILD-SPEC-v2.md` add requirements:
  - R14 Per-app target: optional daily target per app, alongside the overall target. An app with none shows a neutral bar.
  - R15 App detail screen: as `DESIGN-NOTES.md`.
  - R16 All apps screen: donut of time per platform, as `DESIGN-NOTES.md`. It replaces the earlier Stats tab layout.
- [ ] B3. Replace the spec's "Screen specification" section with a pointer to `design/DESIGN-NOTES.md` plus the Target tab description (overall target, presets, master switch, alerts and recaps switches, settings). Move the per-app switch to App detail.
- [ ] B4. Data model table, add keys (all written by the main app):

| Key | Type | Purpose |
| --- | --- | --- |
| `orderedTokens` | `Data` (encoded `[ApplicationToken]`) | Row order and donut colour index |
| `appTargets` | `Data` (encoded array of token + minutes) | Optional daily target per app |
| `detailToken` | `Data` (encoded `ApplicationToken`) | App whose detail screen is open |
| `statsPeriod` | `String` (`today`, `week`, `month`) | Period chosen on All apps and App detail |

- [ ] B5. Report contexts become: `homeTotal`, `appRow`, `appTime`, `appDetail`, `allApps`. Remove the old `todaySummary`, `hourly`, `daily`, `weekly`, `monthly` list and update the data-flow steps.
- [ ] B6. Per-app alerts are out of scope for version 1: the six checkpoint events stay tied to the overall target. Say so in the spec.
- [ ] B7. Update `02-SESSION-TASKS.md` Sessions 2 to 5 and `03-ENGINEER-CHECKLISTS.md` sections 5 and 8 to match. Add to the device test matrix: "Home with five embedded row reports loads within two seconds" and "tapping a row opens App detail".

**Done when:** spec, session file and checklists describe the three approved screens and nothing contradicts `DESIGN-NOTES.md`.

---

## Block C — Core additions (tested on this Mac)

Swift 5.7, Foundation only, in `Packages/Core/Sources/Core/`.

| File | Contents | Tests (minimum) |
| --- | --- | --- |
| `DurationParts.swift` | seconds → days, hours, minutes, seconds; formatted "0d 6h 13m 40s" | 0 s; 59 s; 22,420 s → 0d 6h 13m 40s; 93,784 s → 1d 2h 3m 4s |
| `BarGeometry.swift` | fill fraction and marker fraction for a bar: `scaleMultiple` 4/3 for the total, 1.5 for an app; fill clamped to 1.0; no target → fill relative to the largest app that day, no marker | 166 of 180 min → fill 0.692, marker 0.75; 58 of 60 → 0.644, 0.667; over-scale clamps; no target |
| `AppZone.swift` | zone for an app against its own target, with a `neutral` case when it has none; reuses the amber fraction | 58/60 amber; 52/45 red; 31/60 green; nil target neutral |
| `StatusLine.swift` | "Getting close · 14m left", "Over target · by 7m", "Comfortable · 29m left"; empty for neutral | each zone; exactly on target |
| `DonutMath.swift` | segments from per-app seconds: fraction of total, start and end angle, palette index; apps with zero time omitted; total zero → empty | 58, 52, 31, 14, 11 min → fractions sum to 1.0; order preserved; zero total |
| `PeriodStats.swift` | from daily totals: daily average, days within target, longest day | sample week 44, 61, 38, 82, 49, 41, 58 with a 60 min target → average 53, 5 of 7, longest 82 |
| `Palette.swift` | eight palette names; `index(for position:)` wraps at 8 | positions 0, 7, 8, 15 |
| `SettingsKeys.swift` | add the four keys from B4 | n/a |

- [ ] C1. Write the files and tests. Qualify calls with `Core.` inside test classes where a name collides with `NSObject` (as found in Session 1).
- [ ] C2. `swift test` passes; paste the summary line into `PROGRESS.md`. Commit with `[skip ci]`.

**Done when:** all Core tests pass locally.

---

## Block D — Shared iOS layer and the report extension (compiles; unverified on device)

| File | Contents |
| --- | --- |
| `Shared/SharedSettings.swift` | Typed access to every App Group key. Encodes tokens with `PropertyListEncoder`. Rebuilds a decoded selection with `includeEntireCategory: true`. Helpers: `target(for token)`, `paletteIndex(for token)`. |
| `Shared/ReportContexts.swift` | The five contexts from B5. |
| `Shared/ZoneStyle.swift` | Colour (semantic system colours), word and symbol per zone, plus neutral. App and `UsageReport` only. |
| `Shared/PaletteColors.swift` | Named asset colours for the eight donut colours. |
| `UsageReport/UsageReportExtension.swift` | `@main`; lists five scenes. |
| `UsageReport/Aggregator.swift` | One place that walks `DeviceActivityResults<DeviceActivityData>` → segments → categories → applications and returns plain structs: seconds per token, seconds per day, seconds per hour. All scenes use it. |
| `UsageReport/HomeTotalScene.swift` + view | Hero total, "of 3h", bar, status line. |
| `UsageReport/AppRowScene.swift` + view | Time and thin bar for one token. |
| `UsageReport/AppTimeScene.swift` + view | Time only, right-aligned. |
| `UsageReport/AppDetailScene.swift` + view | Today card; period card (d h m s line, Swift Charts bars, dashed target rule, today outlined); two stats. |
| `UsageReport/AllAppsScene.swift` + view | Donut with Swift Charts `SectorMark`, centre total. |
| `UsageReport/BarView.swift` | Reusable bar with optional marker, driven by `BarGeometry`. |

- [ ] D1. Verify against Apple's pages before writing: `DeviceActivityReportScene`, `DeviceActivityResults`, `DeviceActivityData`, `DeviceActivityFilter`, `ApplicationActivity`, `SectorMark`.
- [ ] D2. Scenes compute everything in `makeConfiguration` using `Aggregator` and `Core`; views only render a configuration struct.
- [ ] D3. The extension reads the App Group and never writes to it.
- [ ] D4. Every view: Dynamic Type text styles, VoiceOver label summarising the figure and zone, placeholder of the same size while loading, plain empty state.
- [ ] D5. Push; read the build result; fix. Budget: 4 runs.

**Done when:** build succeeds with all five scenes.

---

## Block E — Main app screens (compiles; unverified on device)

| File | Contents |
| --- | --- |
| `App/AppState.swift` | Observable model (use `ObservableObject` if `@Observable` causes trouble): authorisation status, selection, ordered tokens, enabled tokens, targets, period. Saves through `SharedSettings`. |
| `App/RootTabs.swift` | Tabs: Apps, Stats, Target. |
| `App/Onboarding/OnboardingFlow.swift` | Four plain cards: what it does; what the app sees and never sees, then the system prompt; pick apps (hint: tick Social and YouTube); choose a target preset. |
| `App/Home/HomeScreen.swift` | Per `DESIGN-NOTES.md`: title, embedded `homeTotal` report, card of rows. |
| `App/Home/AppUsageRow.swift` | `NavigationLink` row: `Label(token)` icon and name from the host; embedded `appRow` report with `.allowsHitTesting(false)`. A `timeOnly` style embeds `appTime` instead and shows a palette dot. |
| `App/Detail/AppDetailScreen.swift` | Back, title, on/off switch, period switch, embedded `appDetail` report, target button. Writes `detailToken` and `statsPeriod` before the report appears. |
| `App/Detail/AppTargetSheet.swift` | Stepper in 15-minute steps, presets 30m, 45m, 1h, 1h 30m, "Remove target". |
| `App/Stats/AllAppsScreen.swift` | Title, period switch, embedded `allApps` report, card of `AppUsageRow(style: .timeOnly)`. |
| `App/Target/TargetScreen.swift` | Overall target (daily or weekly, presets 1h to 4h, custom stepper), master Monitoring switch, alerts switch, recaps switch, link to settings. |
| `App/AccessBanner.swift` | Shown when access is off or no apps are chosen; one button. |
| `App/Filters.swift` | Builds each `DeviceActivityFilter`: iPhone only, tokens, segment and interval from `Core.PeriodMath`. |

- [ ] E1. Verify `AuthorizationCenter`, `FamilyActivityPicker`, `FamilyActivitySelection`, `DeviceActivityReport` (the SwiftUI view) and `Label` with a token against Apple's pages.
- [ ] E2. Re-check authorisation whenever the scene becomes active.
- [ ] E3. Switch off an app → removed from `enabledTokens`, row dims, filters update.
- [ ] E4. Colours and spacing from `DESIGN-NOTES.md`; light and dark asset colours; no element beyond what the notes list.
- [ ] E5. Push; read the build result; fix. Budget: 4 runs.

**Done when:** build succeeds; every screen in `DESIGN-NOTES.md` exists and is reachable from the tab bar or a row.

---

## Block F — Monitor and scheduling (only if Blocks A to E are done and build runs remain)

- [ ] F1. `App/Monitoring/MonitoringScheduler.swift`: daily or weekly schedule, six checkpoint events with `includesPastActivity: true`, restart debounced by one second, stop when the master switch is off. Verify `DeviceActivityCenter`, `DeviceActivitySchedule`, `DeviceActivityEvent` first.
- [ ] F2. `UsageMonitor/UsageMonitor.swift`: parse the percentage from the event name; sanity guard from `Core.Checkpoint`; save `lastCheckpoint`; local notification at 75 and 100. Foundation, DeviceActivity, UserNotifications only.
- [ ] F3. `App/Monitoring/NotificationManager.swift`: permission asked when alerts or recaps are first switched on; evening and Sunday recap; a tap opens the Apps tab.
- [ ] F4. Push; read the build result; fix. Budget: remaining runs.

**Done when:** build succeeds with the monitor in place.

---

## Block G — Morning report (always do this last)

- [ ] G1. `PROGRESS.md`: one table of every file written tonight with its level (tested, compiles, uncompiled draft), every Apple page checked, build runs used out of 12, and each deviation from this list with the reason.
- [ ] G2. `docs/device-checks.md`: the exact steps a person with a newer Mac and an iPhone follows for Gate A, including what to look for on Home (five embedded row reports), row taps, and the donut.
- [ ] G3. Update `SESSION-HANDOFF.md` sections 3 and 8 to the new state.
- [ ] G4. List open questions for the product owner at the top of `PROGRESS.md`.
- [ ] G5. Final commit and push. Stop.

## Waiting on the person (no action for GLM)

- A Mac that can run Xcode 26 (Apple silicon for the long run). Until then the cloud build is the only compiler.
- Apple Developer Program, portal steps, the organisation identifier for `YOURORG`.
- Whether the repo is public or private (private repos on the free plan get about 200 macOS build minutes a month).
