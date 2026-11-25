# Audit of 25 November 2026 and the full task list from here

Audited: `main` at `97a74b0` and the `ci-logs` branch. Same run rules, guard rails and honesty levels as `05-RUN-TO-REVIEW.md`: skip and log anything blocked, never wait.

## Part 0 — Where the project stands

### The headline

**The last successful cloud build was on 18 November at 11:13 (`337203d`, run 19). Since then 50 Swift files have changed (about 2,300 lines added, 650 removed) and none of it has been through a compiler.** That covers the ten visual fixes, the extra demo states and the whole Summary page.

### Evidence

| Item | State | Source |
| --- | --- | --- |
| Last green build | `337203d`, run 19, 18 Nov 11:13 | `ci-logs` history |
| Last build verdict of any kind | **failure**, `2a88ffe`, run 21: `TargetScreen.swift:133` `buildExpression` | `ci-logs:SUMMARY.txt`, `ci-build-full.log` |
| Fix for that failure | In `0dd5508`; never built | `git log` |
| Summary page code (`3338f04`) | Never built | `STATUS.txt` shows `screens: 3338f04 failure`, no build line for it |
| Screenshots on `ci-logs` | None. `NOTE.txt` says "no screenshots" | `ci-logs:screenshots/` |
| Cloud runs since 18 Nov 14:03 | None have reported | `ci-logs` last commit time |
| Code commits since 18 Nov 14:14 | None; documents and research only | `git log` |
| Core tests | 90 test functions; pass locally per GLM's log. The cloud last ran 65 | `Packages/Core/Tests`, `SUMMARY.txt` |

### Static checks run in this audit (no compiler involved)

- Braces, brackets and parentheses balance in all 80 Swift files.
- No `import SharedUI`; every file using `ApplicationToken` imports `ManagedSettings`; every file using `DeviceActivityReport` imports `SwiftUI`.
- `UsageMonitor` imports only Foundation, DeviceActivity, UserNotifications, Core and os.
- No Swift file over 250 lines. No `allApps` or `appTime` left in code.

These rule out the failure classes already met. They do not show the code compiles.

### Records that no longer match the code

- `REVIEW.md` gives R5, R11, R15 and R16 the level "screenshot". Those captures were of code since rewritten (Home, onboarding, chart) or removed (All apps). No capture of the current code exists.
- `REVIEW.md` R16 still describes the All apps screen; it is now Summary. R17 (focus effect) has no row.
- `SESSION-HANDOFF.md` section 3 still lists All apps as built and screenshots as present.

### Work that is sound

- `Core` logic and its tests, runnable on this Mac.
- The self-checking screenshot workflow (markers, liveness, duplicate detection).
- Research documents: `docs/monitoring-analysis.md`, the UK day boundary (`AppCalendar.uk`), device checks A11 to A24.

### Blocked on the product owner

1. **Cloud builds.** GLM's diagnosis is that the free macOS minutes on a private repo ran out. Check the repo's Actions tab and the account's Actions usage. Making the repo public removes the limit; otherwise the allowance refills at the start of the next billing cycle.
2. **A build Mac** (Apple silicon). Nothing reaches an iPhone without one.
3. Apple Developer Program, portal steps, the organisation identifier for `YOURORG`.
4. Decisions on the `ASSUMED` rows (Summary page draft included).
5. `zai.rtf` moved out of the project folder.

---

## Part 1 — First, find out whether the cloud is back (T0)

- [ ] T0.1 Run the local pre-flight from Part 2 (B1) first, so the probe push is as clean as possible.
- [ ] T0.2 Push one small code commit to `main` (no `[skip ci]`, no `[screens]`). Poll `ci-logs` once a minute for 20 minutes for a `build:` line carrying that commit.
- [ ] T0.3 Record the outcome in `PROGRESS.md` with the time. A verdict (success or failure) → **Track A**. Silence → **Track B**, and repeat T0.2 once at the end of Track B.

---

## Part 2 — Track B: everything that needs no cloud (do this either way; if the cloud is alive, do B1 then Track A, then return here)

### B1 — Local pre-flight script (cuts wasted cloud runs)

- [ ] `tools/preflight.sh`, run before every push:
  - `swift test` in `Packages/Core`
  - syntax-parse every Swift file with this Mac's compiler (`swiftc -frontend -parse`); report files it cannot parse, and separate genuine syntax errors from newer-Swift syntax this compiler does not know
  - the audit's static checks: bracket balance; no `import SharedUI`; `ManagedSettings` wherever `ApplicationToken` appears; `SwiftUI` wherever `DeviceActivityReport` appears; allowed imports in `UsageMonitor`; no file over 250 lines; no `print(`, `try!`, `as!`
  - every file listed under `sources:` in `project.yml` exists; every Swift file belongs to a listed source folder
  - every `Color("…")` and `Image("…")` name exists in an asset catalogue
  - every launch argument in `screens.yml` is handled in `DemoMode`
- [ ] Exit non-zero on any failure. Record the first full run in `PROGRESS.md`.

### B2 — Read-through of the 50 unbuilt files

