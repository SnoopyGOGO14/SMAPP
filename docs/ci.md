# CI ledger — runs, minutes, and what they proved

Live state: `git show origin/ci-logs:STATUS.txt` (each line:
`build|screens: <sha> <status> <minutes>m run:<n>`).

## Rules (B4)

- `tools/preflight.sh` before every push.
- Never push while a run is in flight (the concurrency group cancels).
- `[screens]` = 15 core captures; `[screens-all]` = full manifest;
  `build.yml` skips on `[screens]` so only one build runs.
- **Never put the literal `[screens]` or `[screens-all]` in a commit
  message unless you mean it** — the 0003a8d push described the tier
  change in its message and accidentally triggered a full capture run.
- Budget for the 09 run: 10 build runs, 3 screenshot runs.

## The 25 November series

| Run | Commit | Kind | Result | Notes |
| --- | --- | --- | --- | --- |
| 24 | `c3a6e3b` | build | failure (3 min) | the probe — cloud alive again; one error: HomeScreen deferred-let; Core 90/90 in cloud |
| 25 | `0003a8d` | screens (accidental, full manifest) | failure | message contained `[screens]`/`[screens-all]`; build.yml skipped; run failed before/without publishing logs (publish gap now fixed); 1 of 3 screenshot runs burned |
| 26 | `c9ad31b` | build | failure (1m) | one error: `homeCard` — computed property without `@ViewBuilder`, so Swift 5.9's if-expression rule demanded matching branch types. Everything else type-checked clean (Core-test skip + caches in effect). |
| 27 | `e355b82` | build | failure (1m) | three errors: DemoData switches over `period.dataSet` not exhaustive — dataSet returned the *full* 6-case enum; fixed with a narrow `DataSet` enum (failure class 14) |
| 28 | `22895ca` | build | **success (1m)** | A1 green — all three targets, Xcode 26.6; first green build since run 19 (18 Nov). This push slipped out with preflight failing (piped through `tail`, exit status masked — the classic chain hazard); the failure was a script artifact ("3-case enum" comment), regex since hardened |
| 29 (`2997d30`) | screens | **success (9m, screens run 26)** | A2: 15 core captures, all markers matched, all checksums unique |

## Run numbering note

The two workflows number their runs separately: build runs are 24, 26,
27, 28; screens runs are 25 (the accidental full-manifest failure on
`0003a8d`) and 26 (the A2 success). STATUS.txt lines carry `run:` to
disambiguate.

## Historical (before the outage)

Last green build before the outage: run 19, `337203d`, 18 Nov 11:13.
Run 21: the `2a88ffe` TargetScreen `buildExpression` failure. Runs 17–19
details in `PROGRESS.md` (18 November section).
