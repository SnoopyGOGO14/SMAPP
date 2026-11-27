# Next task list — 27 November 2026

State at 11:55: `main` at `1a9c8c9`. The cloud has published nothing since 26 Nov 16:45 (build run 39, screens run 40). The Settings fixes (`d34d3de`) are **locally verified only**. Everything through screens run 40 is proven: 36 of 36 captures.

Rules of `05-RUN-TO-REVIEW.md` apply: skip and log anything blocked, never wait. Run `tools/preflight.sh` before every push and read its exit status directly. **No pushes that trigger a build until Part 0 says the cloud is back**: use `[skip ci]` on every commit in Parts 1 to 5, so nothing queues behind a dead runner.

The theme of this list: the next real event is the one-hour device session (Gate A) on a newer Mac. Everything here makes that hour decisive and makes sure no Gate A result is a dead end.

---

## Part 0 — Resume the cloud when it answers (check at the start and at the end)

- [ ] 0.1 `git fetch origin ci-logs`; if `STATUS.txt` has a line for `d34d3de` or later, the cloud is back.
- [ ] 0.2 If back: one plain push to confirm green, then one `[screens]` push. Check `settings-light`, `settings-dark` and `detail-a11y` markers. Write "READY FOR VISUAL REVIEW, S-round" in `PROGRESS.md`.
- [ ] 0.3 If silent: record the time and carry on. Do not probe again until the end of this list. Budget when back: 2 builds, 1 screenshot run.

---

## Part 1 — Diagnostics screen (the most valuable thing to build now)

A debug-only screen that turns Gate A from guesswork into a checklist the phone fills in itself.

- [ ] 1.1 `App/Diagnostics/DiagnosticsScreen.swift`, reached from Settings in debug builds (`#if DEBUG`) and by `-screen diagnostics`.
- [ ] 1.2 Sections, each with a plain PASS / FAIL / UNKNOWN and the raw value:
  - **Access**: authorisation status now; time last checked.
  - **Selection**: count of chosen apps, enabled apps, per-app targets; whether the stored selection decoded.
  - **App Group, host side**: write a timestamp, read it back.
  - **App Group, extension side**: an embedded report, context `diagnostics`, that draws the timestamp and target it read. This is the single most important unknown.
  - **Data path**: the same report draws today's total seconds, number of apps returned, and number of day segments returned for a 35-day request (the history depth).
  - **Embedded rows**: five `appRow` reports with a host-side stopwatch from appear to first layout callback, where measurable; otherwise "time it by eye" with a visible counter.
  - **Taps in a report**: a report with one button that increments a counter it draws itself. Count rises = taps arrive inside the sealed view.
  - **Monitoring**: `DeviceActivityCenter().activities`, `lastCheckpoint`, `lastAlert`, `lastMonitoringError`.
  - **Notifications**: permission status; a button that schedules a local test notification for 10 seconds ahead.
  - **Build**: version, commit hash (injected at build time), iOS version, device model.
- [ ] 1.3 "Copy report" button: one plain-text block of everything the host knows, for pasting into a message. Extension-drawn values are read off the screen by the person; the report lists them as blanks to fill in.
- [ ] 1.4 `Core`: the report formatter and PASS/FAIL rules as pure functions with tests.
- [ ] 1.5 Demo mode shows the screen with sample values, so it can be captured (`-screen diagnostics`) when the cloud is back.
- [ ] 1.6 Rewrite `docs/gate-a-card.md` around this screen: open Diagnostics, work down it, copy the report. Target: 30 minutes, down from an hour.

Done when: preflight passes; the screen exists behind `#if DEBUG`; the Gate A card refers to it step by step.

---

## Part 2 — A fallback ready for each Gate A outcome

Each unknown gets a switch in one file (`App/FeatureSwitches.swift`), with both paths written now, so a failed check on the day is a one-line change and a rebuild.

| Unknown | If it fails | Build now |
| --- | --- | --- |
| Extension cannot read the App Group | Targets never reach the report | Fallback path: the host encodes target minutes and amber point into the report **context name** from a fixed set (for example `homeTotal.t180.a75`), the extension decodes it. `Core` encoder and decoder with tests; contexts registered for 15-minute steps from 15 m to 8 h |
| One report per Home row is slow or blank | Home rows unusable | Single `appRows` report drawing all rows at fixed 64 pt, with host-side transparent tap areas in the same order. Switch: `homeRowsMode = perRow / single` |
| Taps do not arrive inside a report | Summary focus is dead | Host-driven focus: host-owned transparent overlay over the cards and a legend strip; selection passed by context name (`summary.f0` … `summary.f7`). Switch: `summaryFocusMode = inReport / hostDriven` |
| History shorter than a month | Monthly is misleading | Monthly tab hidden when the diagnostics report shows fewer than 28 day segments; "Showing the last N days" otherwise. Switch reads a stored `historyDays` value set from Settings › Diagnostics |
| `Label(token)` blank inside the extension | Rows lose icons and names | Host draws icon and name beside every report (already true on Home; make it true on Summary cards via the host-driven layout) |
| Threshold events fire early | False alerts | Already guarded; add a switch to turn alerts off entirely and show "Alerts paused: under test" in Settings |

