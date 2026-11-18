# Social Time Monitor — progress log

GLM updates at the end of every session. Honesty levels (05-RUN-TO-REVIEW):
**tested** (unit tests pass on this Mac), **compiles** (cloud build
succeeded), **screenshot** (rendered in the simulator), **unverified on
device** (all Screen Time behaviour). Device gates A to D stay open.

---

## Open questions for the product owner (read first)

1. **The build Mac.** Everything below is "compiles" at best. A 2018+ Intel
   Mac (until April 2027) or any Apple silicon Mac is needed for Gates A–D,
   TestFlight and upload. Day-one steps: `docs/build-mac-setup.md`.
2. Repo public or private? Private = ~200 macOS build minutes/month
   (Actions is 10× on macOS). Public = unlimited; tell GLM and the cap goes.
3. Open decisions now ASSUMED (see ASSUMED list below) — confirm or change:
   amber zone, app name, organisation identifier, websites, recaps default.
4. Replace the placeholder app icon (marked ASSUMED).
5. `zai.rtf` still sits in the project folder (credential; gitignored) —
   move it out.

## Run of 18 November — Blocks A to P (05-RUN-TO-REVIEW.md)

### Build and screenshot budget

- Builds used: 11 of 25 (two were cancelled mid-run by newer pushes).
- Screenshot runs used: 2 of 3 (both failed before capture: their builds
  failed). Final screenshot run: see Block L below.
- Failure→fix log, all diagnosed from `ci-logs`:
  1. Extensions' bundle IDs not prefixed → explicit PRODUCT_BUNDLE_IDENTIFIER.
  2. `TokenCleanup.Result` Equatable with tuple member → dropped conformance.
  3. `import SharedUI` — SharedUI is a source group, not a module → removed.
  4. XcodeGen type name → `extensionkit-extension` (one word, per its docs).
  5. Monitor extension can't compile FamilyControls tokens → SharedSettings
     split into monitor-safe base + `+Tokens`.
  6. DeviceActivity SwiftUI overlay types invisible in explicit-module
     builds → `import SwiftUI` alongside DeviceActivity.
  7. `.weekly` on DeviceActivityName unresolved in the monitor → shared
     `ActivityNames.swift`.
  8. `ApplicationToken` is a ManagedSettings re-export alias →
     `import ManagedSettings` wherever tokens are used (the spec's framework
     table said "ManagedSettings (tokens)" all along).

### Block A — cloud build loop: done, tested+compiles

`.github/workflows/build.yml` (macos-26: Core tests → xcodegen → simulator
build of all three targets), logs to `ci-logs`. Scaffold first went green
on run 2. `docs/ci.md` written.

### Block B — spec realigned: done

R14–R16 added; screen spec replaced by the DESIGN-NOTES pointer + Target
tab; four new data keys; contexts renamed (`homeTotal`, `appRow`,
`appTime`, `appDetail`, `allApps`); per-app alerts declared out of scope;
Sessions 2–5, checklists 5/8 and the device matrix updated.

### Block C — Core additions: done, tested

46 tests pass on this Mac and in the cloud. Files: DurationParts,
BarGeometry, AppZone, StatusLine, DonutMath, PeriodStats, Palette,
TokenCleanup (+SettingsKeys +4). Decision: whole hours drop the minutes
("1h", "10h"); mixed keeps both; 0 → "0m".

### Block D — shared layer + five report scenes: compiles

Shared (SharedSettings split, ReportContexts, ZoneStyle, PaletteColors,
ActivityNames), SharedUI (configurations + pure views: HeroCard, BarView,
AppRow/AppTime, PeriodCard with Charts bars + dashed rule, DonutView with
SectorMark, placeholders), UsageReport (Aggregator + five scenes).
Scenes compute via Aggregator+Core; views only render configuration
structs (which demo mode also feeds). Reads the App Group; writes nothing.

### Block E — app screens: compiles

AppState (@Observable), onboarding (4 cards), Home + AppUsageRow
(NavigationLink rows, hit-testing-off embedded reports), App detail +
target sheet, All apps, Target + Settings, AccessBanner, Filters,
notification routing (AppDelegate), day-rollover watch.

### Block F — monitor + scheduling: compiles

MonitoringScheduler (daily schedule always; weekly schedule in weekly
mode; six checkpoint events with `includesPastActivity`; 1 s debounced
restart; stop when paused), UsageMonitor (percent parse → sanity guard →
lastCheckpoint → alerts at 75/100, worded approximate), recaps (evening
21:00, Sunday 18:00).

### Block H — Target tab finished: compiles

(Done as part of E: mode selector with × 7 / ÷ 7 conversion, presets,
custom stepper, master/alerts/recaps switches with permission on first
enable, Settings with amber slider, week start, access status, edit
selection, per-app target list, privacy text.)

### Block I — states: compiles

Onboarding routing (I1), banner on every tab + re-pick flow (I2), empty
apps state (I3), Paused hero + dimmed rows (I4), no-target bars without
markers + "Set a target" button (I5), TokenCleanup keeping ordered/
enabled/appTargets consistent, unit-tested (I6), placeholders + "No time
recorded" (I7 — placeholder is a fixed-size card, not an animated skeleton;
logged as a deviation), filters rebuilt on foreground/day change (I8).

### Block J — accessibility/appearance: compiles (static); device check pending

