# Screenshot catalogue

Every capture on the `ci-logs` branch under `screenshots/`, produced by
the self-checking workflow (`.github/workflows/screens.yml`): each entry
in `NOTE.txt` carries the marker read back from the app container plus a
checksum; duplicates fail the job. Demo mode fills the screens with the
sample figures from `design/reference/`.

## Capture tiers (25 November, B4)

- `[screens]` in the commit message → the **core set** (15 captures)
  the visual review checks first.
- `[screens-all]` (or a manual workflow dispatch) → the **full
  manifest** below.
- `build.yml` skips on `[screens]` pushes: the screenshot job is the
  only build, so no run is wasted.

## Core set (`[screens]`)

| File | Shows | Evidences |
| --- | --- | --- |
| `home-{light,dark}.png` | Today card (2h 46m of 3h, amber) + five app rows | R4, R5, R7, V1, V9 |
| `summary-weekly-{light,dark}.png` | Ranked donut, centre total, share cards | R16, R17 |
| `detail-week-{light,dark}.png` | Today card, week bars from one baseline, stats, target button | R4, R15, V3, V5 |
| `summary-weekly-focus1-dark.png` | Focus on the top app (segment, centre, dimming) | R17 |
| `summary-daily-dark.png` | Daily period + day pills, today selected | R16 |
| `summary-day0-dark.png` | Daily with the Monday pill selected — its own figures (X1) | R16, W1 |
| `summary-weekly-bottom-dark.png` | Scrolled to the end — the last card clears the tab bar (X9) | R16 |
| `home-over-dark.png` | 3h 20m of 3h — red zone | R7 |
| `home-paused-dark.png` | "Paused" in place of the hero | master switch (R3) |
| `detail-focus4-dark.png` | Detail with day 4 focused (linked total) | R17 |
| `detail-month-dark.png` | 30-day month chart, labels on 1/8/15/22/29 | R4, F3 |
| `target-dark.png` | Daily/weekly selector, presets, master/alerts/recaps switches | R3, R6, V6, V7 |
| `onboarding-card{1,4}-dark.png` | First and last onboarding cards | R1, R11, V8 |

## Full manifest extras (`[screens-all]` only)

| File | Shows | Evidences |
| --- | --- | --- |
| `summary-weekly-focus1-{light}.png` | focus in light appearance | R17 |
| `summary-monthly-{light,dark}.png` | Month period on Summary | R16 |
| `detail-{light,dark}.png` (no period flag) | detail marker without suffix | routing |
| `target-light.png` | Target in light | V2, V6 |
| `onboarding-card{2,3}-dark.png` / all cards in light | the remaining cards | R11 |
| `home-comfortable-dark.png` | 1h 05m of 3h — green zone | R7 |
| `home-noapps-dark.png` | Empty state with "Choose apps" | I3 |
| `home-notarget-dark.png` | Bars without markers + "Set a target" | I5 |
| `home-noaccess-dark.png` | Access banner over Home | R12, I2 |
| `detail-today-dark.png` | Detail period = Today | R4 |
| `detail-sheet-dark.png` | Per-app target sheet | R14 |
| `settings-{light,dark}.png` | Settings: amber slider, week start, access + monitoring rows | F6, H3 |
| `home-a11y-dark.png`, `detail-a11y-dark.png` | Home/detail at accessibility-extra-large text | J1 |

If the large-text files are absent, `NOTE.txt` records that the
simulator's `content_size` option was unavailable (skipped, not failed).

## Status

No captures of the current code existed at the 25 November audit; the
`[screens]` run of that day (if it completed) is the evidence holder.
`allapps-*` files from older runs described removed code and are gone.
