# Social Time Monitor — progress log

Created in Session 0. GLM updates this at the end of every session; the person
reads it before starting theirs. Sessions marked GATE wait for a recorded pass
before the next one starts.

---

## Session 1 — Core logic and tests (GLM: done) · 17 Nov 2026

### Done

All six sources in `Packages/Core/Sources/Core/`, Foundation only, Swift
5.7-compatible (no 5.9 features) so they build on this Mac:

- `Zone.swift` — `Zone` enum + the spec's `zone(usedMinutes:allowanceMinutes:amberFraction:)`
- `TargetMath.swift` — `TargetMode`, `AllowanceView` (the spec's six views),
  daily↔weekly conversion (× 7, ÷ 7), `allowanceMinutes(view:mode:targetMinutes:)`
  implementing every row of the spec's allowance table, `weekToDateAverage`
- `PeriodMath.swift` — `Period` enum + `dateInterval(for:offset:calendar:weekStartsOn:now:)`
- `DurationFormat.swift` — `short(minutes:)` and `left(minutes:)`
- `Checkpoint.swift` — `Checkpoint` struct with statics used by Session 6:
  `checkpointPercents`, `thresholdMinutes(percent:targetMinutes:)`,
  `isPlausible(percent:targetMinutes:minutesSinceIntervalStart:)` (the sanity guard)
- `SettingsKeys.swift` — all ten App Group keys, exact spec strings

Tests in `Packages/Core/Tests/CoreTests/CoreTests.swift` — 19 tests covering
the session's minimum list: zone boundaries (0, 74.9%, 75%, 100%, 100.1%,
zero allowance), conversions round-trip, the full allowance table in both
modes, week-to-date average, day intervals across both 2026 London clock
changes (23 h / 25 h), Monday and Sunday week starts, month lengths 28–31,
offsets −1/−12 (day, hour, week, month), duration strings (0, 59, 60, 134,
600), sanity guard (3-hour target at 01:00 → implausible, 15:00 → plausible),
Checkpoint Codable round-trip, key uniqueness.

Placeholder `Core.swift` and its placeholder test removed.

### Verified and how

`swift test --package-path Packages/Core` on this Mac (Swift 5.7.2, macOS 12):

```
Test Suite 'All tests' passed at 2026-11-17 23:22:47.393.
	 Executed 19 tests, with 0 failures (0 unexpected) in 0.020 (0.022) seconds
```

Two fixes during the run, for the record: removed an unnecessary `DateString`
wrapper (string literals wouldn't convert), and NSObject's legacy `zone`
instance method shadows the global `zone()` inside XCTestCase subclasses —
tests call `Core.zone(...)`.

### Decisions

- **Package on Swift 5.7 tools, platforms iOS 16 / macOS 12** (per product
  owner, 17 Nov) so Core builds and tests on this 2016 Intel Mac tonight.
  Supersedes the `02-SESSION-TASKS.md` line "platforms iOS 17 and macOS 13"
  for the package only; app targets in `project.yml` keep iOS 17.4. Core
  stays Foundation-only regardless.
- **DurationFormat whole hours drop the minutes**: 60 → "1h", 600 → "10h";
  mixed keeps both (134 → "2h 14m"); below an hour minutes only; 0 → "0m".
- Sanity guard compares rounded threshold minutes against elapsed minutes
  (spec wording: threshold minutes must be ≤ minutes elapsed).

### Waiting on the person — nothing new from Session 1 (pure logic)

---

## Session 0 — Scaffold (GLM: done; device leg blocked on a build Mac) · 17 Nov 2026

### Done

- Version-1 plan files (markdown + PDF) moved to `archive/`; one live spec.
- Pack review fixes: semantic system colours in spec + Session 2 `ZoneStyle`
  row; Dynamic Type/VoiceOver first-pass rule; entitlement-denied risk row.
- Scaffold per `02-SESSION-TASKS.md`: `project.yml` (XcodeGen, three targets
  + Core package, iOS 17.4), `Packages/Core`, `Config/` entitlements and
  extension plists, placeholder sources for app/report/monitor, `.gitignore`,
  git repo pushed to github.com/SnoopyGOGO14/SMAPP (`main`).
- `README.md` written as the repo front door.

### Verified and how

- `DeviceActivityReportExtension` protocol shape read from Apple's
  documentation (`.md` trick, README rule 8) and matched against Apple's
  WWDC22 sample; placeholder follows it.
- Extension plist keys per the session file; still to be compared with
  Apple's Xcode templates when a build Mac exists (engineering note stands).

### The build Mac (corrected 17 Nov after the Mac report — replaces the earlier Xcode 15 advice)

Facts, from `sw_vers`, `sysctl hw.model` and
`softwareupdate --list-full-installers`:

- **Model: MacBookPro13,2 — 13-inch MacBook Pro, 2016** (i7-6567U)
- macOS 12.7.6 Monterey; the newest full installer offered **is Monterey** —
  this model's official ceiling
- Therefore: no Ventura → no Xcode 15 → **cannot build the iOS 17.4 app
  target at all**, and no Sequoia → no Xcode 26 → **cannot ever upload from
  this Mac** (uploads have required Xcode 26+ since 28 April 2026; from
  April 2027, Xcode 27 — Apple silicon only)

**Conclusion: this Mac writes code and runs `swift test`, nothing more.**
Every Xcode build, every device gate and the release upload need a 2018+
Intel Mac (until April 2027) or, for the long run, any Apple silicon Mac.
Spec risk row added accordingly. Options and portal steps: `docs/portal-steps.md` §6.

### Waiting on the person

1. **Arrange the build Mac** (see above) — blocks Session 0's device leg,
   Gate A and all later gates.
2. Apple Developer Program membership (Account Holder).
3. Portal: three bundle IDs, App Group, Family Controls (Development) on
   all three — click-by-click in `docs/portal-steps.md`; then the three
   Family Controls (Distribution) requests using
   `docs/AppStore/family-controls-request.md`. Record dates here.
4. Give GLM the real organisation identifier to replace `YOURORG`.
5. Install XcodeGen on the build Mac; `xcodegen generate`; sign; install on
   a physical iPhone showing "Scaffold"; record the pass here.
6. Move `zai.rtf` out of the folder (credential; gitignored but still parked
   in the project directory).

### Open questions

- The v1 PDF in `archive/` cannot be read by GLM (no PDF input support);
  archived unread, assumed identical to the v1 markdown. Paste text if it
  differs.
- Product-owner decisions (spec §Open decisions): amber zone, app name/icon,
  pricing, websites in scope, launch countries, recap default.

---

## Decisions (project-wide)

- One spec (v2); v1 archived, not deleted.
- Semantic system colours over hard-coded hex.
- Generated `.xcodeproj` gitignored — regenerate with `xcodegen generate`.
- Package `Core` stays Foundation-only and 5.7-compatible for this Mac.
- Git remote: `git@github.com:SnoopyGOGO14/SMAPP.git` (SSH key
  `SMAPP-build-mac`, added 17 Nov). Push after every session.

## Session 2 — next, but blocked

GATE A needs a device build. Do not start until Session 0's device leg is
recorded as passed here and the build Mac exists.
