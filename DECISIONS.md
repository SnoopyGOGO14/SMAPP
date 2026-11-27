# DECISIONS — one page, every open choice

Written for you, 27 November 2026. Each row: the question, the default
the app ships with today, the alternative, what actually changes on
screen, and which screenshot on `ci-logs/screenshots` shows it. Answer
by replying "row 3: alternative" (or your own words) — every answer is
a one-line change for GLM (the file and line are named).

| # | Question | Default today | Alternative | What changes on screen | Capture |
| --- | --- | --- | --- | --- | --- |
| 1 | What is the app called? | Social Time Monitor | e.g. "Screen Balance" | Home title, tab titles, App Store name (bundle ID unchanged) | `home-light` |
| 2 | Figures in the system font, or the mock's Space Grotesk? | System font | Space Grotesk (needs the font file bundled; falls back safely) | The big donut/hero figures change typeface | `summary-weekly-light` |
| 3 | Show a Yearly tab? | Hidden until a device proves a year of history | Show it (empty or "not enough history") | A fourth period tab appears | `summary-weekly-light` |
| 4 | Where does amber start? | 75% of the target | Any 5% step 50–95% | The hero bar and status line switch colour earlier/later | `home-over-dark` |
| 5 | Count website time (e.g. YouTube in Safari)? | No — apps only in v1 | Opt-in web domains in v1.1, shown as their own rows | Extra rows like "YouTube (web)" appear if enabled | (future feature; research verdict in `docs/monitoring-analysis.md` §5) |
| 6 | Recap notifications on or off by default? | Off until switched on | On | An evening/Sunday notification inviting a look at the day | (setting: `target-dark`) |
| 7 | What does "weekly target" mean? | A calendar week (from your chosen week-start day) | A rolling 7 days | The week's start day and the total's span | `summary-weekly-light` + Settings |
| 8 | Price? | Open (free assumed for v1) | Paid / subscription | Nothing in the app; App Store listing only | — |
| 9 | Launch countries? | Open (UK-first assumed) | UK + EU together, or wider | Nothing in the app; listing availability | — |
| 10 | App colours: by row order or by rank? | **Row order** — one colour per app everywhere (your round-4 reversal) | By rank (largest app gets colour 1; changes with usage) | TikTok stays one colour across screens vs re-colouring per tab | `summary-weekly-focus1-dark` |
| 11 | The mock's footer strip above the tab bar? | Left out | Shown | A small "Social Monitoring Stats" strip at the Summary's bottom | (not in any capture — off) |
| 12 | Per-app alerts (each app gets its own 75%/100%)? | Out of scope for v1 | Later | Alert wording and thresholds per app | — |

## Where each answer lands (file and line)

| # | Switch or constant | Location |
| --- | --- | --- |
| 1 | Display name | `Config/App-Info.plist` → `CFBundleDisplayName` |
| 2 | `useSpaceGrotesk` | `SharedUI/SummarySkin.swift` line 25 |
| 3 | `showYearly` | `SharedUI/SummarySkin.swift` line 17 |
| 4 | `amberFraction` default | `Shared/SharedSettings.swift` line 64 (the stored value; the Settings slider overrides per user) |
| 5 | Web domains | a v1.1 feature: `docs/monitoring-analysis.md` §4 is the whole change |
| 6 | `recapsEnabled` default | `Shared/SharedSettings.swift` (line 76 area) |
| 7 | Week starts on | Settings (per user); the definition is `Core.SummaryPeriod.weekly` |
| 8 | — | App Store listing only |
| 9 | — | App Store listing only |
| 10 | `colourByRank` | `SharedUI/SummarySkin.swift` line 15 |
| 11 | `showFooterStrip` | `SharedUI/SummarySkin.swift` line 19 |
| 12 | per-app alerts | `UsageMonitor` (threshold events per app token — a later build) |
