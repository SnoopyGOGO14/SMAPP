# Plan — Summary page (draft) and app-wide motion

18 November 2026. Status: **draft for the product owner to confirm**, written so GLM can build it. Start after `07-NEXT-TASKS.md` is finished. Same run rules, guard rails and honesty levels as `05-RUN-TO-REVIEW.md`. Budget: 6 build runs, 3 screenshot runs.

## 1. What this is

The product owner has designed an overall summary page. It becomes the **Stats tab**, renamed **Summary**, and replaces the current All apps screen. Its tap-to-focus animation becomes the motion language for every screen.

## 2. Reference material (already in the project)

| File | What it is |
| --- | --- |
| `SKINS/social_monitoring_usage_Dark/code.html` + `screen.png` | Dark skin: the page as designed |
| `SKINS/social_monitoring_usage_lightskin/code.html` + `screen.png` | Light skin of the same page |
| `SKINS/social_monitoring_usage_-2 dark/` | Byte-identical copy of the dark skin; ignore |

Commit `SKINS/` as it stands. Read both `code.html` files in full before building: sizes, spacing, colours and the interaction script are the specification. They are web mock-ups; build in SwiftUI.

## 3. The page, top to bottom

1. **Period tabs**: text tabs with a hairline under the row. The active tab is bold with a short underline bar beneath it; the bar's filled part shows how much of that period has elapsed (Thursday midday ≈ 50% of the week).
2. **Day pills**: Mon to Sun in one row. Today is the inverted pill. Tapping a pill shows that single day and moves the period to Daily.
3. **Donut**: continuous ring, no gaps, ring thickness 12% of the diameter, segments start at 12 o'clock and run clockwise in order of time, largest first. Centre: small caps label ("WEEKLY USAGE"), the total ("99.5 hrs"), and the top app in its segment colour ("TIKTOK 37 HRS").
4. **App cards**: one per app, largest first: colour dot, name, share in small monospaced digits ("37.2%"), time in bold ("37 hrs"), and beneath them a hairline bar filled to the app's share in its colour.
5. The existing tab bar stays. The mock's footer strip ("Social Monitoring Stats") is left out.

## 4. What carries over exactly, and what must change

| In the mock | In the app | Why |
| --- | --- | --- |
| Layout, spacing, type hierarchy, hairline borders | As designed | |
| Tap a segment or card → focus effect | As designed (section 6) | |
| Dark and light skins | Dark and light appearance | One set of colour assets with two values |
| Each named app has a fixed colour (TikTok red…) | Colour by rank: the largest app takes colour 1, the next colour 2, and so on | iOS hands the app anonymous tokens; the code never knows which app is which |
| Hard-coded figures | Real figures from Screen Time, drawn by the `UsageReport` extension | Sandbox rule |
| Daily, Weekly, Monthly, **Yearly** | Daily, Weekly, Monthly. Yearly is built but hidden behind a flag | iOS keeps a limited history and the app cannot store its own outside the EU. The depth is measured at Gate A; Yearly is switched on only if a year of data exists |
| "hrs" figures | Decimal hours on this page (rule in section 8) | Matches the mock; other screens keep "2h 46m" |
| Web fonts (Space Grotesk; Plus Jakarta Sans, Outfit) | System font with the same weights and tight tracking | `ASSUMED`. Alternative: bundle Space Grotesk (open licence) for figures |
| Red, yellow and green used as app colours | Kept on this page | `ASSUMED`. Zone colours (green, orange, red) appear only on target bars and status words, which this page does not show. Alternative: swap those three for non-zone hues |

## 5. Skin tokens (asset colours, two appearances each)

Apply these to the whole app so every screen shares one look. Existing asset names keep their roles; change their values.

| Role | Dark | Light |
| --- | --- | --- |
| Ground | `#0A0A0C` | `#F8F7F4` |
| Card | `#111114` | `#FFFFFF` |
| Hairline / Divider | `#222226` | `#EAE8E1` |
| BarTrack | `#1C1C21` | `#EDEBE6` |
| PrimaryText | `#F4F4F5` | `#191B1D` |
| SecondaryText | `#A1A1AA` | `#686B73` |
| MutedText (new) | `#71717A` | `#686B73` |
| Focus (new, the gold) | `#FFD700` | `#D97706` |
| Rank colours 1 to 6 | `#FF2D20`, `#0D9488`, `#2563EB`, `#FACC15`, `#7C3AED`, `#EC4899` | `#0284C7`, `#059669`, `#4F46E5`, `#E11D48`, `#7C3AED`, `#DB2777` |
| Rank colours 7 and 8 | `#38BDF8`, `#A1A1AA` | `#0891B2`, `#686B73` |

