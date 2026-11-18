# Device checks — Gate A

For the person with the build Mac and an iPhone (see
`docs/build-mac-setup.md` for getting the app onto a device first).
Everything on this page is unverified until you do it; record the result
and the iOS version in `PROGRESS.md`.

## Setup

1. Complete onboarding: allow Screen Time access, tick the Social category
   plus YouTube in the picker, choose a target (1 hour is fine for testing).
2. Use one or two of the chosen apps for about five minutes.

## Checks added after the Summary page plan (08)

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| A14 | Taps and animation inside the embedded report | On Summary, tap a donut segment and a card: the segment thickens with the gold outline, siblings dim, the centre text swaps; tap again to clear. If taps never arrive in the extension, record it — the demo-only focus fallback applies until a host-driven design exists | |
| A15 | History depth for Monthly and Yearly | Note how far back iOS returns data on the device; if less than a month, Monthly shows the available days with a note; Yearly stays hidden unless a year exists | |
| A16 | Focus with real data | Focus state survives a period change when the app is still present; centre figures match that app's card | |

## Checks added after the November visual review

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| A11 | Chart baseline with real data | Open App detail on a week with mixed days: every bar rises from one shared baseline at the bottom; short days do not float; only over-target days cross the dashed line | |
| A12 | One alert per line, per day | Switch alerts on, use an app past 75%, receive the alert; then force-quit and reopen the app several times — the 75% alert must not repeat (100% still arrives once when crossed) | |
| A13 | Weekly mode totals the calendar week | Set a weekly target and week start day; Home's total over the week must match Settings › Screen Time for the same Monday-to-Sunday span, not the last seven days | |

## Gate A checks

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| A1 | Home total | Matches Settings › Screen Time for those apps within a minute or two | |
| A2 | Home rows | Each app shows its own time; times add up to roughly the total | |
| A3 | Remove an app | Settings › Edit app selection → untick one app; its time disappears everywhere | |
| A4 | Change target | Target tab → change the number; the bar recolours and the marker moves | |
| A5 | App detail | Tap a row: today's card, period bars and stats appear; figures agree with Screen Time | |
| A6 | All apps donut | Segment sizes match each app's share; centre total matches | |
| A7 | Per-app target | Detail › Set a target; the row's bar recolours and gains a marker | |
| A8 | App Group read | If A4 and A7 recolour correctly, the report extension reads shared settings — note it explicitly | |
| A9 | Home load time | With five apps chosen, Home loads within about two seconds | |
| A10 | Row tap | Every row opens its detail screen | |

## If something fails

- Blank charts: check Settings › Screen Time › Apps With Screen Time Access
  is on for the app; relaunch.
- App Group read fails (A4/A7): stop after recording — the spec's risk
  table fallback (pass values through the filter) then applies; tell GLM.
- Wrong figures on one iOS version but right on another: note both.

Record everything in `PROGRESS.md` under a Gate A heading.
