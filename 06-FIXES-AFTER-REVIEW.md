# Fixes after review — 18 November 2026

Review of commit `fd8bb31` (code state = `324a148`, cloud build run 17, Xcode 26.6). Work through F1 to F9 in order. Same run rules, guard rails and honesty levels as `05-RUN-TO-REVIEW.md`. Build budget for this list: 7 build runs and 3 screenshot runs.

## What the review confirmed

- All three targets compile (run 17, `BUILD SUCCEEDED`); the two later commits change documents only.
- 46 Core tests pass on the cloud Mac.
- No Swift file over 250 lines; no `print`, `try!` or `as!` in app code.
- `detail-dark.png` and `detail-light.png` are genuine renders of App detail and are close to the design.

## What the review found

| # | Finding | Evidence |
| --- | --- | --- |
| 1 | Only 2 of the 5 screens were captured. `home-*`, `allapps-*` and `target-dark` are the same picture: onboarding card 1. | `home-dark.png`, `allapps-dark.png`, `target-dark.png` have identical checksums; `home-light.png` = `allapps-light.png` |
| 2 | `onboarding-*.png` show the iPhone home screen: the app was not running when the picture was taken. | Image content; `OnboardingFlow()` is created without `.environment(appState)` in the `-screen onboarding` branch |
| 3 | The daily bar chart draws 5 bars for 7 days. Days sharing an initial (T/T, S/S) stack into one bar. This is in the real extension as well as the demo. | `PeriodCardView`: `Chart(..., id: \.label)` and `x: .value("Day", day.label)`; `AppDetailScene` builds labels from weekday initials |
| 4 | Alerts can repeat. Monitoring restarts on every app launch with `includesPastActivity: true` and nothing records which alert was already sent. | `SocialTimeMonitorApp` `.task`; `UsageMonitor` writes `lastCheckpoint` and never reads it |
| 5 | Weekly mode disagrees with itself: Home totals a rolling 7 days, alerts use the calendar week, and the daily activity still sends "today's target" alerts. | `Filters.homeTotal`, `MonitoringScheduler.restart` |
| 6 | Monitoring start-up errors are swallowed. | Empty `catch` blocks in `MonitoringScheduler` |
| 7 | The two workflows overwrite each other's results on `ci-logs`. | `build.yml` publishes with `git init` + force-push; build 18's summary was lost |
| 8 | `REVIEW.md` credits R5, R11 and R16 with "screenshot". Only R15 has earned it. | `REVIEW.md` lines 19, 25, 30 |
| 9 | Small design gaps: status word is grey (design: zone colour); today's bar has no outline; demo detail has no back, icon or name; Logger subsystem hard-codes `YOURORG`. | `detail-dark.png` against `design/reference/AppDetail.dc.html` |

---

## F1 — Demo routing

- [ ] In demo mode skip onboarding and the access banner entirely.
- [ ] `-screen home`, `allapps`, `target` select the matching tab in `RootTabs` (pass an initial selection).
- [ ] `-screen onboarding` wraps `OnboardingFlow` in `.environment(appState)`; add `-card 1…4` to open a given card.
- [ ] `-screen detail` uses the real `AppDetailScreen` chrome (back, icon tile, name, switch) around the demo card.
- [ ] Each screen, on appear in demo mode, writes its name to `Documents/demo-screen.txt` in the app container.

## F2 — Screenshot workflow that checks itself

GLM cannot see images, so the workflow must prove each capture.

- [ ] After each launch and wait, read the marker: `xcrun simctl get_app_container "$UDID" <bundle id> data`, then `cat Documents/demo-screen.txt`. It must equal the requested screen; otherwise write `MISMATCH <screen>` to `screenshots/NOTE.txt`.
- [ ] Confirm the app process is alive before the screenshot (`pgrep -f SocialTimeMonitor.app/SocialTimeMonitor`). If it is gone, write `CRASHED <screen>` and copy the newest crash report from `~/Library/Logs/DiagnosticReports` into `screenshots/`.
- [ ] After all captures, compute checksums. Any two files with the same appearance and the same checksum → write `DUPLICATE <a> <b>` and exit non-zero.
- [ ] Capture: home, allapps, detail, target, onboarding cards 1 to 4; light and dark.
- [ ] `screenshots/NOTE.txt` ends with one line per file: name, marker read, checksum.

## F3 — Bar chart identity

- [ ] Give `AppDetailConfiguration.DayValue` a unique `id` (the day's start date, or its index). Use it for `Chart` identity, the x value and the `ForEach` under the chart.
- [ ] Put the id and label generation in `Core` (`DayAxis`) with tests: 7 days and 31 days each yield unique ids; labels may repeat.
- [ ] Month period: one slim bar per day; label only the 1st, 8th, 15th, 22nd and 29th.
- [ ] Draw the dashed target rule once, outside the per-day loop.
- [ ] Outline today's bar.

## F4 — One alert per line, per period

- [ ] `Core.AlertLedger`: given the interval start, the percentage and the last alert sent, decide whether to send. Same interval and a percentage already sent → no. Tests: repeat suppressed; next day sends again; 100 after 75 sends; 75 after 100 in the same interval suppressed.
- [ ] `UsageMonitor` stores `lastAlert` (interval start + percentage) in the App Group and consults the ledger before posting.
- [ ] Restart monitoring only when a setting that affects it changes, or when `DeviceActivityCenter().activities` lacks the expected activity. Remove the unconditional restart on launch.

## F5 — Weekly mode, made consistent

- [ ] Weekly mode means week-to-date from `weekStartsOn` everywhere: Home total, status line, monitor interval.
- [ ] In weekly mode alerts come from the weekly activity only. The daily activity keeps saving checkpoints and posts nothing.
- [ ] Mark `ASSUMED` in `PROGRESS.md`: the alternative is a rolling 7 days.

## F6 — Visible monitoring errors

- [ ] Log every `startMonitoring` failure with `os.Logger` and save a short `lastMonitoringError` string and date.
- [ ] Settings shows "Alerts: running" or the saved error with a "Try again" button.
- [ ] Build the Logger subsystem from the bundle identifier.

## F7 — Workflows share `ci-logs` safely

- [ ] `build.yml` publishes the way `screens.yml` does: clone the branch, replace only its own files (`SUMMARY.txt`, `ci-*.log`), commit, push without force. On rejection: fetch, rebase, push; up to three attempts.
- [ ] `screens.yml`: the same retry; it replaces only `screenshots/`.
- [ ] Each workflow writes its own line (`build: <sha> <status>` / `screens: <sha> <status>`) to `STATUS.txt`.

## F8 — Design gaps

- [ ] Status word in the zone colour, rest of the line secondary.
- [ ] Confirm Home rows and the donut against `design/DESIGN-NOTES.md` once genuine captures exist: row height 64, bar marker, colour dots, centre total.

## F9 — Correct the record, then re-capture

- [ ] `REVIEW.md`: R5, R11, R16 back to "compiles" until a genuine capture exists; add a short "Corrections after review" section listing findings 1 to 8 in plain words.
- [ ] `PROGRESS.md`: the screenshot count is 2 genuine screens, not 5.
- [ ] Push with `[screens]`. Read `screenshots/NOTE.txt`. Fix and repeat within the budget until every line shows a matching marker and no duplicates.
- [ ] Update `REVIEW.md` levels from the final `NOTE.txt`, commit, push, stop.

## Done when

- `NOTE.txt` lists 16 captures, each with a matching marker, none duplicated, none crashed.
- The cloud build passes with the new Core tests.
- `REVIEW.md` matches what `NOTE.txt` proves.