Cards: 8 pt radius with a 1 pt hairline border in dark; 12 pt radius with a soft shadow in light. Zone colours stay semantic system colours.

## 6. The focus effect (the animation to reuse everywhere)

One reusable behaviour, `FocusGroup`: a set of sibling items where at most one is focused.

| State | Focused item | Siblings | Linked text |
| --- | --- | --- | --- |
| None | Normal | Normal | Default figures |
| One focused | Emphasised: thicker or 3% larger, `Focus` outline, soft `Focus` glow | Fade to 22% opacity | Swaps to the focused item's name (in `Focus` colour) and value |

- Tap an item to focus it; tap it again, or tap empty space, to clear.
- Timing: 0.3 s ease-in-out for opacity, size and outline. Text swaps with a cross-fade; numbers use the numeric content transition.
- A light haptic on focus.
- With Reduce Motion on: no size change and no glow; opacity and outline change in a 0.15 s fade.
- On first appearance: the ring draws clockwise from 12 o'clock in 0.6 s; bars grow from their baseline in 0.4 s, staggered 30 ms each; figures fade up. Once per screen visit.
- Changing period: segments and bars animate to their new sizes; figures cross-fade. No full redraw.

**Where it applies**

| Screen | Focus group | Linked text |
| --- | --- | --- |
| Summary | Donut segments and app cards (one shared selection) | Donut centre: label → app name, total → app's time, third line → app's share |
| App detail | Daily bars | The period line swaps from the total to that day ("Thu · 1h 01m") |
| Home | App rows: `Focus` border while pressed, then navigate. Bars grow on appear | None |
| Target, onboarding | Preset tiles: selected tile fills with a 0.3 s transition | None |

## 7. What draws what

| Element | Drawn by | Notes |
| --- | --- | --- |
| Period tabs, underline, day pills | Main app | They change the filter; "elapsed" is clock arithmetic, no usage data needed |
| Donut, centre text, app cards, focus state | `UsageReport`, new context `summary`, **one** report view | The focus selection is local view state inside the extension, so the donut and cards animate together |
| Tab bar | Main app | |

- The host gives the report a fixed height: donut block + 72 pt per enabled app, inside the host's scroll view. The report itself does not scroll.
- Rows on this page focus; they do not navigate. App detail is reached from Home.
- Rendering views live in `SharedUI` (`SummaryView`, `FocusGroup`, `RankedDonutView`, `AppShareCard`) and take a plain `SummaryConfiguration`, so demo mode and the extension use the same code.
- **Unproven on a device:** taps and animated state inside an embedded report view. Add to Gate A. Fallback if taps do not arrive: the page stays correct without focus, and focus is offered in demo builds only until a host-driven alternative is designed.

## 8. Logic for `Core` (tested on this Mac)

| File | Contents | Tests (minimum) |
| --- | --- | --- |
| `Ranking.swift` | Sort apps by seconds, largest first; ties keep `orderedTokens` order; assign rank colour index (wrap at 8); share of total to one decimal | 6 apps; a tie; a zero-time app drops out; shares sum to 100.0 ± 0.1 |
| `HoursFormat.swift` | Under 6 minutes → "4 min"; under 10 hours → one decimal ("5.3 hrs"); 10 hours and over → whole ("37 hrs"); totals always one decimal ("99.5 hrs") | 0; 5 min; 30 min → "0.5 hrs"; 5 h 18 m → "5.3 hrs"; 37 h; total 99.5 h |
| `PeriodProgress.swift` | Fraction of the day, week (from `weekStartsOn`) or month elapsed at a given moment | Midday → 0.5; Thursday midday, Monday start → 0.5; first and last instant |
| `SummaryPeriod.swift` | `daily(day)`, `weekly`, `monthly`, `yearly`; date interval for each; which day pill is today; which pills lie in the future (disabled) | Each interval; a pill tap; a week crossing a month end |
| `FocusState.swift` | Pure reducer: tap item, tap same item, tap outside, period change (keeps focus if that app is still present, else clears) | Each transition |
| `DonutMath.swift` | Extend: continuous segments (no inset), a minimum visible sweep of 1.5° for tiny shares | A 0.5% share still gets a visible sweep; total stays 360° |

