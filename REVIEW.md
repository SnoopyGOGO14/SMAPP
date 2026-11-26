# Social Time Monitor — review pack

Written for the product owner. First written 18 November 2026; audited
and re-levelled 25 November (see below). One page of truth about what
the repository contains and how sure we are about each part.

## Audit of 25 November (read this first)

**The last successful cloud build was 18 November at 11:13 (`337203d`,
run 19). Since then 50 Swift files changed — the ten visual fixes, the
extra demo states and the whole Summary page — and none of it had been
through a compiler.** The capture branch held no screenshots of the
current code. This file's earlier levels overstated four features as
"screenshot" from captures of code since rewritten or removed.

State now (26 November, the close): every screen compiles (builds
green through run 39) and **the full 36-capture manifest verified —
every marker matched, no crashes, no duplicates (screens run 40,
NOTE.txt clean).** Visual reviews passed rounds 3–6; the last few
captures (Settings, the hourly Daily chart, the accessibility pair)
await your final eye-check. What remains unproven is everything that
needs a real iPhone: the Screen Time data itself, the alerts, and
interaction inside Apple's sealed usage view (Gates A–D).

## Corrections after review (18 November)

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
"uncompiled" = code changed since the last green build; not yet rebuilt.

| # | Feature | Level (25 Nov, after run 28) |
| --- | --- | --- |
| R1 | Choose apps via Apple's picker | compiles (run 28); unverified on device |
| R2 | Per-app on/off switch (App detail) | compiles (run 28); unverified on device |
| R3 | Master switch (Target tab) | compiles (run 28); unverified on device |
| R4 | Usage statistics per app and combined | screenshot (demo figures, all periods incl. the hourly Daily chart — run 40); live data unverified on device |
| R5 | Charts: ranked donut, daily bars, hero bars | screenshot — captured in both appearances, verified by the round 3–6 reviews |
| R6 | Overall target, daily or weekly | tested (conversion logic) + compiles (run 28) |
| R7 | Colour zones green/amber/orange-red | tested (boundaries at 75%/100%) + compiles (run 28) |
| R8 | Weekly average logic | tested |
| R9 | Zone alerts at 75%/100% | compiles (run 28); unverified on device |
| R10 | Privacy: everything on the phone | compiles; privacy manifest + documents written |
| R11 | One-minute setup with presets | screenshot — onboarding cards 1–4, both appearances (run 40) |
| R12 | Access health check + banner | captured (the noaccess state, run 40); the live health check unverified on device |
| R13 | Evening and Sunday recaps | compiles; unverified on device |
| R14 | Optional per-app targets | tested (cleanup logic) + compiles (run 28) |
| R15 | App detail screen | screenshot — week/month/hourly-Daily, focus, sheet (run 40) |
| R16 | **Summary page** (ranked donut, share cards, period tabs, day pills, focus) | screenshot — all periods, day selection, end-scroll (run 40) |
| R17 | Focus effect (donut segment ↔ card, centre cross-fade) | screenshot — focus1/focus4 markers, both appearances (run 40); Core logic tested |

Plus: **124 unit tests** pass (locally and in the cloud).
(25 November) rebuilt everything the outage had left uncompiled; screens
run 26 captured the 15 core screens — `NOTE.txt` on `ci-logs` is the
evidence (markers, checksums, no crashes). Full "screenshot" credit
waits for your visual review of those PNGs.

## Summary-page decisions GLM took as defaults (08 plan §11)

One line each; change any answer and the change is small:

