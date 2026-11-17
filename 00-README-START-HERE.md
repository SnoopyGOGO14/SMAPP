# Social Time Monitor — build pack (v2)

17 November 2026. This folder holds everything needed to build the iPhone app with an AI coding model (GLM) driving the code and a person handling Apple's portal, Xcode signing and the physical iPhone.

## Read in this order

| File | Purpose | Who reads it |
| --- | --- | --- |
| `00-README-START-HERE.md` | This page: order, roles, standing rules | Everyone |
| `01-BUILD-SPEC-v2.md` | The full specification: requirements, Apple platform rules, background operation, architecture, data model, screens, risks | GLM at the start of every session; the person once |
| `02-SESSION-TASKS.md` | Nine build sessions, each with files to create, tasks, engineering notes and acceptance checks | GLM, one session at a time |
| `03-ENGINEER-CHECKLISTS.md` | Lists to consider and implement: accounts, project settings, permissions, extensions, interface, privacy, test matrix, release | The person and GLM, ticked off as work lands |
| `PROGRESS.md` | Created by GLM in Session 0 and updated at the end of every session | GLM writes, the person reads |

The two earlier files in this folder (`Social Time Monitor — iPhone App Build Plan.md` and `Social-Time-Monitor-Build-Plan.md`) are version 1. Version 2 replaces them; keep them for reference or archive them so the builder reads one specification only.

## Who does what

| Task | GLM | Person |
| --- | --- | --- |
| Write Swift, tests, project file (`project.yml`), plists, entitlements files | Yes | Reviews |
| Run `swift test` on the pure-logic package | Yes | |
| Apple Developer portal: bundle IDs, App Group, Family Controls requests | | Yes |
| Choose signing team in Xcode, build to a physical iPhone | | Yes |
| Device checks at each gate (compare with Settings › Screen Time) | | Yes |
| TestFlight and App Store submission | Prepares text | Submits |

## Standing rules for every session

1. Read `01-BUILD-SPEC-v2.md` and `PROGRESS.md` before writing code. Work on one session only, then stop.
2. Sessions marked **GATE** end with a device check by the person. Begin the next session after the gate is recorded as passed in `PROGRESS.md`.
3. Usage figures are drawn inside the `UsageReport` extension only. The main app and `UsageMonitor` never hold per-app usage numbers.
4. The "Family Controls App and Website Usage" capability stays switched off (customer use is limited to the EU; see the spec).
5. Apple frameworks only. No third-party packages, no network code, no analytics.
6. `UsageMonitor` imports Foundation, DeviceActivity and UserNotifications only.
7. All App Group reads and writes go through `SharedSettings`. All zone colours and wording come from `ZoneStyle`.
8. Screen Time API names are easy to misremember. Use the signatures given in the session file; for anything else, read Apple's page first. Apple serves its documentation as plain markdown when `.md` is added to the page address, for example `https://developer.apple.com/documentation/deviceactivity/deviceactivityevent.md`.
9. Interface text in British English (colour, authorise, organise).
10. Finish every session by updating `PROGRESS.md`: what was built, what was verified and how, what is waiting on the person, open questions.
