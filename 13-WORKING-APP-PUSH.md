# Working-app push — 27 November 2026

Goal: **a functioning app on the product owner's iPhone**, by the shortest path. Polish waits. State: `main` at `f65183d`; cloud silent since 26 Nov 16:45; 33 Swift files (about 1,700 lines) unbuilt; everything up to screens run 40 proven.

Rules of `05-RUN-TO-REVIEW.md` apply (skip and log, never wait), with three changes for this push:

1. **Working first.** A task belongs in this list only if the app cannot run on a phone without it. Everything else goes to `docs/later.md`.
2. **Ponytail governs every change** (Part 1). Least code that works.
3. **No new unbuilt Swift.** Until a cloud build is green, Swift changes are limited to deletions and to fixes for compile errors.

## The honest shape of the problem

The code is not what stands between here and a working app. Three things are, and each needs the product owner once:

| Blocker | Unlocks | Owner action |
| --- | --- | --- |
| Cloud builds silent | Compiling anything | Make the repo public (no minutes limit) after Part 2 clears it, or restore Actions minutes |
| No Apple Developer membership | Signing a build an iPhone will accept | Join the Apple Developer Program |
| No Mac that runs Xcode 26 | Putting a build on the phone | **Not needed for a first working app if Part 4 succeeds**: the cloud signs it, and this Mac or TestFlight installs it |

---

## Part 1 — Ponytail

- [ ] 1.1 Read the project's own instructions at `github.com/DietrichGebert/ponytail` for the agent harness in use here. It installs lifecycle hooks: read every hook file before enabling it and record what each does in `docs/ponytail.md`. If the harness is unsupported or a hook does anything beyond injecting rules, do not install; copy the ruleset text into the agent's standing instructions and say so.
- [ ] 1.2 From here on apply its ladder to every change, in order: is it needed at all → reuse what the repo has → standard library → native Apple API → existing dependency → one line → the minimum. Record the rung chosen in each commit message.
- [ ] 1.3 Run its repo audit (or do the same by hand). Output `docs/ponytail-audit.md`: every file ranked by "would the app run on a phone without this?".
- [ ] 1.4 **Cut, do not add.** Move out of the app targets (to `parked/`, excluded from `project.yml`) whatever the audit shows is unneeded for a first run, provided the build stays simpler: candidate list to assess, not a mandate: host-driven focus fallback, single-report rows fallback, context-name codec scenes, recap notifications, Yearly code, extra demo states and modes, the footer strip switch. Keep: Diagnostics, the alerts kill switch, demo mode's core screens (the screenshot check depends on them).
- [ ] 1.5 `Core` tests still pass; preflight passes; nothing in `parked/` is referenced.

Done when: the app targets contain only what a first on-phone run needs, and the unbuilt pile is smaller than it was.

## Part 2 — Clear the repo to go public (so the cloud can run without limits)

- [ ] 2.1 Scan the whole history for secrets: `git log -p --all` searched for keys, tokens, `zai`, `sk-`, `BEGIN`, passwords, e-mail addresses, the Mac's user name and home path. Report findings in `docs/public-readiness.md`. If anything sensitive is in history, stop this part and say exactly what and where; do not rewrite history without instruction.
- [ ] 2.2 Check every committed file for personal details; replace with placeholders where harmless.
- [ ] 2.3 Add a `LICENSE` choice to `DECISIONS.md` (default: all rights reserved, no licence file).
- [ ] 2.4 Write the verdict at the top of `PROGRESS.md`: "SAFE TO MAKE PUBLIC" or the list of what must be fixed first.

## Part 3 — Green build (as soon as the cloud answers)

- [ ] 3.1 Probe: one plain push. If a verdict arrives, continue; if silent after 20 minutes, log it and go to Part 5.
- [ ] 3.2 Fix compile errors in whole-log batches until `BUILD SUCCEEDED`. Budget: 6 builds.
- [ ] 3.3 One `[screens]` run: home, summary weekly, detail week, target, settings, diagnostics; light and dark for home and summary. Clean `NOTE.txt`.
- [ ] 3.4 Write "READY FOR VISUAL REVIEW" in `PROGRESS.md`.

