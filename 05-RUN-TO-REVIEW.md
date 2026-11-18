# Run to review — complete engineer's task list for GLM

18 November 2026. This is the master list from the current state to a build that is as complete as it can be for the product owner to review. It follows the plan in `01-BUILD-SPEC-v2.md`, `02-SESSION-TASKS.md`, `design/DESIGN-NOTES.md` and `04-OVERNIGHT-TASKS.md`.

Where this file and `04-OVERNIGHT-TASKS.md` differ, this file wins: there is no stopping after Block G, the morning report moves to the very end (Block P), and "stop conditions" become "skip conditions".

## How to run

1. Work top to bottom. Tick each task in this file as it lands and commit.
2. **Never wait and never stop early.** When a task is blocked, log it under `## Skipped` in `PROGRESS.md` (task id, what was tried, the exact error, what is needed and from whom), then start the next task straight away.
3. A task is blocked when: the same error survives three different fixes; it needs the person (Apple portal, signing, a physical iPhone, a newer Mac, a product decision); or the build budget is spent.
4. Product decisions never block. Take the default in "Defaults" below, mark it `ASSUMED` in `PROGRESS.md`, and carry on.
5. After the last block, make one more pass over the Skipped list and retry anything that later work may have unblocked. Then finish with Block P.
6. Honesty levels, used exactly: **tested** (unit tests pass on this Mac), **compiles** (cloud build succeeded), **screenshot** (rendered in the simulator in Block L), **unverified on device** (all Screen Time behaviour). Device gates A to D stay open; never record one as passed.

## Guard rails for an unattended run

- Work only inside this project folder and this repository.
- Push to `main` and `draft/*` branches only. No force-push to `main`. The `ci-logs` branch is written by the workflow alone.
- Commit no secrets, keys or tokens. Leave `.gitignore` entries for credentials in place.
- Install nothing on this Mac and change no macOS or GitHub settings.
- Delete only files you created. Move anything else to `archive/`.
- Apple frameworks only; no third-party packages; no network code in the app.
- The "Family Controls App and Website Usage" capability stays off.
- Check each Screen Time, Swift Charts and XcodeGen detail against its documentation before use and list the pages checked in `PROGRESS.md`.
- Keep every screen as plain as `design/DESIGN-NOTES.md`. Add nothing the notes do not list.

## Build budget

- 25 cloud build runs in total for this run, plus 3 screenshot runs (Block L). Count them in `PROGRESS.md`.
- One push per block where possible. `[skip ci]` on commits touching only Markdown, `docs/`, `design/` or `Packages/Core`.
- When the budget is spent, keep writing code on a branch named `draft/uncompiled`, clearly labelled, and continue with every task that needs no build.

## Defaults for open decisions (mark each `ASSUMED`)

| Decision | Default |
| --- | --- |
| Amber zone | On, from 75% of target |
| App name | Social Time Monitor |
| Organisation identifier | Keep `YOURORG` placeholder |
| Websites counted | No |
| Recaps | Off until switched on |
| Per-app alerts | Out of scope for version 1 |
| Pricing, launch countries | Leave open; list in the review pack |

---

## Part 1 — Blocks A to F from `04-OVERNIGHT-TASKS.md`

Do them exactly as written there, with the run rules above. Skip Block G for now.

- [x] **A** Cloud build loop (workflow, `ci-logs` branch, scaffold builds) — done: run 2 green; docs/ci.md written
- [x] **B** Spec, session file and checklists brought in line with the approved designs
- [x] **C** Core additions with tests (`DurationParts`, `BarGeometry`, `AppZone`, `StatusLine`, `DonutMath`, `PeriodStats`, `Palette`, new keys) — 46 tests pass locally and in the cloud
- [ ] **D** Shared iOS layer and the five report scenes
- [ ] **E** Main app screens (onboarding, Home, App detail, All apps, Target, access banner, filters)
- [ ] **F** Monitor extension, scheduler, notifications

