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
| 30 (`3f9f517`) | build | **success (2m)** | all W1–W14 fixes compiled first try |
| 31 (`e7d1e0a`) | screens (run 28) | **failure (5m, no captures)** | my own W6 bug: the settle note wrote to `shots/NOTE.txt` before `mkdir -p shots` — under GitHub's default `bash -e` the step died right after the 30 s settle. Also found: the B4 log-publishing copied the logs but never staged them (`git add screenshots STATUS.txt`) — both fixed in `f0fdc58` |
| 32 (`f0fdc58`) | screens (run 29) | **failure (9m) — but all 16 captures landed, every marker matched** | the duplicate check did its job: `summary-day2-dark` was pixel-identical to `summary-daily-dark` — the day pills had no *selected* style, so picking a day changed nothing visible. Real W1 gap; fixed in `22344cb` (the selected pill takes the inverted style) |
| 33 (`22344cb`) | screens (run 30) | **failure (1m)** | my pill fix reintroduced failure class 8 (deferred `let` in a ViewBuilder) — SummaryScreen:155; the first screens run whose logs arrived (the `git add -A` staging works) |
| 34 (`7377c25`) | screens (run 31) | **all 16 captures, markers clean; the only flag a benign duplicate** | day 2 = today (Wednesday), so `-day 2` and the plain daily capture correctly showed the same image; the workflow now uses `-day 0` (collides only on Mondays). Round 4 stands on these captures |
| 35 (`124f776`) | build (run 34) | failure (1m) | failure class 15: the type-checker timed out on the untyped literal chain in `monthBase`; broken into typed sub-expressions |
| 36 (`ec3f623`) | build (run 35) | **success (2m)** | X1–X9 compile; the round-5 capture run follows |
| 37 (`9623dfd`) | screens (run 34) | **success (8m) — 17 captures, markers clean, day0 and end included, no duplicates** | round 5 stands on these captures |
| 38 (`5f6e165`) | build (run 36) | **success (2m)** | Y1 (tile colours) + Y2 (inline title mode) compile |
| 39 (`ce87fe5`) | screens (run 36) | success (13m) — 36 captures, 33 markers clean, **3 MISMATCHes** | all three showed the *previous* capture's screen (`detail-dark`→`summary/monthly`, `settings-*`→`detail/sheet`): the simulator terminate/launch race, not an app bug (the same screens matched with other args in the same run). capture() now retakes once on mismatch + settles the terminate; one more `[screens-all]` follows — **1 screenshot run over budget**, logged |
| 40 (`eed83ce`) | screens (run 37) | **success (14m) — 36 captures; detail-dark fixed (1 RETAKEN, the stale-launch race); settings still mismatched** | root cause found, and it was never a race: **SettingsScreen never called `DemoMarker.mark`** — every settings capture read the previous screen's stale marker file. One-line fix in `ac1781f` |
| 41 (`ac1781f`) | build | pending | Z1–Z4: the plain push before the final `[screens-all]` |
| — | — | — | Y-round budget: 1 of 2 builds, 0 of 1 screens at this point |

## Run numbering note

The two workflows number their runs separately: build runs are 24, 26,
27, 28; screens runs are 25 (the accidental full-manifest failure on
`0003a8d`) and 26 (the A2 success). STATUS.txt lines carry `run:` to
disambiguate.

## Historical (before the outage)

Last green build before the outage: run 19, `337203d`, 18 Nov 11:13.
Run 21: the `2a88ffe` TargetScreen `buildExpression` failure. Runs 17–19
details in `PROGRESS.md` (18 November section).
