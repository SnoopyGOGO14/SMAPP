# Social Time Monitor (SMAPP) — session handoff

Written 17 November 2026, 23:20 UK time, at the end of the planning and setup session. Read this first when picking the project up, then `PROGRESS.md`.

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

**Done**

- Product requirements R1 to R13, architecture, data model, screens, risks: written and in the repo.
- Session 0 scaffold committed by GLM: `project.yml` (XcodeGen), three targets (`SocialTimeMonitor`, `UsageReport`, `UsageMonitor`), `Packages/Core` with placeholder source and test, entitlements and Info.plists in `Config/`.
- Repo history: `de02de0` initial commit, `fbbb91d` Session 0 scaffold, `cee7c72` README update. Working tree clean at 23:17.
- GitHub access for GLM: deploy key titled `SMAPP` on this repo only, read/write, fingerprint `SHA256:E+8z54zWDK6VE63l5IZwOx8z4P3Ef4vqn+mazJaojkU`. Fingerprint checked against GLM's public key: match. Push works.
- `zai.rtf` (holds a credential) was gitignored and is absent from the project folder as of the last listing.

**In progress: tasks handed to GLM at 23:17, completion unconfirmed**

1. Report the Mac's model, year and newest macOS offered (`sw_vers`, `sysctl hw.model`, `softwareupdate --list-full-installers`).
2. Correct the toolchain entry in `PROGRESS.md` (see section 4) and add the April 2027 risk row to the spec.
3. Session 1: Core logic and tests, built to run on this Mac today (swift-tools-version 5.7, Foundation only).
4. Draft `docs/AppStore/family-controls-request.md` (answers for Apple's Family Controls Distribution form, one section per bundle ID).
5. Draft `docs/portal-steps.md` (click-by-click portal steps for the person).
6. Stop after Session 1; commit and push.

At the time of writing `Packages/Core` still held the placeholder files, so Session 1 had yet to land.

**Blocked on the person**

- Session 0 closes only when `xcodegen generate` succeeds, a signing team is chosen and the app installs on an iPhone showing "Scaffold". That needs the toolchain in section 4.
- Apple Developer Program membership, three bundle IDs, the App Group, Family Controls (Development) on each, and the Family Controls (Distribution) request for each.
- An organisation identifier to replace `YOURORG` in `project.yml` and the three `.entitlements` files.
- One iPhone on iOS 17.4 or later; ideally a second on the newest iOS.

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

1. Finish the six tasks in section 3 and record results in `PROGRESS.md`.
2. Commit this file (`SESSION-HANDOFF.md`) to the repo.
3. Wait at Gate A: Session 2 needs a device build.

**Person**

1. Apple menu → About This Mac: note the model year. System Settings → Software Update: note the newest macOS offered. Tell GLM.
2. Join the Apple Developer Program; work through `docs/portal-steps.md` once GLM has drafted it.
3. Give GLM the organisation identifier.
4. Answer the open decisions in section 7.

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
