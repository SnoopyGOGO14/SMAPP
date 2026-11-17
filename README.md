# SMAPP — Social Time Monitor

A native iPhone app that shows how long you actually spend on screen in TikTok,
Instagram, X, YouTube and any other app you choose, with a per-app on/off
switch, colour-zoned charts (green / amber / red) and one user-set target.

Built with SwiftUI on Apple's Screen Time APIs (FamilyControls + DeviceActivity).
Everything stays on the device: no account, no server, no analytics.

## Start here

| Read this | For |
| --- | --- |
| [`00-README-START-HERE.md`](00-README-START-HERE.md) | Reading order, roles, standing rules |
| [`01-BUILD-SPEC-v2.md`](01-BUILD-SPEC-v2.md) | The specification |
| [`02-SESSION-TASKS.md`](02-SESSION-TASKS.md) | Nine build sessions, four device-check gates |
| [`03-ENGINEER-CHECKLISTS.md`](03-ENGINEER-CHECKLISTS.md) | Thirteen engineer checklists |
| [`PROGRESS.md`](PROGRESS.md) | Running log — updated every session |

Version-1 plan documents live in [`archive/`](archive/).

## Status

**Session 0 (scaffold) complete** — see `PROGRESS.md`. The build is driven by
an AI coding agent session-by-session, with a person handling the Apple
Developer portal, signing and physical-device checks at each gate.

Current blockers are listed in `PROGRESS.md` → *Waiting on the person*
(macOS/Xcode upgrade, Family Controls entitlement requests, `xcodegen`).

## Layout

```
project.yml      XcodeGen definition (three targets + Core package)
Packages/Core   Pure logic, runs under `swift test`
App/            Main app target (SwiftUI)
UsageReport/    Device Activity Report extension (draws all usage charts)
UsageMonitor/   Device Activity Monitor extension (threshold alerts)
Config/         Info.plists, entitlements, privacy manifest
```

Generate the Xcode project with `xcodegen generate`, then open
`SocialTimeMonitor.xcodeproj`.
