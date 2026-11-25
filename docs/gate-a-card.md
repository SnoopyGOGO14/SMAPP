# Gate A card — one sitting, about an hour

Print this (or open it on the Mac) and do it on the phone after
`tools/first-run.sh` succeeds and the app runs. Tick as you go; record
anything unexpected in `PROGRESS.md`. The full detail behind each step
is `docs/device-checks.md` (A1–A24).

## Set up (5 min)

1. Allow Screen Time access; tick the **Social** category + **YouTube**.
2. Target: **1 hour a day**. Switch Monitoring on.
3. Use TikTok (or any chosen app) for about five minutes.

## The essentials — the data path (15 min)

- [ ] **Home total** matches Settings › Screen Time for those apps
      within a minute or two. (A1)
- [ ] **Each Home row** shows its own time; the rows roughly add up to
      the total. (A2)
- [ ] **Untick one app** in Settings › Edit app selection — its time
      disappears everywhere. (A3)
- [ ] **Change the target** — the bar recolours and the marker moves.
      If the colour *and* the marker move, the report extension reads
      the App Group (A4 + A8).
- [ ] **Tap a row** — detail opens with the today card, bars and stats.
      (A5, A10)
- [ ] **Summary tab**: donut segments match each app's share; the
      centre total matches; tapping a segment and a card focuses (gold
      ring, centre text swaps, tap again clears). (A6, A14, A16)
- [ ] **Bars rise from one baseline**; only over-target days cross the
      dashed line. (A11)
- [ ] **History depth**: how far back does Monthly go? Note it. (A15)

## Alerts and weekly mode (20 min, can overlap with app use)

- [ ] Alerts on; pass 75% of target → **one** notification. Force-quit
      and reopen the app several times → the 75% alert does not repeat.
      (A12)
- [ ] Set a weekly target + week start day: Home's weekly total matches
      Settings › Screen Time for the same calendar week. (A13)

## Behaviours worth one look each (10 min)

- [ ] PiP and backgrounded audio (A21): which, if either, accrues?
- [ ] Note (no test needed): private tabs never count; browsers vary
      (A18–A20 are for when web domains are enabled).

## If something fails

- Blank charts: Settings › Screen Time › Apps With Screen Time Access
  must be on for the app; relaunch once.
- Wrong on one iOS version but right on another: note both.
- App Group read fails (target change does nothing): stop and record —
  the spec's fallback applies; tell GLM.

**When done:** write the results (with iOS version) into
`PROGRESS.md` under a "Gate A" heading — that opens or closes every
device-dependent claim in `REVIEW.md`.
