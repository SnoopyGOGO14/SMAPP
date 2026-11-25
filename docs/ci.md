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
| 26 | `c9ad31b` | build | pending | A1 attempt 2: all fixes + B3–B7 work; 104 Core tests |

## Historical (before the outage)

Last green build before the outage: run 19, `337203d`, 18 Nov 11:13.
Run 21: the `2a88ffe` TargetScreen `buildExpression` failure. Runs 17–19
details in `PROGRESS.md` (18 November section).