## Part 4 — The no-new-Mac route to the phone

The cloud Mac builds and signs; the phone gets the app through TestFlight or from this Mac over USB. **Unproven; verify every step against Apple's documentation before writing it, and record the pages.**

- [ ] 4.1 `docs/device-route.md`: the route end to end, with what is verified and what is assumed:
  - signing in the cloud with an App Store Connect API key (`xcodebuild -allowProvisioningUpdates` with `-authenticationKeyPath`, `-authenticationKeyID`, `-authenticationKeyIssuerID`), automatic signing for all three targets
  - Family Controls (Development) is self-service on each App ID; Family Controls (Distribution) needs Apple's approval and is required for TestFlight
  - registering the iPhone's identifier through the App Store Connect API so a development profile includes it
  - exporting a development-signed `.ipa` as a workflow artefact
  - installing that `.ipa` on the iPhone from this 2016 Mac over USB (candidates: Apple Configurator, `ideviceinstaller` from libimobiledevice; check which still supports the phone's iOS version and Developer Mode)
  - TestFlight as the simpler route once the Distribution entitlement is granted
- [ ] 4.2 `.github/workflows/device.yml`, run only on `workflow_dispatch` or a `[device]` commit message: generate project, archive with cloud signing, export development `.ipa`, upload as an artefact, write `device: <sha> <status>` to `STATUS.txt`. Secrets are read from repository secrets named `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `DEVICE_UDID`, `TEAM_ID`. **Never print, commit or log a secret.** With secrets absent the job exits cleanly with "secrets not set".
- [ ] 4.3 Replace `YOURORG` from one value, `ORG_ID`, read at project generation (environment variable or `Config/org.txt`), so the owner's identifier is a one-line change.
- [ ] 4.4 `docs/owner-steps.md`, click by click, for a non-engineer:
  1. Join the Apple Developer Program.
  2. Create an App Store Connect API key (role, where to download the `.p8`, the two IDs).
  3. Add the five repository secrets on GitHub (Settings › Secrets and variables › Actions).
  4. Find the iPhone's identifier and switch on Developer Mode.
  5. Start the device build (Actions › device › Run workflow) and download the `.ipa`.
  6. Install it (the method Part 4.1 verified).
  7. Open the app, go to Settings › Diagnostics, tap Copy report, and send it.
- [ ] 4.5 If any step in 4.1 turns out to be impossible, say which, and state the smallest alternative (for example an hour on a borrowed Apple silicon Mac, or a rented cloud Mac with screen sharing).

## Part 5 — First-run path, checked by reading

With no compiler, trace the one path a first run takes and make sure nothing on it can dead-end. Fix only defects; record each in `docs/first-run-trace.md`.

- [ ] 5.1 Launch → onboarding → Screen Time prompt → app picker → target preset → Home.
- [ ] 5.2 Home with real tokens: `homeTotal` report, one `appRow` report per app, row tap → App detail.
- [ ] 5.3 Summary with real tokens: periods, day pills, the `summary` report.
- [ ] 5.4 Target change → monitoring restart → `UsageMonitor` event → notification.
- [ ] 5.5 Every place the real path differs from demo mode is listed, since only demo mode has ever been seen running.

## Part 6 — Close

- [ ] 6.1 `docs/later.md`: everything parked or deferred, one line each.
- [ ] 6.2 `REVIEW.md`, `PROGRESS.md`, `TASKS-INDEX.md`, `SESSION-HANDOFF.md` updated with honest levels. The top of `PROGRESS.md` lists the owner's steps in order with a link to `docs/owner-steps.md`.
- [ ] 6.3 Commit, push, stop.

## Done when

- The app targets are smaller than at `f65183d` and preflight passes.
- `PROGRESS.md` says whether the repo is safe to make public.
- `device.yml` and `docs/owner-steps.md` exist, with every claim marked verified or assumed.
- Either a green build exists for the trimmed code, or the top of `PROGRESS.md` says the cloud is still silent and since when.
