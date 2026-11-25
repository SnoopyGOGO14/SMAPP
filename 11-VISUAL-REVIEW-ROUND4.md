# Visual review, round 4 — findings and fixes

25 November 2026, 21:50. Reviewed: the 16 captures on `ci-logs/screenshots` from `7377c25` (screens run 31). The run is marked "failure" only because the duplicate check fired (X1); all 16 markers matched and nothing crashed. Rules of `05-RUN-TO-REVIEW.md` apply. Budget: 3 build runs, 2 screenshot runs. Run `tools/preflight.sh` before every push and read its exit status directly. Before any `[screens]` push, build green first on a plain push.

## Confirmed fixed from round 3

W2 (focused segment keeps its colour, gold outline), W3 (Summary tab icon), W5 title row, W6 (no banner), W7 ("Sun · 49m"), W8 (40s), W9 hero consistency, W10 (Target caption), W11 (no system blue), W12 (one tab style), W1 in part (pills render, today inverted, future days disabled).

## Still to fix

### X1 — `-day 2` has no visible effect (the duplicate)
`summary-day2-dark.png` is byte-identical to `summary-daily-dark.png`: both show Wed selected and the same figures. The pill style exists; the argument is not reaching the selection.
- [ ] Trace `-day` from `DemoMode` through `Core`'s argument parser to `summaryDay`. Write the chosen day into the marker (`summary/daily/day2`) so the workflow proves it took effect.
- [ ] Demo data for a non-today day must differ from today's (use that day's figures from `Core.DemoSeries`), so the capture differs in content as well as in the pill.
- [ ] A `Core` test: parsing `-screen summary -period daily -day 2` yields day 2, and the data set for day 2 differs from today's.

### X2 — Colours change with the period (decision changed)
On Daily, TikTok is red; on Weekly, X is red and TikTok is teal; on Home TikTok's tile is red. Colour by rank makes the same app change colour from tab to tab.
- [ ] Switch the default to **colour by the user's row order** (`orderedTokens` index), the alternative already listed in plan 08 section 11. An app keeps one colour on every screen and in every period. Cards stay sorted by time; only the colour assignment changes.
- [ ] Update the `ASSUMED` row and the `Core` tests.

### X3 — Small times read badly as decimal hours
Summary Daily shows 58 minutes as "1 hr" and 11 minutes as "0.2 hrs".
- [ ] `HoursFormat`: under 60 minutes → minutes ("58 min", "11 min"); 1 hour and over → hours as now ("2.8 hrs", "29 hrs"). Applies to cards, the centre total and the top-app line. Update tests.

### X4 — 58m on Home, 59m on App detail
The same figure (58 m 40 s) is truncated on Home and rounded up on the detail hero.
- [ ] One rule everywhere: truncate to whole minutes for display. Add a `Core` test that Home's row and the detail hero give the same text for 3,520 seconds.

### X5 — Weekly demo figures are implausible
Weekly ranks X first at 6.7 hrs though it is the smallest app every day shown elsewhere.
- [ ] Weekly and monthly per-app totals come from summing the same daily series in `Core.DemoSeries`, so the weekly order follows the daily pattern (TikTok first). Test: weekly rank order equals the order of the summed daily series.

### X6 — Home row bar runs under the icon
The bar now spans the row but starts at the tile's left edge and touches the bottom of the tile.
- [ ] Bar starts at the text column (aligned with the app name), ends at the row's trailing edge, 8 pt below the name line. The tile sits clear of it.

### X7 — Empty band on App detail
There are about 80 pt of empty space between the navigation bar and the period tabs.
- [ ] Tabs sit 12 pt below the navigation bar.

### X8 — Month axis labels still truncated
The axis reads "1 … …".
- [ ] Draw the three labels (1, 15, 29) as an overlay positioned by day index, each with a fixed 28 pt width and no truncation.

### X9 — Last Summary card under the tab bar
- [ ] Bottom inset equal to the tab bar height plus 16 pt. Add a capture `summary-weekly-bottom-dark` scrolled to the end (launch argument `-scroll end`), marker `summary/weekly/end`.

## Then

- [ ] Plain push, confirm `BUILD SUCCEEDED`.
- [ ] Push with `[screens]`. A clean `NOTE.txt` has every marker matching (including `day2` and `end`) and no duplicates.
- [ ] Write "READY FOR VISUAL REVIEW, round 5" at the top of `PROGRESS.md` and stop.
