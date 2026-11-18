# Social Time Monitor — review pack

Written for the product owner, 18 November 2026, at the end of the
unattended run (05-RUN-TO-REVIEW.md). One page of truth about what the
repository contains and how sure we are about each part.

## Corrections after review

The first screenshot claim was wrong and is corrected here. A manual
review of the first captures found (18 November):

1. Only two of five screens were really captured — Home, All apps and
   dark Target were identical pictures of onboarding card 1; the demo
   routing never skipped onboarding or selected a tab.
2. The "onboarding" captures showed the iPhone home screen: the app
   crashed there (a missing environment in one demo route).
3. The daily bar chart merged days that share a weekday initial
   (T/T, S/S), drawing five bars for seven days — in the real app, not
   just the demo.
4. Alerts could repeat: monitoring restarted on every launch with
   nothing recording which alert had already been sent.
5. Weekly mode disagreed with itself: rolling 7 days on Home, a calendar
   week in alerts, and daily alerts firing alongside weekly ones.
6. Monitoring start-up errors were silently swallowed.
7. The two CI workflows overwrote each other's results on `ci-logs`
   (how one build's verdict disappeared).
8. This file overstated three features (R5, R11, R16) as
   screenshot-verified when only App detail (R15) had earned it.

Fixes F1–F9 in `06-FIXES-AFTER-REVIEW.md` address all eight; the
screenshot workflow now verifies every capture itself (screen marker,
process alive, no duplicate checksums) because GLM cannot see images.

## What works, and how sure we are

Levels: **tested** (unit tests pass), **compiles** (built successfully on
GitHub's Mac with Xcode 26.6), **screenshot** (rendered in a simulator),
**unverified on device** (needs an iPhone — everything Screen Time).

| # | Feature | Level |
| --- | --- | --- |
| R1 | Choose apps via Apple's picker | compiles; unverified on device |
| R2 | Per-app on/off switch (App detail) | compiles; unverified on device |
| R3 | Master switch (Target tab) | compiles; unverified on device |
| R4 | Usage statistics per app and combined | compiles; unverified on device |
| R5 | Charts: donut, daily bars, hero bars | compiles (an earlier build drew the daily chart with merged bars — fixed in F3; new captures pending) |
| R6 | Overall target, daily or weekly | tested (conversion logic) + compiles |
| R7 | Colour zones green/amber/orange-red | tested (boundaries at 75%/100%) + compiles |
| R8 | Weekly average logic | tested |
| R9 | Zone alerts at 75%/100% | compiles (one alert per line per interval — F4); unverified on device |
| R10 | Privacy: everything on the phone | compiles; privacy manifest + documents written |
| R11 | One-minute setup with presets | compiles; capture pending |
| R12 | Access health check + banner | compiles; unverified on device |
| R13 | Evening and Sunday recaps | compiles; unverified on device |
| R14 | Optional per-app targets | tested (cleanup logic) + compiles |
| R15 | App detail screen | screenshot (the one genuine capture set, close to the design) |
| R16 | All apps donut screen | compiles; capture pending |

Plus: **46 unit tests** pass (twice: on the 2016 Mac and in the cloud),
and the cloud build compiles app + both extensions on Xcode 26.6.

## Where to look

- **Screenshots** (if the capture run succeeded): the repo's `ci-logs`
  branch → `screenshots/` — five screens × light and dark, filled with the
  exact figures from the approved mock-ups. Compare them with
  `design/reference/*.dc.html` — GLM cannot see images, so this comparison
  is yours (L6).
- **The design canvas**: the three approved screens.
- **Build history**: the repo's Actions tab; latest green run is run 17.
- **Everything else**: `PROGRESS.md` (file-by-file honesty table, build
  budget, skipped list, assumed decisions).

## What could not be done, and why

1. **Nothing is proven on an iPhone.** The 2016 build Mac tops out at
   macOS 12; every device gate stays open. A newer Mac unblocks everything
   (`docs/build-mac-setup.md`, then `docs/device-checks.md` for Gate A).
2. **Visual comparison of screenshots** — GLM has no image input (also why
   the PDF and jpg renders went unread).
3. **VoiceOver and largest-text walkthroughs** — labels are in place;
   proving them needs hands on a device.
4. **App Group reads from the report extension** — the code path exists;
   Apple's sandbox drops extension *writes* by design, reads are expected
   to work but are proven only at Gate A.

## Decisions GLM made on your behalf (ASSUMED)

| Decision | Default used | The alternative |
| --- | --- | --- |
| Amber zone | On, from 75% of target | green and red only |
| App name | Social Time Monitor | your choice |
| Organisation ID | `YOURORG` placeholder everywhere | tell GLM your `com.x` |
| Websites (Safari) counted | No | add web-domain tokens |
| Recaps | Off until switched on | On |
| Per-app alerts | Out of scope for v1 | later |
| Pricing, launch countries | Left open | your call before listing |
| Neutral app-row bar scale | Fixed 60-minute reference (matches the mock within 0.4 pt) | not reachable inside a single-app report |
| Donut month caption | Hidden for Month | approximate monthly allowance |
| App icon | Placeholder ring gauge (`tools/make_icon.swift`) | your artwork |

## What you need to supply, in order

1. **A build Mac** (2018+ Intel until April 2027, or any Apple silicon).
2. **Apple Developer Program** membership; then `docs/portal-steps.md`
   (bundle IDs, App Group, Family Controls requests — answers pre-drafted
   in `docs/AppStore/family-controls-request.md`).
3. **Your organisation identifier** — GLM replaces `YOURORG` in one pass.
4. **Decisions** on every ASSUMED row above.
5. **An iPhone** on iOS 17.4+, ideally a second on the newest iOS, for
   `docs/device-checks.md` (Gate A) and the matrix in
   `03-ENGINEER-CHECKLISTS.md` §11.

## Gate A, step by step

`docs/device-checks.md` has the full table. In short: allow access, pick
two or three apps, use one for five minutes, then check that Home's total
matches Settings › Screen Time, that removing an app removes its time, and
that changing the target recolours the bar and moves the marker. Record
the result in `PROGRESS.md` — Gates B–D follow the same pattern.
