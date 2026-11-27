# Social Time Monitor (SMAPP) — session handoff

Written 17 November 2026, 23:20 UK time; updated after each run. Read this first when picking the project up, then `PROGRESS.md`.

## Todos — state at this handoff (25 November, after round-3 fixes)

1. **THE WORKING-APP PUSH IS DONE (27–28 November, Parts 1–6 of
   `13-WORKING-APP-PUSH.md`); the cloud never answered** — the probe
   (21:58) and every check before it published nothing since 26 Nov
   16:45. The repo is **SAFE TO MAKE PUBLIC** (Part 2's scan). The
   owner's moves, in order: make the repo public (or wait for the
   minutes to refill) → tell GLM **"repo is public, re-run the
   probe"** → then Part 3 resumes: fix-to-green (6-build budget), one
   `[screens]`, READY. In parallel: join the Developer Program and
   follow `docs/owner-steps.md` (the device build, the install, the
   Diagnostics report back). The app targets are 423 lines smaller
   (fallbacks parked in `parked/` with their triggers in
   `docs/later.md`). All locally verified: the
   Diagnostics screen (Gate A in ~30 minutes), a fallback per Gate A
   outcome (`Shared/FeatureSwitches.swift` +
   `docs/gate-a-outcomes.md`), `DECISIONS.md` for the owner, the
   release materials, and the quality pass (143 tests; the edge tests
   caught a real codec padding mismatch). **The cloud has been silent
   since 26 Nov 16:45** — check the Actions tab for the cause
   (queued/billing/pre-publish error). When it answers: Part 0.2 —
   plain push for green, one `[screens]` (core tier includes the
   Settings fixes and detail-a11y), "READY FOR VISUAL REVIEW,
   S-round". Until then everything after `d165792` is locally
   verified only. The round-6 review passed 36/36; the five Settings
   tidy items (S1–S5) are fixed in `d34d3de` — preflight clean, 124
   tests, parse-checked — but the cloud has published **no verdict
   for that commit in 45+ minutes** (every recent run answered in
   2–3). Check the Actions tab: a queued run, a billing stop, or a
   workflow error before the publish step all look identical from
   `ci-logs`. **When the cloud answers:** `d34d3de` needs no re-push;
   the next `[screens]` push delivers the round's captures (core tier
   now includes settings ×2 and detail-a11y), then raise REVIEW.md
   per NOTE.txt and the close below stands. Until then the S-fixes
   are locally verified only.
2. **Everything else is closed** (26 November): the full 36-capture
   manifest verified clean (screens run 40); builds green through
   run 39; rounds 3–6 of visual review passed. The remaining items
   are the person's: the build Mac (`tools/first-run.sh` day one,
   then `docs/gate-a-card.md`), Developer Program + portal steps, the
   organisation identifier, and the ASSUMED decisions. GLM resumes
   from Gate A results in `PROGRESS.md`.
2. **The billing-exhaustion diagnosis was wrong — the cloud never lost
   minutes.** The probe (run 24) answered in 3 minutes. If runs go
   quiet again, check the Actions tab before assuming billing.
3. **Budgets closed:** round-3 1/4 builds + 4/2 screens; X round 2/3 + 1/2; Z round 2/2 + 1/1 (one tuple-typing burn) (two over — my W6 workflow bug, a genuine W1 gap the duplicate-check caught, and a class-8 regression; all logged in `docs/ci.md`). New CI
   rules in `docs/ci.md`: preflight before every push (never pipe it
   through `tail`), never push while a run is in flight, `[screens]` =
   core 15 / `[screens-all]` = full manifest, and **never put the
   literal `[screens]` in a commit message unless a capture run is
   meant** (the 0003a8d lesson).
4. **Blocked on the person (unchanged):** a build Mac (Apple silicon);
   the Apple Developer Program + `docs/portal-steps.md`; the
   organisation identifier to replace `YOURORG`; decisions on every
   ASSUMED row in `REVIEW.md` (both tables, including the ten
   Summary-page defaults — each is now a one-line switch, B7);
   `zai.rtf` still needs moving out of the folder.
5. **Standing cautions learned the hard way (25 November additions
   marked ▸):**
   - Never push to `main` while a run is in flight — the concurrency
     group cancels it, even for a docs-only push.
   - Always `grep -rn "import SharedUI"` before pushing: SharedUI is a
     source group, not a module; the phantom import has slipped in
     three times.
   - Deferred `let` initialisation inside ViewBuilder closures fails
     (`buildExpression`); use a helper function.
   - ▸ A computed `some View` property without `@ViewBuilder` makes its
     `if/else` an *if-expression* — branches must match types (run 26;
     failure class 13 in `docs/failure-classes.md`).
   - ▸ A mapping property must return a narrow enum, not the enum it
     narrows, or downstream switches stop being exhaustive (run 27;
     class 14).
   - ▸ Chain checks with `set -o pipefail` or a pipeline masks the
     failure (burned again on 25 November, preflight through `tail`).
   - In extension targets, `ApplicationToken` needs
     `import ManagedSettings`, and DeviceActivity overlay types need
     `import SwiftUI` alongside `import DeviceActivity`.
