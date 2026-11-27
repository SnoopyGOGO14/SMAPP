# Next task list — prove the app behaves, not just that it draws

27 November 2026. State: `main` at `b109fdf`, build run 45 green, screens run 47 clean (22 captures), repo public (no build-minutes limit).

Screenshots prove each screen can be drawn. Nothing yet proves that tapping things works, that the non-demo app starts without crashing, or that the code builds for a real iPhone rather than the simulator. This list closes those three gaps with the cloud alone, while the Developer Program enrolment is pending.

Rules of `05-RUN-TO-REVIEW.md` and the Ponytail ladder apply: least code that works, record the rung in each commit. Run `tools/preflight.sh` before every push. Budget: 12 build runs, 4 screenshot or test runs. Skip and log anything blocked; never wait.

---

## Part 1 — Build for a real iPhone (device architecture)

- [ ] 1.1 Add a job `device-compile` to `build.yml`: `xcodebuild build -scheme SocialTimeMonitor -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO`. Simulator and device builds differ; this is the first time the device one is tried.
- [ ] 1.2 Add a Release-configuration build of the same destination. Confirm no `#if DEBUG` code (Diagnostics, demo mode) is referenced from release paths.
- [ ] 1.3 Run `device.yml` with no secrets set and confirm it exits cleanly with "secrets not set" and writes its `STATUS.txt` line.
- [ ] 1.4 Fix what these find. Record device-only failure classes in `docs/failure-classes.md`.

Done when: `STATUS.txt` carries `device-compile: <sha> success` for Debug and Release.

## Part 2 — The real app starts (no `-demo`)

Demo mode is the only thing ever seen running. The live path must at least launch and behave sensibly where Screen Time is unavailable.

- [ ] 2.1 In `screens.yml`, add a `live` set: launch with **no** `-demo` argument on a fresh simulator. Capture after 5 s (`live-launch`), then check the process is still alive.
- [ ] 2.2 Launch arguments for the live path only (debug builds): `-skipOnboarding`, `-screen home|summary|target|settings|diagnostics`. No demo data: the app shows whatever its real code produces with access not granted.
- [ ] 2.3 Capture each of those live screens. Expected: onboarding card 1 on first launch; with onboarding skipped, the access banner and empty states. A crash, a blank screen or a spinner that never ends is a finding.
- [ ] 2.4 Capture `live-diagnostics`: it should show honest values for a simulator (access not determined, selection empty, host App Group round trip).
- [ ] 2.5 Fix crashes and dead ends found. Record in `docs/first-run-trace.md` which live behaviours are now seen running.

Done when: every live capture has a matching marker, the process survives each, and none shows a blank or stuck screen.

## Part 3 — Interaction tests (taps, navigation, state)

A UI test target that drives the demo app in the simulator. Keep it small: one test per behaviour, no helpers beyond what repeats three times.

- [ ] 3.1 Add `SocialTimeMonitorUITests` (XCUITest) to `project.yml`; a workflow `uitests.yml` triggered by `[uitests]` that runs it on one simulator and publishes the result summary and any failure screenshots to `ci-logs/uitests/`.
- [ ] 3.2 Give every interactive element a stable accessibility identifier (reuse existing labels where they are already unique).
- [ ] 3.3 Tests, each launching with `-demo`:
  1. Tab bar: Apps → Summary → Target → Apps; each screen's title appears.
  2. Home: tap the TikTok row → App detail shows "TikTok"; back returns to Home.
  3. App detail: Daily, Weekly, Monthly tabs each change the period card's text.
  4. App detail: tap a day bar → the period line changes to that day; tap again → it returns to the total.
  5. App detail: open the target sheet, choose 45m, close → the hero reads "of 45m" and the status word changes.
  6. App detail: switch monitoring off → the Home row for that app dims or leaves the total.
  7. Summary: tap a card → the centre text shows that app; tap again → it clears.
  8. Summary: tap a past day pill → Daily is selected and the total changes; future pills are disabled.
  9. Target: choose 2h → Home hero reads "of 2h" and the zone word changes to "Over target".
  10. Target: Monitoring off → Home shows "Paused"; on → figures return.
  11. Settings: change amber point; remove a per-app target → its row leaves the list and the Home row loses its marker.
  12. Onboarding: from card 1 to card 4 with `-demo -screen onboarding`, choosing 3h lands on Home.
  13. Relaunch: change the target, terminate, relaunch → the change persisted.
- [ ] 3.4 Each failing test is a finding: fix the app, not the test, unless the test is wrong. List every fix in `PROGRESS.md`.

Done when: `ci-logs/uitests/SUMMARY.txt` shows 13 of 13 passing on the current commit.

## Part 4 — Full manifest after the trim

- [ ] 4.1 One `[screens-all]` run on the trimmed code. Confirm the parked features left no hole: every marker matches, no duplicates.
- [ ] 4.2 Update `docs/screens.md` for captures removed with parked features and for the new live set.

## Part 5 — Close

- [ ] 5.1 `REVIEW.md`: add a level **behaves** (UI test passes) above **screenshot**; set each requirement to the highest level its evidence shows. Device-dependent items stay **unverified on device**.
- [ ] 5.2 `docs/gate-a-card.md`: remove any step now proven by Parts 1 to 3; keep only what needs the phone.
- [ ] 5.3 `PROGRESS.md` top line: "READY FOR REVIEW: device compile, live launch, UI tests", with the commit. Update `TASKS-INDEX.md` and `SESSION-HANDOFF.md`. Commit, push, stop.

## Waiting on the product owner

Apple Developer Program enrolment, then `docs/owner-steps.md`. Answers to `DECISIONS.md` at any time.