- [ ] 2.1 Implement each fallback path and its switch. Default stays the current behaviour.
- [ ] 2.2 `Core` tests for every encoder, decoder and mode selection.
- [ ] 2.3 Demo mode honours the switches via `-mode <name>` so each fallback can be captured later.
- [ ] 2.4 `docs/gate-a-outcomes.md`: for each Diagnostics line, "if PASS do nothing; if FAIL set this switch to this value", in a table.

Done when: every row in the table has code on both sides of its switch and a line in the outcomes document.

---

## Part 3 — Decision pack for the product owner

- [ ] 3.1 `DECISIONS.md` at the root, one page, written for a non-engineer. For each open or `ASSUMED` decision: the question in one sentence, the current default, the alternative, what changes on screen, and which capture shows it. Include: app name; fonts; Yearly tab; amber point; websites counted; recaps default; weekly mode definition; pricing; launch countries; colours by row order; footer strip; per-app alerts.
- [ ] 3.2 Each answer maps to a named switch or a single constant. List the file and line beside it.
- [ ] 3.3 `docs/copy.md`: every user-facing string in the app in one table (screen, key, text), so the owner can edit wording in one place. Generated from the String Catalog by a script in `tools/`; add the script to preflight so the table cannot drift.

---

## Part 4 — Release materials finished as far as they can be

- [ ] 4.1 `docs/AppStore/listing.md`: three name options, subtitle, promotional text, description, keywords, support and marketing URLs as placeholders, age rating answers, category. No third-party brand names anywhere.
- [ ] 4.2 `docs/AppStore/screenshots.md`: which six captures become store screenshots, in order, with a caption for each; the device sizes Apple currently requires (check Apple's page and record the date checked).
- [ ] 4.3 `docs/AppStore/review-notes.md` and `family-controls-request.md` re-read against the app as built (Summary page, per-app targets, diagnostics excluded from release).
- [ ] 4.4 `docs/AppStore/privacy-policy.md` and a plain `support.md` (how to grant and withdraw access, why history is limited, why icons come from iOS).
- [ ] 4.5 `Config/PrivacyInfo.xcprivacy` re-checked against Apple's current required-reason list; record the date checked.
- [ ] 4.6 A release checklist in `docs/release.md` from "build Mac arrives" to "submitted", each step tagged person or builder.

---

## Part 5 — Quality without a compiler

- [ ] 5.1 `Core` edge tests: leap day, year end, both UK clock changes for every period, a week spanning two months, zero usage, one app, twelve apps (palette wrap), a 23-hour day, targets of 15 minutes and 8 hours.
- [ ] 5.2 Accessibility read-through of every view: each control has a label, value and trait; write the VoiceOver script per screen in `docs/accessibility.md`.
- [ ] 5.3 Dead-code pass: anything unreachable since the Summary page replaced All apps, unused assets, unused strings. Preflight gains an unused-asset and unused-string check.
- [ ] 5.4 `docs/architecture.md` redrawn for the app as built: targets, contexts, App Group keys, switches, what draws what, one Mermaid diagram.
- [ ] 5.5 Re-read every file changed since the last green build (`d165792`) against `docs/failure-classes.md` and record it in `docs/unbuilt-review.md`.

---

## Part 6 — Close

- [ ] 6.1 Part 0 once more.
- [ ] 6.2 `REVIEW.md`: levels unchanged for anything not rebuilt; new work listed as **locally verified**; a dated section for this round.
- [ ] 6.3 `PROGRESS.md`, `TASKS-INDEX.md` (add `10`, `11`, `12`) and `SESSION-HANDOFF.md` updated. Commit with `[skip ci]`, push, stop.

## Waiting on the product owner

1. **The cloud.** Open the repo's Actions tab. A queued or failed run for `d34d3de` shows the cause. If it is the minutes allowance, the choices are: make the repo public (no limit), wait for the allowance to refill at the next billing cycle, or use the new Mac as a self-hosted runner once it arrives.
2. **The newer Mac** (Apple silicon), then `tools/first-run.sh` and the Gate A card.
3. Apple Developer Program, portal steps, organisation identifier.
4. Answers in `DECISIONS.md` once Part 3 produces it.