6. Research summary (18–21 November, all landed): `docs/monitoring-analysis.md`
   — iOS behaviours, the browser matrix, the websites verdict
   (app-only v1; opt-in domains v1.1, own rows, never merged), §7
   unused report signal (pickups, notifications, longest session), §8
   alternative capture routes (Shortcuts automation = the only
   consumer-legal app-open trigger; shields; network-filter dead
   ends). Device checks A17–A24. UK day tracker: `Core.AppCalendar.uk()`
   drives the Summary day boundary (ASSUMED: UK-pinned). Earlier
   findings: sandbox rules, EU-only direct-data route (off), Xcode 26 /
   April 2027 Apple-silicon deadline, monitor memory ceiling.

## 1. What this is

A native iPhone app that shows time actually spent on screen in TikTok, Instagram, Facebook, X, YouTube and any other chosen app. One on/off switch per app, charts by hour, day, week and month, and one user-set target (hours per day or per week) with green, amber and red zones. iPhone first; Android later.

Builder: GLM (AI coding model) writes the code on the Mac. The person handles Apple's portal, Xcode signing and the physical iPhone.

## 2. Where everything lives

| Thing | Location |
| --- | --- |
| Local project | `/Users/larrysmacbookproi7/Desktop/SMAPP` |
| GitHub repo | `github.com/SnoopyGOGO14/SMAPP`, branch `main` |
| Live specification | `01-BUILD-SPEC-v2.md` in the repo (GLM has edited it since it was written; the repo copy is the authority) |
| Build sessions | `02-SESSION-TASKS.md` (nine sessions, four device gates A to D) |
| Run lists (in order) | `04-OVERNIGHT-TASKS.md` → `05-RUN-TO-REVIEW.md` → `06-FIXES-AFTER-REVIEW.md` → `07-NEXT-TASKS.md` → `08-SUMMARY-PAGE-PLAN.md` → `09-AUDIT-AND-NEXT.md`; index: `TASKS-INDEX.md` |
| Checklists | `03-ENGINEER-CHECKLISTS.md` |
| Running log | `PROGRESS.md` (GLM updates at the end of every session) |
| Review pack | `REVIEW.md` (written for the product owner) |
| Monitoring research | `docs/monitoring-analysis.md` (iOS behaviours, browser-linked usage, websites verdict) |
| Device checks | `docs/device-checks.md` (Gates A–D; A17–A24, essentials first; one-page card: `docs/gate-a-card.md`) |
| Design references | `design/` (original mock-ups) and `SKINS/` (Summary page skins) |
| Standing rules | `00-README-START-HERE.md` |
| Claude doc (planning copy) | `https://claude.ai/artifact/94ykMFNWj2vKtZgKgc4i72` — matches spec v2 as first written; lacks GLM's later edits |
| Version 1 plans | `archive/` (reference only) |

## 3. State at handoff

**Done (end of the 09 run, 25 November)**

- All three targets **BUILD SUCCEEDED** (run 28, `22895ca`, Xcode 26.6) — the 50 files written during the outage (visual fixes V1–V10, demo states, the whole Summary page) all compile. **104 Core tests** pass locally and in the cloud.
- **15 core captures** on `ci-logs/screenshots` (screens run 26, commit `2997d30`): home/summary/detail in light+dark, the over/paused states, focus markers, month, target, onboarding 1 and 4. Every marker matched, all checksums unique, no crashes. Waiting for the person's visual review.
- The 09 task list is complete except A5 (post-review): B1 preflight (`tools/preflight.sh`), B2 unbuilt review (`docs/unbuilt-review.md`, `docs/failure-classes.md`), B3 logic under test (SummaryText, DemoArguments, interval edges), B4 cheaper CI (tiers, caches, single build per push), B5 truthful records, B6 build-Mac readiness (`tools/first-run.sh`, `docs/gate-a-card.md`, reordered device checks), B7 ASSUMED defaults as one-line switches.
- All portal and App Store documents drafted under `docs/`; research addenda in `docs/monitoring-analysis.md` §7–8.
- GitHub access: same deploy key `SMAPP` (read/write), pushes work.

**The honesty line**: everything above is *compiles* or *tested* at best; **nothing is proven on an iPhone** — the 2016 Mac cannot run Xcode, and every device gate (A–D) is open by rule.

**Blocked on the person**

- A build Mac (2018+ Intel until April 2027, or Apple silicon for the long run) — unblocks Gate A and everything after. Day one: `docs/build-mac-setup.md`.
- Apple Developer Program + `docs/portal-steps.md`; the three Family Controls (Distribution) requests (answers drafted in `docs/AppStore/family-controls-request.md`).
- The real organisation identifier to replace `YOURORG`.
- Decisions on every ASSUMED row in `REVIEW.md`; replacement app icon.
- Move `zai.rtf` out of the project folder (credential; gitignored).

## 4. Toolchain: the main open risk