| Decision | Default | Consequence if changed |
| --- | --- | --- |
| Where the page lives | Replaces All apps as the Stats tab, renamed Summary | a fourth tab needs RootTabs + spacing rework |
| Yearly tab | Hidden until a device shows a year of history | a greyed tab needs one flag flip (B7 switch) |
| App colours | **By the user's row order (position)** — X2 (round 4) reversed the earlier default: rank colouring made the same app change colour from tab to tab | by rank, largest first |
| Underline bar on the active tab | share of the period elapsed | share of target used would move it inside the report |
| Day pills | tap = that day, Daily view | pills on every period = one showsDayPills flag |
| Fonts | system font | Space Grotesk needs bundling + licence note |
| Red/yellow/green as app colours | kept, Summary only | non-zone hues = new Rank colour values only |
| Skin tokens | applied to every screen | Summary-only = revert five view colour calls |
| Footer strip from the mock | left out | shown = one view above the tab bar |
| App name | Social Time Monitor | rename = bundle ID stays, display name + docs |

## Decisions GLM made on your behalf (ASSUMED, project-wide)

| Decision | Default used | The alternative |
| --- | --- | --- |
| Amber zone | On, from 75% of target | green and red only |
| App name | Social Time Monitor | your choice |
| Organisation ID | `YOURORG` placeholder everywhere | tell GLM your `com.x` |
| Websites (Safari) counted | No (research verdict: app-only v1, opt-in domains v1.1) | add web-domain tokens |
| Recaps | Off until switched on | On |
| Per-app alerts | Out of scope for v1 | later |
| Pricing, launch countries | Left open | your call before listing |
| Neutral app-row bar scale | Fixed 60-minute reference (matches the mock within 0.4 pt) | not reachable inside a single-app report |
| Donut month caption | Hidden for Month | approximate monthly allowance |
| App icon | Placeholder ring gauge (`tools/make_icon.swift`) | your artwork |
| UK day boundary | `AppCalendar.uk()` (Europe/London) drives Summary | device-local time |

## Where to look

- **Screenshots**: the repo's `ci-logs` branch → `screenshots/` (empty
  at the audit; the 25 November `[screens]` run refills it).
- **The design canvas**: `design/reference/` and `SKINS/*/screen.png`.
- **Build history**: the repo's Actions tab; last green run 19
  (`337203d`, 18 Nov); run 24 (25 Nov) restarted the series.
- **Everything else**: `PROGRESS.md` (top section = 25 November run),
  `docs/unbuilt-review.md` (all 50 files), `09-AUDIT-AND-NEXT.md`.

## What could not be done, and why

1. **Nothing is proven on an iPhone.** The 2016 build Mac tops out at
   macOS 12; every device gate stays open. A newer Mac unblocks
   everything (`docs/build-mac-setup.md`, then `docs/device-checks.md`
   for Gate A).
2. **Visual comparison of screenshots** — GLM has no image input (also
   why the PDF and jpg renders went unread).
3. **VoiceOver and largest-text walkthroughs** — labels are in place;
   proving them needs hands on a device.
4. **App Group reads from the report extension** — the code path exists;
   Apple's sandbox drops extension *writes* by design, reads are
   expected to work but are proven only at Gate A.

## What you need to supply, in order

1. **A build Mac** (2018+ Intel until April 2027, or any Apple silicon).
2. **Apple Developer Program** membership; then `docs/portal-steps.md`
   (bundle IDs, App Group, Family Controls requests — answers
   pre-drafted in `docs/AppStore/family-controls-request.md`).
3. **Your organisation identifier** — GLM replaces `YOURORG` in one
   pass.
4. **Decisions** on every ASSUMED row above (both tables).
5. **An iPhone** on iOS 17.4+, ideally a second on the newest iOS, for
   `docs/device-checks.md` (Gate A; checks A1–A24) and the matrix in
   `03-ENGINEER-CHECKLISTS.md` §11.

## Gate A, step by step

`docs/device-checks.md` has the full table; `docs/gate-a-card.md` is the
one-page version. In short: allow access, pick two or three apps, use
one for five minutes, then check that Home's total matches Settings ›
Screen Time, that removing an app removes its time, and that changing
the target recolours the bar and moves the marker. Record the result in
`PROGRESS.md` — Gates B–D follow the same pattern.
