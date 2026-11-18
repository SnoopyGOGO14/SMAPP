# Social Time Monitor — approved screen designs (18 November 2026, simplified)

Three screens. The product owner's instruction: **simple and uncluttered on every page**. One big number, one bar, short rows. When in doubt, leave it out.

The HTML files in `design/reference/` are the source of the mock-ups: read them for exact sizes, spacing, copy and colours. They are reference only (they need the design canvas to render); build the screens in SwiftUI.

| Screen | Reference file | Reached from |
| --- | --- | --- |
| Home (today) | `reference/Main.dc.html` | Apps tab |
| App detail | `reference/AppDetail.dc.html` | tapping a Home row or an All-apps row |
| All apps (overall time, donut) | `reference/AllApps.dc.html` | Stats tab |

All figures in the mock-ups are sample data. App tiles show initials because the mock cannot use brand artwork; the app shows real icons and names through `Label(token)`.

## Look

- Dark first. Ground `#0D1014`, card `#171B21`, divider `#232830`, bar track `#262C35`, text `#F4F6F8`, secondary text `#A3ACB9`. Provide a light-mode set with the same roles.
- Type: system font. Screen title 30 bold. Hero figure 54 bold. Row text 15. Captions 12–14. Use the nearest Dynamic Type styles.
- Cards radius 24, app icon tile radius 10, bars fully rounded. Generous padding (20–22 inside cards).
- Zone colours are semantic system colours (decision already in `PROGRESS.md`): green = comfortable, orange = getting close, red = over target. A bar is one solid zone colour. The zone is also written as a word once per screen.
- Target marker: a white 3 pt vertical line across the bar. No label on the marker.
- Donut palette (categorical, avoids green, orange and red): teal `#26C6C6`, pink `#F0569A`, blue `#4C8DFF`, violet `#A47BFF`, silver `#C9D2E0`, sky `#7FD4FF`, orchid `#D873F5`, slate `#8B95A7`. An app's colour = palette[its index in `orderedTokens` mod 8]. Add them to the asset catalogue as named colours.
- Touch targets 44 pt minimum.

## Home (Apps tab)

1. "Today" and the date.
2. One card: the day's total as the hero figure ("2h 46m"), "of 3h", one bar (scale 0 to 4/3 of the overall target, marker at the target), one status line ("Getting close · 14m left").
3. One card of app rows, 64 pt each: icon, name, time on the right, thin bar underneath (scale 0 to 1.5 × that app's target, marker at its target). An app with no target has a slate bar and no marker. The whole row opens App detail.
4. Tab bar: Apps, Stats, Target.

Nothing else on this screen. The per-app on/off switch lives on App detail; the master switch lives on the Target tab.

## App detail

1. Back, app icon and name, on/off switch.
2. One card: today's time as the hero figure ("58m"), "of 1h today", bar with target marker, one status line.
3. Period switch: Today, 7 days, Month.
4. One card for the chosen period: total as days, hours, minutes, seconds on one line ("0d 6h 13m 40s"), then one bar per day in zone colours with a dashed target line, today outlined, day initials beneath.
5. Two stats: daily average, days within target.
6. One button: "Target 1h a day · Change" (sheet with a stepper in 15-minute steps and "Remove target").

## All apps (Stats tab)

1. "All apps" and the date; period switch (Today, 7 days, Month).
2. Donut: one segment per platform sized by time. Centre: total time and "of 3h". No labels on the ring.
3. One card of rows, 50 pt each: colour dot matching the segment, name, time. A row opens App detail.
4. Tab bar.

## What draws what (Screen Time sandbox)

Usage figures can only be drawn by the `UsageReport` extension. Navigation, switches and targets belong to the main app.

| Element | Drawn by |
| --- | --- |
| Home card (total, bar, status) | `UsageReport`, context `homeTotal` |
| Home row: icon, name, tap | Main app (`Label(token)` inside a `NavigationLink`) |
| Home row: time and bar | `UsageReport`, context `appRow`, one small embedded report per row, single-token filter, `.allowsHitTesting(false)` so the host row receives the tap |
| App detail: back, title, switch, period switch, target button | Main app |
| App detail: today card, period card, two stats | `UsageReport`, context `appDetail` |
| All apps: title, period switch | Main app |
| All apps: donut and centre total | `UsageReport`, context `allApps` |
| All apps row: colour dot, name, tap | Main app |
| All apps row: time | `UsageReport`, context `appTime`, one per row, hit testing off |

One embedded report per row keeps taps in the main app. It is unproven on a device. Fallback if several embedded reports perform badly: one report drawing all rows at a fixed height, with the host overlaying transparent tap areas in the same order.
