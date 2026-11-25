# Device checks — Gate A

For the person with the build Mac and an iPhone (see
`docs/build-mac-setup.md` for getting the app onto a device first, and
`docs/gate-a-card.md` for the one-page version of the first sitting).
Everything on this page is unverified until you do it; record the result
and the iOS version in `PROGRESS.md`.

Reordered 25 November (B6): one sitting of about an hour, essentials
first — the data path, the App Group read, embedded row reports, taps
inside the Summary report, and history depth — then everything else in
check order.

## Setup

1. Complete onboarding: allow Screen Time access, tick the Social category
   plus YouTube in the picker, choose a target (1 hour is fine for testing).
2. Use one or two of the chosen apps for about five minutes.

## Part 1 — the essentials (one sitting, ~1 hour)

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| A1 | Home total | Matches Settings › Screen Time for those apps within a minute or two | |
| A2 | Home rows | Each app shows its own time; times add up to roughly the total (the embedded per-row reports) | |
| A5 | App detail | Tap a row: today's card, period bars and stats appear; figures agree with Screen Time | |
| A4 | Change target | Target tab → change the number; the bar recolours and the marker moves | |
| A7 | Per-app target | Detail › Set a target; the row's bar recolours and gains a marker | |
| A8 | App Group read | If A4 and A7 recolour correctly, the report extension reads shared settings — note it explicitly | |
| A6 | Summary donut | Segment sizes match each app's share; centre total matches | |
| A14 | Taps and animation inside the embedded report | On Summary, tap a donut segment and a card: the segment thickens with the gold outline, siblings dim, the centre text swaps; tap again to clear. If taps never arrive in the extension, record it — the demo-only focus fallback applies until a host-driven design exists | |
| A16 | Focus with real data | Focus state survives a period change when the app is still present; centre figures match that app's card | |
| A15 | History depth for Monthly and Yearly | Note how far back iOS returns data on the device; if less than a month, Monthly shows the available days with a note; Yearly stays hidden unless a year exists | |
| A3 | Remove an app | Settings › Edit app selection → untick one app; its time disappears everywhere | |
| A10 | Row tap | Every row opens its detail screen | |

## Part 2 — the rest, in check order

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| A11 | Chart baseline with real data | Open App detail on a week with mixed days: every bar rises from one shared baseline at the bottom; short days do not float; only over-target days cross the dashed line | |
| A12 | One alert per line, per day | Switch alerts on, use an app past 75%, receive the alert; then force-quit and reopen the app several times — the 75% alert must not repeat (100% still arrives once when crossed) | |
| A13 | Weekly mode totals the calendar week | Set a weekly target and week start day; Home's total over the week must match Settings › Screen Time for the same Monday-to-Sunday span, not the last seven days | |
| A17 | Time-zone accrual | Change the device time zone mid-day (or note it while travelling): the day's threshold boundary follows the schedule's start time zone, not local midnight — record which the totals follow | |
| A18 | Web-domain monitoring (if enabled) | Select youtube.com in the picker; watch in a normal Safari tab → the domain row accrues; repeat in a Private tab → it must not | |
| A19 | Browser reality check | Watch in Chrome and Firefox: note whether any domain-level time appears (expected: none or partial) and whether browser app time appears if their app tokens are selected | |
| A20 | Home-screen web app | Add youtube.com to the Home Screen, watch from the icon: record whether it appears as its own entry and whether it lands in Safari or domain time | |
| A21 | PiP and background audio | Watch YouTube in Picture in Picture, then with the app backgrounded (Premium audio): record which, if either, accrues | |
| A22 | Per-app pulse events (§8 of monitoring-analysis) | Test build registers one extra `DeviceActivityEvent` per enabled app (`app.<n>`, 1-min threshold) alongside the six checkpoints; record whether iOS accepts ~11 events per activity and whether `UsageMonitor` wakes per app without breaching the memory ceiling | |
| A23 | Unused signal populates (§7) | Test report scene displays raw `numberOfPickups` and `numberOfNotifications` per application; after a day of normal use both should be non-zero for the chosen apps | |
| A24 | Shortcuts automation open signal (§8, only if a nudge mode is ever built) | Set "When TikTok is opened → run shortcut"; over ~20 openings record firing delay, missed fires, and whether a close event also fires | |

## If something fails

- Blank charts: check Settings › Screen Time › Apps With Screen Time Access
  is on for the app; relaunch.
- App Group read fails (A4/A7): stop after recording — the spec's risk
  table fallback (pass values through the filter) then applies; tell GLM.
- Wrong figures on one iOS version but right on another: note both.

Record everything in `PROGRESS.md` under a Gate A heading.
