# Gate A outcomes — what a FAIL means and the one line that fixes it

Part 2 of `12-NEXT-WITHOUT-CLOUD.md`. Work down the Diagnostics screen;
for any FAIL, flip the switch below (all in `Shared/FeatureSwitches.swift`,
settable in a debug build or via `-mode <name>` in demo captures) and
rebuild. No check is a dead end.

| Diagnostics line | If PASS | If FAIL → switch | Switch value | What the fallback does |
| --- | --- | --- | --- | --- |
| Screen Time access | nothing | (not a switch — the banner already guides re-granting) | — | — |
| App Group host echo | nothing | — (host-side failure is a build problem, not a device unknown) | — | — |
| Report's App Group timestamp ≠ host's | nothing | `appGroupContextFallback` | `true` | The host encodes target + amber into the report context name (`homeTotal.t180.a75`, `Core.ContextCodec`); the extension decodes it. 32 contexts registered (15 m–8 h steps at amber 75). |
| Report's "Target read" ≠ 60 min | nothing | `appGroupContextFallback` | `true` | Same channel — the target rides the context name. |
| Home rows slow / blank (stopwatch) | nothing | `homeRowsMode` | `.single` | One `appRows` report draws every row at fixed 64 pt; the host overlays transparent tap areas in the same order. |
| Tap test counter does not rise | nothing | `summaryFocusMode` | `.hostDriven` | The host draws the legend (Label(token) chips, so names/icons are host-side too); focus passes by context name (`summary.f0`…`f7`); the report bakes the focus in. |
| Day segments < 28 (history short) | nothing | `monthlyRequiresHistory` + set `historyDays` | `true`, value from the report | Monthly hides below 28 days; between 28 and 34 it captions "Showing the last N days". |
| `Label(token)` blank in the report | nothing | (covered) `summaryFocusMode` | `.hostDriven` | The legend chips draw names host-side; Home rows already do. |
| Monitoring activities = 0 or error | nothing | fix the error; if thresholds misbehave: `alertsKillSwitch` | `true` | Alerts stop entirely; Settings shows "Alerts paused: under test" while under test. |
| Notifications denied | nothing | (iOS Settings problem — the person re-enables in Settings) | — | — |

## Demo capture modes (2.3)

`-screen <screen> -mode <name>` in a capture launch demonstrates each
fallback: `appGroupFallback`, `singleRows`, `hostFocus`,
`shortHistory`, `alertsOff`. None are in the current capture manifest —
add them when the cloud returns and the owner wants to see them.

## Note

`FeatureSwitches` lives in `Shared/` (not `App/` as the task list
sketched) so the monitor target can see the alerts kill switch; it is
Foundation-free for the monitor's strict sources list.
