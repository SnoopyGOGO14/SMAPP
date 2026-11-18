# Social Time Monitor (SMAPP) — session handoff

Written 17 November 2026, 23:20 UK time; updated after each run. Read this first when picking the project up, then `PROGRESS.md`.

## Todos — state at this handoff (18 November, end of the 08 code run)

1. **BLOCKED: GitHub Actions macOS minutes appear exhausted.** The
   `0dd5508` runs (07 Parts 1–2 captures) and every later push neither
   start nor fail — the classic billing-queue signature after tonight's
   ~20 runs. **The person must check the repo's Actions tab and billing
   (or make the repo public — public repos have no minutes cap).** Once
   minutes exist, push any commit with `[screens]` and the manifest
   delivers everything: the 07 captures plus the new Summary set.
2. **07-NEXT-TASKS Parts 1–2: code complete and pushed** (`0dd5508`),
   capture verification pending item 1. Parts 3–4 documents are done;
   REVIEW/PROGRESS level updates wait on the same captures.
3. **08-SUMMARY-PAGE-PLAN P1–P8, P10, P11: built and committed** —
   Summary page (ranked donut, share cards, period tabs with elapsed
   underline, day pills), skin tokens app-wide, FocusGroup motion on
   Summary/detail/Home/presets, demo routes + capture manifest
   (08 build budget untouched: 0 of 6 runs used while blocked).
   P9 (captures) and P12 (level updates) are blocked on item 1.
4. **Standing cautions learned the hard way:**
   - Never push to `main` while a `[screens]` run is in flight — the
     concurrency group cancels it, even for a docs-only push.
   - Always `grep -rn "import SharedUI"` before pushing: SharedUI is a
     source group, not a module; the phantom import has slipped in
     three times now.
   - Deferred `let` initialisation inside ViewBuilder closures fails
     (`buildExpression`); use a helper function.
   - In extension targets, `ApplicationToken` needs
     `import ManagedSettings`, and DeviceActivity overlay types need
     `import SwiftUI` alongside `import DeviceActivity`.
5. `zai.rtf` still in the folder (credential; gitignored) — the person
   means to move it.

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
| Checklists | `03-ENGINEER-CHECKLISTS.md` |
| Running log | `PROGRESS.md` (GLM updates at the end of every session) |
| Standing rules | `00-README-START-HERE.md` |
| Claude doc (planning copy) | `https://claude.ai/artifact/94ykMFNWj2vKtZgKgc4i72` — matches spec v2 as first written; lacks GLM's later edits |
| Version 1 plans | `archive/` (reference only) |

## 3. State at handoff

**Done (end of the unattended run, 18 November ~02:00)**

- All three targets **BUILD SUCCEEDED** on GitHub's macos-26 runner (Xcode 26.6, run 17, commit 324a148). 46 Core tests pass on both the 2016 Mac and in the cloud.
- The full app as specified: onboarding, Home, App detail, All apps, Target + Settings, access banner, all states (Blocks A to O of `05-RUN-TO-REVIEW.md` — every box ticked or logged in `PROGRESS.md` §Skipped).
- Demo mode renders the approved mock-up figures; the screenshot workflow pushes light+dark PNGs of five screens to `ci-logs/screenshots` (result of the final `[screens]` run recorded in `PROGRESS.md`).
- Review pack: `REVIEW.md` (written for the product owner) + honesty table, budget, ASSUMED list and Apple-pages list in `PROGRESS.md`.
- All portal and App Store documents drafted under `docs/`.
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

1. Done for this run: every box in `05-RUN-TO-REVIEW.md` ticked or logged
   under Skipped; review pack written; final push made.
2. Next work waits on the person (Gate A needs a device build). When a
   build Mac exists: rerun the portal-dependent items, then Session 2's
   gate per `docs/device-checks.md`.

**Person**

1. Arrange the build Mac; follow `docs/build-mac-setup.md`.
2. Join the Apple Developer Program; work through `docs/portal-steps.md`;
   submit the three Family Controls (Distribution) requests from
   `docs/AppStore/family-controls-request.md`.
3. Give GLM the organisation identifier.
4. Answer the ASSUMED decisions in `REVIEW.md`; choose the app name/icon.
5. Review the screenshots on `ci-logs` against `design/reference/`
   (GLM cannot view images) and run Gate A on a device.

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
