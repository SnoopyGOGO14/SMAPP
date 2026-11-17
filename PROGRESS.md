# Social Time Monitor — progress log

Created in Session 0. GLM updates this at the end of every session; the person
reads it before starting theirs. Sessions marked GATE wait for a recorded pass
before the next one starts.

---

## Session 0 — Scaffold (GLM: done, person: blocked — see below) · 17 Nov 2026

### Done

- Version-1 plan files (`Social Time Monitor — iPhone App Build Plan.md`
  and its PDF) moved to `archive/`. One live spec now: `01-BUILD-SPEC-v2.md`.
- Pack review fixes applied to v2 (GLM, this session):
  - `01-BUILD-SPEC-v2.md` visual rules + `02-SESSION-TASKS.md` Session 2 row:
    `ZoneStyle` now uses **semantic system colours** (`Color(.systemGreen) /
  .systemOrange / .systemRed)`), not hard-coded hex. Hex silently loses
    dark-mode and Increase Contrast variants. Amber = orange, not yellow.
  - Spec visual rules: Dynamic Type + VoiceOver from the first pass
    (retrofitting inside the report extension is the expensive path).
  - Spec risks: re-added the "Distribution entitlement denied outright" row.
- Scaffold created exactly per `02-SESSION-TASKS.md`:
  - `project.yml` (XcodeGen, three targets + `Core` package, iOS 17.4)
  - `Packages/Core/` (`Package.swift`, placeholder source + test so the
    package builds; Session 1 replaces them)
  - `Config/` — entitlements for all three targets (Family Controls + App
    Group `group.com.YOURORG.socialtimemonitor`), `UsageReport-Info.plist`
    (`EXAppExtensionAttributes` / `com.apple.deviceactivityui.report-extension`),
    `UsageMonitor-Info.plist` (`NSExtension` /
    `com.apple.deviceactivity.monitor-extension` / principal class), minimal
    `App-Info.plist`
  - Placeholder sources: `App/SocialTimeMonitorApp.swift` ("Scaffold"),
    `UsageReport/UsageReportExtension.swift` (empty scene),
    `UsageMonitor/UsageMonitor.swift` (empty subclass)
  - `.gitignore`; `git init`; first commit

### Verified and how

- `DeviceActivityReportExtension` shape (protocol, `body: some
  DeviceActivityReportScene`, one scene per context) read from Apple's
  documentation via the `.md` trick — rule 8 of the README — and
  cross-checked against Apple's WWDC22 sample. Placeholder follows it.
- Extension plist keys written per the session file. **Not yet compared with
  Apple's own Xcode templates** — that needs a machine with Xcode 15+
  (see below); the session file's engineering note still applies.

### Waiting on the person

1. **Toolchain upgrade (blocker):** this Mac runs Xcode 14.2 / Swift 5.7.2 on
   macOS 12. The spec needs Swift 5.9 and the iOS 17.4 SDK, so it needs
   Xcode 15 or later, which needs macOS 13 or later. Until then
   `xcodegen generate`, `swift test` and device builds cannot run here.
2. Install XcodeGen (`brew install xcodegen`) after the upgrade, then run
   `xcodegen generate` in this folder. If XcodeGen rejects `app-extension`
   for the report extension, switch that target to
   `extension-kit-extension` and record it here.
3. Apple portal (start today; review has its own timetable): register the
   three bundle IDs and the App Group; enable Family Controls (Development)
   on all three; submit the Family Controls (Distribution) request for each.
   Replace `YOURORG` in `project.yml` and the three `.entitlements` files
   with the real organisation identifier.
4. One iPhone on iOS 17.4+, ideally a second on the newest iOS.
5. Session 0 closes when: `xcodegen generate` succeeds, signing team
   selected, app installs on the iPhone showing "Scaffold". Record it here.

### Open questions

- The v1 PDF in `archive/` **cannot be read by GLM** (this model does not
  accept PDF input). It is archived unread and assumed identical to the v1
  markdown. If it contains anything the markdown lacks, paste the text.
- Product-owner decisions still open (spec §Open decisions): amber zone,
  app name/icon, pricing, websites in scope, launch countries, recap default.
- `zai.rtf` sits in this folder and contains a credential. It is excluded
  from git by `.gitignore`, but it should really be moved out of the project
  folder entirely.

### Decisions

- One spec (v2); v1 archived rather than deleted.
- Semantic system colours over hex (GLM review, re-applied to v2).
- Generated `.xcodeproj` is gitignored — regenerate with `xcodegen generate`.
- `Packages/Core` placeholder source + test exist only so Session 0 is
  buildable; Session 1 owns the real contents.

### Session 1 preview (starts only after Session 0 is closed by the person)

Core logic + tests per `02-SESSION-TASKS.md` — Zone, TargetMath, PeriodMath,
DurationFormat, Checkpoint, SettingsKeys, all proven by `swift test`.
