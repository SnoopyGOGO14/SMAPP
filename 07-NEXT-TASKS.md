# Next task list — after the visual check of the 16 captures

18 November 2026. Reviewed: commit `1c15fa2` (code `337203d`, build run 19, screens run success). The self-checking screenshot run did its job: 16 distinct captures, every marker matching. The findings below come from looking at the pictures against `design/reference/`.

Same run rules, guard rails and honesty levels as `05-RUN-TO-REVIEW.md`: skip and log anything blocked, never wait. Budget for this list: **5 build runs and 3 screenshot runs**. Do Part 1 first and capture once before starting Part 2.

## Verdict on the captures

| Screen | Verdict |
| --- | --- |
| All apps | Matches the design. Donut, centre total and rows are right. |
| App detail | Close. Three faults: V3, V4, V5. |
| Home | Hero card right. The app rows are missing: V1, V2. |
| Target | Works, but shows "No target" while Home shows "of 3h": V6, V7. |
| Onboarding 1 to 4 | Wording is good. Layout is bare: V8. |

---

## Part 1 — Fix what the captures show

### V1 — Home shows "No apps chosen" in demo mode
`home-dark.png` and `home-light.png` show the hero card, then a "Set a target" button and an empty-state card. The five app rows never appear.
- [ ] In demo mode the Home body takes its state from `DemoData`: five rows, a target set, monitoring on. The empty-state and "Set a target" branches are bypassed.
- [ ] Rows per `DESIGN-NOTES.md`: 64 pt, tile, name, time on the right, thin bar with marker; the no-target row has a slate bar and no marker.

### V2 — Button labels invisible in dark mode
"Set a target" and "Choose apps" render as white text on a white pill in `home-dark.png`.
- [ ] Remove the global `.tint(Color("PrimaryText"))` on the tab view as the source of button colour. Give primary buttons one shared style (`PrimaryButtonStyle`): fill `PrimaryText`, label `Ground`, 50 pt high, full width, radius 16. Use it everywhere a primary action appears.
- [ ] Check every button in `home-dark.png`, `target-dark.png` and the onboarding captures after the next run: label and fill must differ.

### V3 — Daily bars float around the target line
In `detail-*.png` the seven bars are vertically centred instead of rising from a shared baseline, so short days hang in mid-air and tall days extend below the others.
- [ ] Bars share one baseline at the bottom of the chart area and grow upwards. Height = minutes ÷ scale maximum, where the maximum is the larger of 1.5 × target and the tallest day.
- [ ] The dashed target line sits at target ÷ maximum above the baseline. A bar crosses it only when that day is over target.
- [ ] Move the height calculation into `Core` (`ChartGeometry`) with tests: 44, 61, 38, 82, 49, 41, 58 against a 60-minute target → only the 61 and 82 bars exceed the line's height.

### V4 — Doubled separator in the status line
"Getting close · · 14m left" and "Getting close · · 2m left".
- [ ] One separator. Return the zone word and the remainder as two values from `Core` (`statusParts`) so the view never splits a formatted string. Test all three zones.

### V5 — Switch stranded below the navigation bar on App detail
There is a large empty band between the title and the switch.
- [ ] Put the on/off switch in the navigation bar's trailing position, on the same line as the back button and title. No empty band.

### V6 — Switch colours
The Monitoring switch renders white-on-white in dark mode and black in light mode.
- [ ] All switches use the system green when on. Check Monitoring, Zone alerts, Recaps and the detail switch in both appearances.

### V7 — Target tab ignores demo data
- [ ] In demo mode the Target tab shows the demo state: Daily, 3h selected, "3h a day", Monitoring on, Zone alerts on.
- [ ] The selected preset is visibly selected (filled with `PrimaryText`, label `Ground`); the others are outlined.

### V8 — Onboarding layout
Content is pinned to the top-left with a small blue button and two-thirds of the screen empty.
- [ ] Each card: the app's ring icon (from the asset catalogue) centred in the upper third, title and body centred beneath, one full-width `PrimaryButtonStyle` button pinned above the page dots.
- [ ] Card 4: four large preset tiles in a 2 × 2 grid ("1h", "2h", "3h", "4h", with "a day" beneath each), then "Choose my own".
- [ ] No system-blue anywhere; buttons follow V2.

### V9 — Demo tiles
- [ ] Commit the `icons/` folder. Build `App/Demo/DemoIcons.xcassets` from `icons/svg` as `icons/README.md` describes and add it to the app target.
- [ ] In demo mode each demo app shows the Solid tile for its palette index, in Home rows and the detail title. Debug builds only.

### V10 — Silver on white
The X row's silver dot and donut segment are faint in light mode.
- [ ] Give `DonutSilver` a darker light-appearance value (`#8E9AAF`); keep `#C9D2E0` for dark.

**Capture point:** push Part 1 with `[screens]`. Confirm from `NOTE.txt` that all markers match, then continue.

---

## Part 2 — Make every state reviewable

Extend demo mode so the product owner can see the screens that only appear in particular situations.

- [ ] `-state` launch argument, debug only: `default`, `over` (total 3h 20m of 3h, red), `comfortable` (1h 05m of 3h, green), `paused`, `noapps`, `notarget`, `noaccess` (banner showing).
- [ ] `-period today|week|month` for App detail and All apps. `DemoData` gains a 30-day series for Month.
- [ ] `-sheet target` opens the per-app target sheet over App detail. `-screen settings` opens Settings.
- [ ] Add to the capture list, dark appearance only unless noted:
  - home: `over`, `comfortable`, `paused`, `noapps`, `notarget`, `noaccess`
  - detail: `-period today`, `-period month`, `-sheet target`
  - allapps: `-period week`, `-period month`
  - settings (light and dark)
- [ ] Large text: capture home and detail once more after `xcrun simctl ui "$UDID" content_size accessibility-extra-large`, then reset to `large`. Check the option name against `xcrun simctl ui` help in the log first; if it is unavailable, log it and skip.
- [ ] Markers include the state and period (`home/over`, `detail/month`) and the workflow checks them the same way.
- [ ] `docs/screens.md`: a table of every capture file, what it shows and which requirement it evidences.

---

## Part 3 — Tighten before the device

- [ ] `Core` tests for everything new in Parts 1 and 2 that is pure logic (`ChartGeometry`, `statusParts`, demo state selection).
- [ ] VoiceOver labels re-read for Home rows, the donut and the chart after the layout changes.
- [ ] `docs/device-checks.md`: add three checks found in review: bars rise from the baseline with real data; an alert arrives once per line per day after opening the app several times; weekly mode totals the calendar week.
- [ ] Re-run `GATES.md` checks.

---

## Part 4 — Report

- [ ] `REVIEW.md`: a "Visual check, round 2" section listing V1 to V10 with before and after file names; update each requirement's level from the new `NOTE.txt`.
- [ ] `PROGRESS.md`: runs used, anything skipped, `ASSUMED` rows.
- [ ] `SESSION-HANDOFF.md` updated. Commit, push, stop.

## Done when

- `NOTE.txt` shows every capture with a matching marker and no duplicates.
- Home shows five rows in demo mode; bars rise from one baseline; one separator in each status line; switches green; no white-on-white or system-blue buttons.
- `docs/screens.md` lists every capture.
