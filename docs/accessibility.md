# Accessibility — the VoiceOver read-through (Part 5.2)

Per screen, what VoiceOver reads and the script for a hands-on pass.
Labels come from the code (28 accessibility annotations across App and
SharedUI); traits and values noted where they matter. The hands-on
pass needs a device or the simulator's VoiceOver (Cmd-F5 with the
simulator focused).

## Home

- The hero card: "Today's total" plus the status line's zone word and
  remainder — one element.
- Each app row: name + time + zone ("TikTok, 58 minutes, comfortable"
  via AppRowReportView's label); the row is a link (navigation trait
  comes from NavigationLink).
- Empty state: "No apps chosen", button "Choose apps".
- The paused card reads "Paused".

## App detail

- Toolbar: Back (labelled "Back"), title (the app's name via
  Label(token)), the Monitor switch (native Toggle semantics — label
  "Monitor").
- Period tabs (PeriodTabsControl): container "Period"; each tab is a
  button with the selected trait when active.
- Today card + period card: one element each, "58m of 1h today, …";
  the period card's total reads as "Total X; N of M days within
  target" (or busiest hour when hourly).
- Bars are decorative (hidden) — the card's label carries the data.
- Tapping a bar focuses a day: the linked line announces "Sun · 49m".

## Summary

- Title row: "Summary", the date.
- Period tabs: as on detail; the underline bar is hidden.
- Day pills: weekday letters, `isSelected` on today/picked; future
  pills are disabled (VoiceOver says "dimmed").
- Donut: one element, "Total 99.5 hrs across 5 apps"; the centre text
  is part of it.
- App cards: "TikTok, 6.2 hrs, 37.4 percent" — the share bar hidden.

## Target

- Mode picker, preset buttons ("1h"…), stepper, all native semantics;
  the zone preview line is plain text.
- Switches: Monitoring / Zone alerts / Recaps — native Toggle.

## Settings

- Amber stepper ("Amber from 75%"), week-start picker (labelled),
  per-app target rows (app name + minutes + Edit/Remove buttons),
  privacy text plain.

## Onboarding

- Cards: icon hidden, title + body as text; buttons native. Card 4's
  preset tiles are buttons with "1h"/"2h"…

## Diagnostics (debug only)

- Rows are "title, value" pairs; the tap-test button announces its
  count ("Tap test, 3 taps so far").

## VoiceOver script for the device pass (10 minutes)

1. Home: swipe right through rows — every app name + minutes spoken;
   double-tap opens detail.
2. Detail: read the toolbar line, then the period card; swipe to the
   bars — nothing extra announced (bars hidden); double-tap a bar —
   the linked line changes and is announced.
3. Summary: donut announces the total; cards announce name/time/share;
   tabs announce selection state.
4. Target/Settings: toggle states are spoken on/off; steppers
   increment audibly.
5. Dynamic Type at the largest size: nothing overlaps (the a11y
   captures show the layout).

Gaps found in the read-through (fixed where cheap): the row bar and
underlines were already hidden; the Diagnostics rows needed a combined
element (added `children: .combine`). Nothing else missing.
