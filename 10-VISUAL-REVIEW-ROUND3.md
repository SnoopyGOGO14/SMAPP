# Visual review, round 3 — findings and fixes (step A5)

25 November 2026. Reviewed: the 15 captures on `ci-logs/screenshots` from `2997d30` (screens run 26), against `design/reference/`, `SKINS/*/screen.png` and `08-SUMMARY-PAGE-PLAN.md`. Rules of `05-RUN-TO-REVIEW.md` apply. Budget: 4 build runs, 2 screenshot runs (one `[screens]`, then one `[screens-all]`). Run `tools/preflight.sh` before every push, and check its exit status directly.

## Verdict

| Screen | Verdict |
| --- | --- |
| Home (default, over, paused; light and dark) | Good. Rows, tiles, bars, markers and states all render. Two small items: W11, W13 |
| App detail, week | Good. Bars rise from the baseline, today outlined, switch in the bar, one separator |
| App detail, focus and month | Works; four faults: W6, W7, W8, W9 |
| Summary, weekly (light and dark) | Close to the skins. Faults: W1, W3, W4, W5 |
| Summary, focus | The effect works (dim, gold card, centre swap). One real fault: W2 |
| Target | Demo state shows. Faults: W10, W11 |
| Onboarding 1 and 4 | Good |

## Fixes

### W1 — Day pills missing on Summary
The Mon to Sun row from the skins (plan section 3, item 2) is absent in every Summary capture.
- [ ] Add the pill row under the tabs: today inverted, future days disabled, tap = that day in Daily. Capture `summary-daily` with a non-today pill selected.

### W2 — Focused segment changes colour
In `summary-weekly-focus1-dark.png` WhatsApp (teal) is focused, but its segment is drawn solid yellow. In the skins the focused segment keeps its own colour and gains a gold outline and glow.
- [ ] Focused segment: own rank colour, thicker, `Focus` outline around it. Never recolour the fill.
- [ ] The card's dot and bar already keep teal; the segment must match them.

### W3 — Summary tab has no icon
The middle tab shows the word "Summary" with no symbol on every screen.
- [ ] Give it a symbol that exists in SF Symbols on iOS 17.4 (check the name; a missing name renders blank). Add a preflight check that every `systemImage:` name is on an allow-list verified against Apple's catalogue.

### W4 — Summary demo figures disagree with the other screens
Summary daily shows 2.8 hrs across TikTok, WhatsApp, Facebook, YouTube, X; Home shows TikTok 58m, Instagram 52m, YouTube 31m, Facebook 14m, X 11m. Summary weekly shows TikTok 37 hrs; App detail shows TikTok's week as 6h 13m.
- [ ] One coherent demo data set: daily = Home's five figures (total 2h 46m) ranked by time; weekly and monthly built from the same per-app daily series App detail uses. Drop the mock's 99.5-hour sample.
- [ ] A `Core` test that the Summary daily total equals the Home total and that TikTok's weekly figure equals the App detail weekly total.

### W5 — Summary details
- [ ] Hours text: drop a trailing ".0" ("8 hrs", "6 hrs", "1 hr"); keep one decimal otherwise ("5.3 hrs"). Update `HoursFormat` tests.
- [ ] Last card is hidden behind the tab bar. Add bottom content inset so the final card clears it when scrolled.
- [ ] Add the same title row as other tabs ("Summary" and the date) above the period tabs, or confirm with the product owner that the page stays untitled; default: add it.

### W6 — System banner in a capture
`detail-focus4-dark.png` has an iOS notification banner over the navigation bar.
- [ ] In `screens.yml`: wait for the simulator to settle after boot (30 s), then before each capture check the top 120 px against the screen's ground colour sample or simply retake once after 5 s if two consecutive captures differ. Log `RETAKEN` in `NOTE.txt`.

### W7 — Focused day label
The period line reads "S · 49m". With two S days and two T days a single letter is ambiguous.
- [ ] Use the short weekday name: "Sun · 49m". Month: "12 Nov · 49m".

### W8 — Seconds always zero
The period line reads "0d 6h 13m 0s" (and "0d 22h 15m 0s").
- [ ] Demo series carry seconds (design shows 40s). Confirm the real path passes seconds through `Aggregator` unrounded.

### W9 — Month view
- [ ] Hero shows "9m of 1h today" on Month but "58m" on 7 days. Today's figure must be identical across periods.
- [ ] Axis labels read "1, 8, …, …, …": the 15, 22 and 29 labels are truncated. Give labels room (fixed-width, no truncation) or show 1, 15, 29 only.

### W10 — Target contradiction
"3h a day" is shown with "No target set" directly beneath.
- [ ] Caption reflects the state: with a target, "About 21h a week"; with none, "No target set".

### W11 — Stray system blue
The selected tab's icon and label are system blue (Apps and Target). The design has no blue controls.
- [ ] Selected tab uses `PrimaryText`; unselected `SecondaryText`.

### W12 — One period control
App detail uses a segmented control (Today, 7 days, Month); Summary uses text tabs (Daily, Weekly, Monthly).
- [ ] App detail adopts the Summary tab style and wording, including the elapsed underline.

### W13 — Home row bar (minor)
The bar sits beside the name on the right half. The design runs it under the name across the row.
- [ ] Bar under the name and time, full row width, 6 pt.

### W14 — Demo tile colours (demo only)
On Home TikTok's tile is teal; on Summary TikTok is red. Real builds show real icons, so this affects demo captures only.
- [ ] In demo mode take the tile colour from the same rank colour the Summary uses.

## Then

- [ ] Push with `[screens]`; confirm markers. Write "READY FOR VISUAL REVIEW, round 4" in `PROGRESS.md` and stop for the pictures to be checked.
- [ ] After that review passes: one `[screens-all]`, raise `REVIEW.md` levels to what `NOTE.txt` proves, update the handoff, stop.
