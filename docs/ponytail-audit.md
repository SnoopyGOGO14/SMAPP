# Ponytail audit — would the app run on a phone without this?

Part 1.3. Every file in the app targets, ranked. **Keep** = the first
on-phone run breaks without it (or the screenshot self-check / Diagnostics
depends on it). **Park** = not needed for a first run; moved to
`parked/` and excluded from `project.yml` (Part 1.4).

| Rank | File | Verdict |
| --- | --- | --- |
| 1 | `App/AppState.swift`, `Shared/SharedSettings*.swift`, `App/SocialTimeMonitorApp.swift`, `App/RootTabs.swift` | Keep — the spine |
| 2 | `App/Onboarding/OnboardingFlow.swift`, `App/Filters.swift`, `App/Monitoring/*` | Keep — the first-run path (authorise, pick, monitor) |
| 3 | `App/Home/*`, `App/Detail/*`, `App/Summary/{SummaryScreen,DayPillsRow}.swift`, `App/Target/*` | Keep — the four screens the first run uses |
| 4 | `UsageReport/{UsageReportExtension,HomeTotalScene,AppRowScenes,AppDetailScene,SummaryScenes,Aggregator}.swift`, `SharedUI/{HeroCardView,AppRowViews,PeriodCardView,AppDetailCardView,SummaryView,RankedDonutView,SummarySkin,SummaryConfiguration,PeriodTabsControl,BarView,ButtonStyles,Configurations}.swift`, `Shared/ReportContexts.swift` | Keep — every figure the app shows is drawn here |
| 5 | `App/Diagnostics/*`, `SharedUI/DiagnosticsViews.swift`, `UsageReport/DiagnosticsScene.swift`, `Core/DiagnosticsLogic.swift` | Keep — the 30-minute Gate A session is the point of this push |
| 6 | `Shared/FeatureSwitches.swift` (alerts kill switch only), `UsageMonitor`'s guard | Keep — thresholds-under-test control |
| 7 | `App/Demo/*` core (screens, figures, marker) | Keep — the capture self-check depends on demo mode |
| 8 | `App/Summary/SummaryFocusLegend.swift` | **Park** — host-driven focus fallback: only needed if taps never arrive in the report; that is a Gate A *result*, not a first run |
| 9 | `SharedUI/AppRowsView.swift`, `UsageReport/AppRowsScene.swift`, `App/Home/HomeScreenRows.swift` (its `singleRows`) | **Park** — single-report rows fallback, same reason |
| 10 | `UsageReport/FallbackHomeTotalScene.swift` + the 32 encoded registrations + the 8 `summary.fN` scenes | **Park** — App Group read-back fallback; the Diagnostics screen will tell us, and the code returns from `parked/` in one move |
| 11 | `Core/ContextCodec.swift` + tests | **Park** — the codec exists to serve 8 and 10 |
| 12 | Recaps (`NotificationManager`'s scheduling, the Target toggle, the `recapsEnabled` key's UI) | **Park** — off by default, never seen, not on the first-run path |
| 13 | Yearly (`SummaryPeriod.yearly`, `SummaryDefaults.showYearly`, the Summary/period-tab branches) | **Park** — hidden today; its code is pure surface area |
| 14 | `-mode` demo fallbacks (`DemoArguments.mode`, `DemoMode.applyModeSwitches`, the preflight flag) | **Park** — they demo parked features |
| 15 | The footer strip switch (`SummaryDefaults.showFooterStrip` + the view) | **Park** — off by default, one line when wanted |
| 16 | Extra demo states beyond the capture manifest's needs (`comfortable`) | Keep — 15 lines, the capture manifest uses it; cutting costs more churn than it saves |

Ladder rung for every change in Part 1.4: **rung 1 — does it need to
exist? No: delete.** (Deletion beats addition; the parked files return
as whole files, not diffs, if Gate A ever needs them.)