- [ ] `docs/failure-classes.md`: one line for each compile failure met so far (the eight in `PROGRESS.md`, plus `buildExpression` from deferred `let` in a view builder, shadowed locals, Equatable with tuples, argument order in `DateComponents`, modifiers on the wrong type).
- [ ] For each Swift file changed since `337203d` (`git diff --name-only 337203d HEAD -- '*.swift'`), read it against that list and against Apple's documentation for every Screen Time, Swift Charts and SwiftUI call it makes. Fix what is found.
- [ ] `docs/unbuilt-review.md`: a table of the 50 files: checked, issues found, fixes made. Level stays **uncompiled**.

### B3 — More logic out of the views and under test

- [ ] `SummaryConfiguration` building: ranking, shares, hours text, centre lines and focus text produced by one pure `Core` function from seconds-per-app. Tests for each period and for focus on and off.
- [ ] `Aggregator`: keep the Screen Time walk thin; everything after "seconds per token, per day, per hour" is `Core`.
- [ ] Filter intervals for Summary (day, week, month, with `AppCalendar.uk`) tested for week and month edges and both clock changes.
- [ ] Demo state selection (`-state`, `-period`, `-focus`, `-sheet`) parsed by a pure `Core` function with tests, so a wrong argument cannot silently fall back to a default screen.

### B4 — Cheaper cloud runs

- [ ] One workflow run per push: when the message has `[screens]`, the screenshot job builds once and also writes the build verdict; `build.yml` skips. No double build.
- [ ] Skip the Core test step in the cloud when `Packages/Core` is unchanged in the push.
- [ ] Cache XcodeGen (download the release binary once, or cache Homebrew) and DerivedData between runs with `actions/cache`.
- [ ] Record each run's duration in `STATUS.txt` (`build: <sha> <status> <minutes>m`) and keep a running total in `docs/ci.md`.
- [ ] Capture list in two tiers: `[screens]` = 12 core captures; `[screens-all]` = the full manifest.

### B5 — Records brought back to the truth

- [ ] `REVIEW.md`: every requirement whose code changed since `337203d` drops to **uncompiled** until a build says otherwise; remove "screenshot" from R5, R11, R15; R16 becomes Summary; add R17. Add a dated "Audit of 25 November" section with the headline from Part 0.
- [ ] `PROGRESS.md`, `SESSION-HANDOFF.md`, `docs/screens.md`, `DESIGN-NOTES.md` and the spec agree with the code as it is.
- [ ] `TASKS-INDEX.md` at the root: lists `04` to `09` with status (closed, partly done, open) and what remains in each.
- [ ] Move `smartphone-dashallstats.jpg` to `design/reference/`. Note in `SKINS/README.md` that the "-2 dark" folder duplicates the dark skin.

### B6 — Ready for the day a build Mac arrives

- [ ] `tools/first-run.sh`: checks Xcode version, installs XcodeGen if absent, generates the project, runs the Core tests, builds for the simulator, and prints the next manual steps (signing team, run on iPhone).
- [ ] `docs/device-checks.md`: reorder into one sitting of about an hour: Gate A essentials first (data path, App Group read, embedded row reports, taps inside the Summary report, history depth), then A11 to A24.
- [ ] A one-page `docs/gate-a-card.md` the person can follow on the phone: step, what to look for, tick box.

### B7 — Summary page draft, pending the owner's answers

- [ ] List the ten `ASSUMED` rows from `08-SUMMARY-PAGE-PLAN.md` section 11 at the top of `REVIEW.md` with a one-line consequence each.
- [ ] Make each default a single switch in code (rank colours vs fixed order, Yearly flag, footer strip, palette set, font) so a changed answer is a one-line change. Tests for the pure parts.

---

## Part 3 — Track A: once the cloud answers

Budget: **10 build runs, 3 screenshot runs.** Run `tools/preflight.sh` before every push.

- [ ] A1 **Green build.** Fix compile errors in batches: read the whole error list from the log, fix every error in it, push once. Stop adding features until `BUILD SUCCEEDED`.
- [ ] A2 **Core captures.** Push with `[screens]`: home (default, over, paused), summary (weekly, weekly with focus 1, daily), detail (week, week with focus 4, month), target, onboarding card 1 and 4; light and dark for home, summary and detail. Every marker must match; no duplicates; no crashes.
- [ ] A3 **Self-check against the lists.** From `NOTE.txt` and the logs only: confirm V1 to V10 routes exist and the Summary markers carry period and focus. Fix and re-run within the budget.
- [ ] A4 **Stop for the visual review.** Write "READY FOR VISUAL REVIEW" with the commit at the top of `PROGRESS.md`. The pictures are checked by the reviewer, against `design/reference/` and `SKINS/*/screen.png`.
- [ ] A5 After the review's findings are fixed: `[screens-all]` once, then raise `REVIEW.md` levels to exactly what `NOTE.txt` proves.

---

## Part 4 — Close

- [ ] Repeat T0.2 if Track A has not run.
- [ ] `PROGRESS.md`: what was done, what was skipped and why, runs and minutes used, the level of every file.
- [ ] `SESSION-HANDOFF.md` updated. Commit, push, stop.

## Done when

- `tools/preflight.sh` passes on `main`.
- Every file changed since `337203d` appears in `docs/unbuilt-review.md`.
- `REVIEW.md` claims nothing the evidence does not show.
- Either a green build and a clean `NOTE.txt` exist for the current code, or the top of `PROGRESS.md` says plainly that the cloud is still silent and since when.