If Block A cannot be made to work, log it as skipped, do B and C in full, and write D onwards on `draft/uncompiled`. Everything after this point still applies.

---

## Part 2 — Completing the app

### Block H — Target tab and settings, finished

- [ ] H1. Target screen: Daily or Weekly selector; presets 1h, 2h, 3h, 4h; custom stepper in 15-minute steps; converting between daily and weekly through `Core.TargetMath`.
- [ ] H2. Master Monitoring switch; alerts switch; recaps switch. Notification permission is requested the first time either of the last two is switched on.
- [ ] H3. Settings screen: amber point slider (50 to 95%), week start day, Screen Time access status with a "Fix" button, "Add or remove apps" (reopens the picker), list of per-app targets with edit and remove, privacy statement.
- [ ] H4. Every change saves through `SharedSettings` and triggers the debounced monitoring restart.

Done when: build succeeds; each control reads and writes its key.

### Block I — States and resilience

- [ ] I1. First launch routes to onboarding; completed onboarding is remembered.
- [ ] I2. Access declined or later withdrawn: banner on every tab, one button to re-request, then the re-pick flow (earlier tokens are void).
- [ ] I3. No apps chosen: friendly empty state with "Choose apps".
- [ ] I4. Monitoring paused: Home shows "Paused" in place of the hero figure; rows dim.
- [ ] I5. No overall target: bars show without markers and a single "Set a target" button.
- [ ] I6. App removed from the phone or from the selection: its row, target and palette slot are cleaned up; `orderedTokens`, `enabledTokens` and `appTargets` stay consistent (write one function for this and unit-test the pure part in `Core`).
- [ ] I7. Each embedded report has a same-size placeholder while loading and a plain "No time recorded" state.
- [ ] I8. Midnight and week rollover: filters are rebuilt when the app becomes active and when the day changes.

Done when: build succeeds; each state has a view and a code path that reaches it.

### Block J — Accessibility, appearance, wording

- [ ] J1. Dynamic Type through the largest accessibility size; hero figures scale and wrap, bars keep their height.
- [ ] J2. VoiceOver: hero cards read total, target and zone in one sentence; rows read "Instagram, 52 minutes, over target"; chart bars read day, time and zone; the donut reads each platform and time.
- [ ] J3. Light and dark asset colours for every role in `DESIGN-NOTES.md`; zone colours remain semantic system colours; contrast of text on every background at least 4.5 to 1.
- [ ] J4. Reduce Motion respected; haptic on switches and presets.
- [ ] J5. All user-facing text in a String Catalog, British English, sentence case, no jargon. One file lists the status phrases so they stay consistent.
- [ ] J6. Remove any proof or debug screens from the release path.

Done when: build succeeds with zero warnings from our own code.

### Block K — App icon and launch screen (placeholder for the product owner)

- [ ] K1. An original icon: a simple ring gauge in the app's colours on the dark ground. No third-party brand marks. Produce the 1024-point PNG with a small Swift script run on this Mac (CoreGraphics), saved in `tools/` with its output in the asset catalogue. If the script cannot run here, add a single-colour placeholder and log it.
- [ ] K2. Launch screen: ground colour only.
- [ ] K3. Mark the icon `ASSUMED` in `PROGRESS.md`.

### Block L — Demo mode and simulator screenshots (this is what makes the app reviewable without an iPhone)

Screen Time data never appears in a simulator, so the real screens would be blank. Demo mode renders the same views from sample figures.

