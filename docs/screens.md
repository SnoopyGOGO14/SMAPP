# Screenshot catalogue

Every capture on the `ci-logs` branch under `screenshots/`, produced by
the self-checking workflow (`.github/workflows/screens.yml`): each entry
in `NOTE.txt` carries the marker read back from the app container plus a
checksum; duplicates fail the job. Demo mode fills the screens with the
sample figures from `design/reference/`.

## Base screens (light and dark)

| File | Shows | Evidences |
| --- | --- | --- |
| `home-{light,dark}.png` | Today card (2h 46m of 3h, amber) + five app rows | R4, R5, R7, V1, V9 |
| `allapps-{light,dark}.png` | Donut with centre total + platform rows | R5, R16, V10 |
| `detail-{light,dark}.png` | Today card, week bars from one baseline, two stats, target button | R4, R15, V3, V5 |
| `target-{light,dark}.png` | Daily/weekly selector, presets, master/alerts/recaps switches | R3, R6, V6, V7 |
| `onboarding-card{1-4}-{light,dark}.png` | The four onboarding cards incl. the preset grid | R1, R11, V8 |

## States (Part 2, dark)

| File | Shows | Evidences |
| --- | --- | --- |
| `home-over-dark.png` | 3h 20m of 3h — red zone | R7 |
| `home-comfortable-dark.png` | 1h 05m of 3h — green zone | R7 |
| `home-paused-dark.png` | "Paused" in place of the hero | master switch (R3) |
| `home-noapps-dark.png` | Empty state with "Choose apps" | I3 |
| `home-notarget-dark.png` | Bars without markers + "Set a target" | I5 |
| `home-noaccess-dark.png` | Access banner over Home | R12, I2 |
| `detail-today-dark.png` | Detail period = Today | R4 |
| `detail-month-dark.png` | 30-day month chart, labels on 1/8/15/22/29 | R4, F3 |
| `detail-sheet-dark.png` | Per-app target sheet | R14 |
| `allapps-week-dark.png` | Donut over a 7-day period | R4, R16 |
| `allapps-month-dark.png` | Donut over a month | R4, R16 |
| `settings-{light,dark}.png` | Settings: amber slider, week start, access + monitoring rows | F6, H3 |

## Accessibility

| File | Shows | Evidences |
| --- | --- | --- |
| `home-a11y-dark.png` | Home at the accessibility-extra-large content size | J1 |
| `detail-a11y-dark.png` | Detail at the same size | J1 |

If the large-text files are absent, `NOTE.txt` records that the
simulator's `content_size` option was unavailable (skipped, not failed).
