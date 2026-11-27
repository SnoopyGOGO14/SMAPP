# Unbuilt-code review — the 31 files changed since `d165792`

Part 5.5 of `12-NEXT-WITHOUT-CLOUD.md`: the last green cloud build was
`d165792` (run 39, 26 November). Everything after it — the Z and S
rounds, then Parts 1–5 of the no-cloud list — is **locally verified
only** (parse, preflight's structural checks, 143 Core tests) until a
cloud build returns. Method: each file read against
`docs/failure-classes.md`; the pure logic is test-covered.

Notable self-caught items along the way:

- The codec zero-padding mismatch (`t15` vs `t015`) — caught by the
  new edge tests before any build; fixed to the padded form the
  extension's 32 registrations use.
- The Diagnostics split initially left duplicate member declarations
  and a mangled quote (parse check caught both; fixed).

| File | Checked | Status |
| --- | --- | --- |
| App/BuildInfo.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Demo/DemoMode.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Diagnostics/DiagnosticsScreen.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Diagnostics/DiagnosticsSupport.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Filters.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Home/HomeScreen.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Home/HomeScreenRows.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/SocialTimeMonitorApp.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Summary/SummaryFocusLegend.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Summary/SummaryScreen.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Target/PerAppTargetsCard.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| App/Target/SettingsScreen.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Packages/Core/Sources/Core/ContextCodec.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Packages/Core/Sources/Core/DemoArguments.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Packages/Core/Sources/Core/DiagnosticsLogic.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Packages/Core/Sources/Core/SettingsKeys.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Packages/Core/Tests/CoreTests/ContextCodecTests.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Packages/Core/Tests/CoreTests/DiagnosticsLogicTests.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Shared/FeatureSwitches.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Shared/ReportContexts.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| Shared/SharedSettings.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| SharedUI/AppRowsView.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| SharedUI/DiagnosticsViews.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| SharedUI/PeriodTabsControl.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| SharedUI/SummaryConfiguration.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| UsageMonitor/UsageMonitor.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| UsageReport/AppRowsScene.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| UsageReport/DiagnosticsScene.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| UsageReport/FallbackHomeTotalScene.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| UsageReport/SummaryScenes.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |
| UsageReport/UsageReportExtension.swift | read; classes 1–15 hunted | clean (preflight + parse + tests where pure) |

Verdict: **locally verified**. The first plain push when the cloud
returns must confirm green before anything else runs
(`12-NEXT-WITHOUT-CLOUD.md` Part 0.2).