- [ ] L1. Move the pure rendering views and their configuration structs (hero card, bar, row time, period card, donut) into `SharedUI/`, compiled into both the app and `UsageReport`. The extension scenes keep only `makeConfiguration`.
- [ ] L2. `App/Demo/DemoData.swift`: sample configurations matching the figures in `design/reference/` (total 2h 46m of 3h; TikTok 58m of 1h; Instagram 52m of 45m; YouTube 31m of 1h; Facebook 14m, no target; X 11m of 30m; week 44, 61, 38, 82, 49, 41, 58 minutes).
- [ ] L3. Launch arguments, debug builds only: `-demo` replaces every embedded report with the matching `SharedUI` view fed from `DemoData`, skips authorisation and uses neutral placeholder tiles with initials for app icons; `-screen home|detail|allapps|target|onboarding` opens that screen directly.
- [ ] L4. Release builds contain no demo code path (`#if DEBUG`).
- [ ] L5. Second workflow `.github/workflows/screens.yml`, run only when the head commit message contains `[screens]`: build for a named iPhone simulator, boot it, install the app, then for each screen and for light and dark appearance launch with the arguments and capture with `xcrun simctl io booted screenshot`. Push the PNG files to the `ci-logs` branch under `screenshots/`. Try default simulator signing first; if install or launch fails, record the log and try `CODE_SIGN_IDENTITY=-`.
- [ ] L6. Compare each screenshot with its reference in `design/reference/` and fix spacing, sizes and colours. Budget: 3 screenshot runs.

Done when: `screenshots/` on `ci-logs` holds Home, App detail, All apps, Target and onboarding in light and dark. If simulator capture cannot be made to work, log it as skipped; demo mode itself (L1 to L4) still counts.

### Block M — Tests and code quality

- [ ] M1. `Core` tests extended for everything added in Blocks H and I that is pure logic. Run locally.
- [ ] M2. One file, one job: split anything over about 250 lines.
- [ ] M3. No force unwraps on decoded settings; every decode has a safe default.
- [ ] M4. `os.Logger` in both extensions with one subsystem; no `print`.
- [ ] M5. Read the last build log and clear every warning in our code.
- [ ] M6. Re-read `03-ENGINEER-CHECKLISTS.md` sections 2 to 9 and tick what is done; list what is left.

### Block N — Release preparation (documents and configuration only)

- [ ] N1. `Config/PrivacyInfo.xcprivacy` for all three targets declaring UserDefaults use with the current required-reason codes from Apple's page; no tracking; no collected data.
- [ ] N2. `docs/AppStore/review-notes.md`, `listing.md` (name options, subtitle, description, keywords, free of third-party brand names) and `privacy-policy.md`.
- [ ] N3. Version 1.0 (1); Release configuration builds in the cloud.
- [ ] N4. `docs/build-mac-setup.md`: what the person does on a newer Mac on day one (Xcode version, clone, `xcodegen generate`, signing team, run on iPhone), then Gate A.

### Block O — Repository tidy

- [ ] O1. `README.md`: what the app is, how the three targets fit together (one Mermaid diagram), folder map, how to run the Core tests, how the cloud build and screenshots work.
- [ ] O2. `docs/architecture.md`: what draws what, the App Group keys, the five report contexts, the monitoring flow.
- [ ] O3. Spec, session file, checklists and `DESIGN-NOTES.md` agree with the code as built. Where the code differs, change the document and say why.

---

## Part 3 — Finish

### Second pass

- [ ] Retry every item under `## Skipped` once. Update each entry with the outcome.

### Block P — Review pack (always last)

- [ ] P1. `REVIEW.md` at the repository root, written for a non-engineer:
  - what works and how sure we are (tested, compiles, screenshot, unverified on device), one line per feature R1 to R16
  - where to look: screenshots on the `ci-logs` branch, the design canvas, the Actions tab
  - what could not be done and why (the Skipped list in plain words)
  - every `ASSUMED` decision, with the alternative
  - what the product owner needs to supply, in order
  - the device checks waiting at Gate A, step by step
- [ ] P2. `PROGRESS.md`: table of every file with its honesty level; Apple pages checked; build and screenshot runs used; deviations from this list.
- [ ] P3. `SESSION-HANDOFF.md` updated to the final state.
- [ ] P4. Final commit and push. Then stop.

## Complete only when

- Every box above is ticked or has an entry under `## Skipped`.
- `REVIEW.md` exists and matches the repository.
- The last commit on `main` builds, or the reason it cannot is at the top of `REVIEW.md`.