- This Mac: Intel, macOS 12, Xcode 14.2, Swift 5.7.2 (from GLM's log).
- App Store uploads have required Xcode 26 or later since 28 April 2026.
- Xcode 26.0 to 26.3 need macOS Sequoia 15.6 or later; 26.3 is the last version that runs on Sequoia. Xcode 26.4 to 26.6 need macOS Tahoe 26.2 or later.
- From April 2027 uploads need Xcode 27, which installs on Apple silicon Macs only.
- Consequence: Xcode 15 on macOS 13 would allow development builds only. To ship, this Mac must reach macOS 15.6 (believed to need a 2018 or later MacBook Pro; confirm in Software Update). Even then, release builds from an Intel Mac stop being accepted from April 2027.
- Decision needed once the model year is known: upgrade this Mac, or arrange access to a newer Mac for release builds. GLM can write code and run Core tests here either way.

## 5. Design decisions already made

- All usage figures are drawn inside the `UsageReport` extension. The main app and `UsageMonitor` never hold per-app usage numbers.
- Apple's newer direct-data route (iOS 26.4+, "Family Controls App and Website Usage") stays switched off: customer use is limited to EU devices with EU accounts, and development builds would mislead by working in any region.
- Apps are chosen through Apple's picker with `includeEntireCategory: true`; icons and names come from `Label(token)`.
- Report filter limited to iPhone and to enabled tokens.
- `UsageMonitor`: Foundation, DeviceActivity, UserNotifications only; six checkpoint events (25 to 150% of target) with `includesPastActivity: true`; sanity guard against early-firing events; alerts worded as approximate and opening the Today ring.
- Zones: green under 75% of target, amber 75 to 100%, red over 100%. Colours are semantic system colours (GLM's change, replacing hex values).
- Minimum iOS 17.4. Apple frameworks only; no network code.
- Session 1 is independent of the Session 0 device gate and may run first. Gates A to D still hold for everything after.

## 6. Written but unverified

- Swift API shapes in `02-SESSION-TASKS.md` have never been compiled.
- Extension Info.plist keys and XcodeGen target types have yet to be compared with Apple's own Xcode templates.
- App Group reads from inside the report extension (expected to work; proven only at Gate A).
- Days of history iOS returns for the Month view.
- Monitoring continuing after a phone restart with the app closed.
- Weekly-mode schedule spanning a full week.
- App icons and names rendering inside the report extension.

## 7. Open decisions for the product owner

- [ ] Amber zone at 75%, or green and red only (also an open comment in the Claude doc)
- [ ] App name and icon
- [ ] Free, paid or subscription
- [ ] Count websites (for example youtube.com in Safari) in version 1?
- [ ] Launch countries: UK first, or UK and EU together
- [ ] Recap notifications on or off by default
- [ ] Mac for release builds (section 4)

## 8. Next actions

**GLM**

1. The 09 list is done through A4. A5 (fix the review's findings,
   `[screens-all]` once, raise REVIEW.md levels) runs after the
   person's visual check.
2. After that, new work waits on the person (Gate A needs a device
   build). When a build Mac exists: `tools/first-run.sh`, then
   `docs/gate-a-card.md`.

**Person**

1. **Visual review (now):** the 15 captures on `ci-logs/screenshots`
   against `design/reference/` and `SKINS/*/screen.png` — list and
   file names in `docs/screens.md`. Tell GLM the findings; A5 follows.
2. Arrange the build Mac; follow `docs/build-mac-setup.md`, then
   `tools/first-run.sh` on it.
3. Join the Apple Developer Program; work through `docs/portal-steps.md`;
   submit the three Family Controls (Distribution) requests from
   `docs/AppStore/family-controls-request.md`.
4. Give GLM the organisation identifier.
5. Answer the ASSUMED decisions in `REVIEW.md` (both tables); choose
   the app name/icon.
6. Run Gate A on a device (`docs/gate-a-card.md`, ~1 hour).

## 9. Tool and access notes for the next assistant session

- The SMAPP folder is connected to the Claude session through the desktop app; files can be listed, staged and written back.
- Claude in Chrome: extension reported as not connected throughout this session.
- Built-in browser pane: signed out of GitHub.
- Computer use: Chrome granted at read tier; screenshots fail on this Mac (need macOS 14).
- GitHub changes this session were made by the person in the browser and by GLM over SSH.

## 10. Key sources

- Apple, SDK minimum requirements: https://www.developer.apple.com/news/upcoming-requirements/
- Apple, Xcode system requirements: https://developer.apple.com/xcode/system-requirements
- Apple Developer Forums, Xcode 27 on Intel: https://developer.apple.com/forums/thread/829619
- Apple documentation, direct-data API and its EU limit: https://developer.apple.com/documentation/deviceactivity/deviceactivitydata/activitydata(filteredby:using:)
- Apple Developer Forums, early threshold events on iOS 26.x: https://developer.apple.com/forums/thread/809410
- Further sources are listed at the end of `01-BUILD-SPEC-v2.md`.