## 9. Demo data and captures

- [ ] `DemoData.summary(period:)` with six demo apps so the page shows six cards. Keep today's five figures as they are for Home and add a sixth at 9 m only on Summary's weekly and monthly sets; daily totals must still equal Home's 2h 46m for the shared five.
- [ ] Launch arguments: `-screen summary`, `-period daily|weekly|monthly`, `-focus <rank>` (opens with that rank focused).
- [ ] Captures, light and dark: summary weekly; summary weekly with `-focus 1`; summary daily; summary monthly; detail with `-focus 4` (a day bar focused). Markers include period and focus.
- [ ] Compare against `SKINS/*/screen.png`: ring thickness, card height, hairline bars, typography weights, gold focus.

## 10. Build order

| # | Task | Done when |
| --- | --- | --- |
| P1 | Commit `SKINS/` and this plan. Update `DESIGN-NOTES.md`: Summary replaces All apps; add sections 3, 5 and 6 of this plan; mark the page "draft" | Notes and plan agree |
| P2 | Spec: R16 becomes "Summary page"; add R17 "Focus effect and motion on every screen"; data model gains `summaryPeriod` and `summaryDay`; report contexts replace `allApps` and `appTime` with `summary` | Spec, session file and checklists updated |
| P3 | `Core` additions from section 8 with tests | `swift test` passes locally |
| P4 | Skin tokens from section 5 across the asset catalogue; card style helper for the two appearances | Build succeeds |
| P5 | `SharedUI`: `FocusGroup`, `RankedDonutView`, `AppShareCard`, `SummaryView`, appear and period-change animations, Reduce Motion path | Build succeeds; demo renders |
| P6 | `UsageReport`: `SummaryScene` building `SummaryConfiguration` through `Aggregator` and `Core.Ranking` | Build succeeds |
| P7 | Main app: `SummaryScreen` with period tabs, elapsed underline, day pills (future days disabled), filter per period, fixed report height; Stats tab renamed Summary; remove `AllAppsScreen` and its scenes | Build succeeds; no dead code left |
| P8 | Motion on the other screens per section 6: App detail bar focus with linked text, Home row press state and bar growth, preset tile transitions | Build succeeds |
| P9 | Demo arguments and captures from section 9; push with `[screens]`; fix until markers match | `NOTE.txt` clean |
| P10 | Accessibility: each segment and card reads "TikTok, 37 hours, 37 percent"; focus is reachable by VoiceOver activate; tabs and pills have selected traits | Labels in place |
| P11 | `docs/device-checks.md`: add taps and animation inside the embedded report, history depth for Monthly and Yearly, focus with real data | Added |
| P12 | `REVIEW.md` and `PROGRESS.md` updated with levels, `ASSUMED` rows and anything skipped. Commit, push, stop | Done |

## 11. Decisions taken as defaults (`ASSUMED`; the product owner may change any)

| Decision | Default | Alternative |
| --- | --- | --- |
| Where the page lives | Replaces All apps as the Stats tab, renamed Summary | A fourth tab |
| Yearly tab | Hidden until a device shows a year of history | Show it greyed out with "Not enough history yet" |
| App colours | By rank, largest first | By the user's row order, so an app keeps its colour as usage changes |
| Underline bar on the active tab | Share of the period elapsed | Share of the target used (needs usage data, so it would move inside the report) |
| Day pills | Tap = that day, Daily view | Pills visible on Daily only |
| Fonts | System font | Bundle Space Grotesk |
| Red, yellow, green as app colours | Kept, on Summary only | Replace with non-zone hues |
| Skin tokens | Applied to every screen | Summary only |
| Footer strip from the mock | Left out | Shown above the tab bar |
| App name | Social Time Monitor | Social Monitoring Stats (the mock's title) |

## 12. Risks

- Taps and animation inside the report extension are unproven until Gate A.
- Monthly depends on how much history iOS returns; Yearly very likely exceeds it.
- Colour by rank means an app's colour changes when its ranking changes between periods.
- Six cards plus the donut exceed one screen on smaller iPhones; the page scrolls.