ScaledMetric on hero figures (J1), VoiceOver labels on hero/rows/bars/
donut (J2), light+dark role colours + semantic zone colours, contrast
checked arithmetically ≥ 4.5:1 (J3), Reduce Motion: no custom animations
to disable (J4 — haptics helper present, only lightly wired), String
Catalog en-GB + status phrases centralised in Core (J5), no debug screens
in release (J6). VoiceOver/Dynamic-Type walkthrough needs a device.

### Block K — icon + launch screen: compiles

`tools/make_icon.swift` (CoreGraphics, run on this Mac) → 1024 pt ring-
gauge placeholder; launch screen = ground colour. **ASSUMED**.

### Block L — demo mode + screenshots

L1–L4 done: SharedUI shared by app + extension; DemoData mirrors the
mock figures exactly; `-demo` and `-screen home|allapps|detail|target|
onboarding` in DEBUG only; release has no demo path. L5: `screens.yml`
runs on `[screens]` commits, pushes PNGs to `ci-logs/screenshots`.
L6 (visual comparison): **GLM cannot do this — no image input**; the
screenshots are for the product owner to compare against
`design/reference/`. Screenshot result: [PATCHED BELOW].

### Block M — quality: done (local checks)

No file over 250 lines; no `as!`/`try!`; no `print` in extensions
(os.Logger, one subsystem); remaining warnings after the colorset fix:
none from our code (actool colorset warnings resolved by idiom+appearances
structure — verified in the final build). M6 checklist tick-off:
03-ENGINEER-CHECKLISTS sections 2–9 reviewed; portal/signing items
(§1) remain for the person; device-matrix items remain open by rule.

### Block N — release prep: done (documents/configuration)

PrivacyInfo.xcprivacy in Config (UserDefaults CA92.1 + 1C8F.1, no tracking,
no collection) — needs adding to the three targets' resources, done via
Config/ inclusion in project.yml [verify in final build]; review-notes.md,
listing.md, privacy-policy.md, build-mac-setup.md; MARKETING_VERSION 1.0 (1).

### Block O — repo tidy: done

README (Mermaid diagram, folder map, how to run), docs/architecture.md,
spec/session/checklists agree with the build (deviations recorded here).

### Second pass + Block P

REVIEW.md written for the product owner; SESSION-HANDOFF updated; final
commit pushed; gates audit below.

---

## Skipped

| Task | What was tried | Why blocked | Needed from whom |
| --- | --- | --- | --- |
| L6 compare screenshots with mocks | — | GLM has no image input (same for the v1 PDF and the jpg render) | Product owner: compare `ci-logs/screenshots` with `design/reference/` |
| Eye-check of `smartphone-dashallstats.jpg` | — | No image input | Product owner |
| Reading `archive/*.pdf` | — | No PDF input | — (markdown twin archived alongside) |
| Device gates A–D | — | Needs build Mac + iPhone | Person; steps in `docs/device-checks.md` |
| VoiceOver/AX5 walkthrough (J1/J2) | static labels implemented | Needs device/simulator interaction | Person |
| App Group read from report extension | code path written | Proof only at Gate A | Person |

## ASSUMED decisions

| Decision | Taken default | Alternative |
| --- | --- | --- |
| Amber zone | On, from 75% | Green/red only |
| App name | Social Time Monitor | any |
| Org identifier | `YOURORG` placeholder kept | person's real `com.x` |
| Websites counted | No | include web-domain tokens |
| Recaps default | Off until switched on | On |
| Per-app alerts | Out of scope v1 | later |
| Pricing / countries | Left open | — |
| Neutral app-row bar scale | Fixed 60-min reference (mock matches within 0.4 pt) | true largest-app value is unreachable in a single-token report |
| All-apps donut month caption | Omitted (nil) | approximate monthly allowance |
| Editing a non-empty selection | Lives in Settings | extra control on Home (design says "nothing else") |
| App icon | Placeholder ring gauge | product owner artwork |

## Apple pages checked (rule: docs before code)

DeviceActivityReportExtension, DeviceActivityReportScene,
DeviceActivityResults, DeviceActivityData, ActivitySegment,
CategoryActivity, ApplicationActivity, DeviceActivityFilter,
DeviceActivityReport (SwiftUI view), SectorMark (Charts),
FamilyActivitySelection, FamilyActivityPicker, Displaying Activity
Labels (Label(applicationToken:)), DeviceActivitySchedule,
DeviceActivityEvent, DeviceActivityMonitor — all via the `.md` trick;
plus XcodeGen's ProjectSpec (product types), Apple's required-reason API
page (UserDefaults codes), and the forums threads cited in the spec.

## GATES audit (GATES.md, manual ledger)

- G1 core-tests-pass: **PASS** (46/46 local + cloud)
- G2 checklist-complete: **PASS** after Block P ticks
- G3 cloud-build-green: **[PATCHED BELOW]**
- G4 screenshots-or-skipped: **[PATCHED BELOW]**
- G5 review-pack-exists: **PASS** (REVIEW.md)
- G6 no-force-decode: **PASS** (grep clean)
- G7 no-print-in-extensions: **PASS** (grep clean)
- G8 tree-pushed: **PASS** at final commit

## Earlier sessions

Session 0 (scaffold) and Session 1 (Core, 19 tests) logs are in git
history; Session 1's Mac report (MacBookPro13,2 = 2016, Monterey ceiling)
remains the reason nothing can build on this machine.
