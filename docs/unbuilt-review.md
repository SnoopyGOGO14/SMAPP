# Unbuilt-code review (B2) — the 50 files changed since `337203d`

Method: each file read against `docs/failure-classes.md`, its call
signatures checked against Core's tested public API, and the type-check
evidence from cloud run 24 (which reported exactly one error —
`HomeScreen.swift:29` — meaning every other file below type-checked
clean on Xcode 26.6 before the fixes landed).

Status legend: **r24-clean** = type-checked clean in cloud run 24;
**fixed-r25** = had a defect, fixed for run 25 (A1); **tested** = Core
package, covered by the 90 passing tests; **deleted** = removed.

## Core package (15 files — tested, logic proven locally and in the cloud)

| File | Status | Notes |
| --- | --- | --- |
| Packages/Core/Sources/Core/AppCalendar.swift | tested | 4 tests incl. DST and Sydney |
| Packages/Core/Sources/Core/ChartGeometry.swift | tested | baseline geometry (V3) |
| Packages/Core/Sources/Core/DonutMath.swift | tested | −90° = 12 o'clock convention verified against the view |
| Packages/Core/Sources/Core/FocusState.swift | tested | toggle semantics |
| Packages/Core/Sources/Core/HoursFormat.swift | tested | hours/total strings |
| Packages/Core/Sources/Core/PeriodProgress.swift | tested | elapsed fractions, UK calendar |
| Packages/Core/Sources/Core/Ranking.swift | tested | rank + share; no tuple Equatable |
| Packages/Core/Sources/Core/SettingsKeys.swift | tested | key strings only |
| Packages/Core/Sources/Core/StatusLine.swift | tested | zone wording source |
| Packages/Core/Sources/Core/StatusParts.swift | tested | V4 fix |
| Packages/Core/Sources/Core/SummaryPeriod.swift | tested | pills, intervals, raw values |
| Packages/Core/Sources/Core/SummaryText.swift | tested (B3) | centre lines, focus on/off — wired into RankedDonutView |
| Packages/Core/Sources/Core/DemoArguments.swift | tested (B3) | launch-arg parsing; DemoMode delegates, invalid args surface in the marker |
| Packages/Core/Tests/CoreTests/AppCalendarTests.swift | tested | — |
| Packages/Core/Tests/CoreTests/ChartGeometryStatusPartsTests.swift | tested | — |
| Packages/Core/Tests/CoreTests/CoreTests.swift | tested | — |
| Packages/Core/Tests/CoreTests/SummaryLogicTests.swift | tested | — |
| Packages/Core/Tests/CoreTests/SummaryTextAndArgsTests.swift | tested (B3) | centre lines, arg parsing, UK interval edges across both clock changes |

## App target (17 files)

| File | Status | Issues found → fixes |
| --- | --- | --- |
| App/AccessBanner.swift | r24-clean | `.primaryAction` replaces borderedProminent (V2) |
| App/Demo/DemoData.swift | fixed-r25 | `-period weekly/daily/monthly` had no DemoPeriod cases → 6 Summary captures would MISMATCH; cases added with `dataSet` mapping |
| App/Demo/DemoDetailScreen.swift | r24-clean | new demo detail; toolbar switch, sheet, focus |
| App/Demo/DemoMode.swift | fixed-r25 | same DemoPeriod gap (with DemoData) |
| App/Detail/AppDetailScreen.swift | r24-clean | V5 toolbar switch; debug/demo title split |
| App/Detail/AppTargetSheet.swift | r24-clean | `.preset`/`.primaryAction` styles |
| App/Filters.swift | r24-clean | summary filter added; allApps/appTime removed |
| App/Home/AppUsageRow.swift | r24-clean | single .bar style; HomeRowStyle pressed focus border |
| App/Home/HomeScreen.swift | **fixed-r25** | **run 24's only error**: deferred `let` assignment in ViewBuilder (class 8) → `showsSetTargetButton` computed property |
| App/Monitoring/MonitoringScheduler.swift | fixed-r25 | `try?` on non-throwing `center.activities` (run-24 warning) |
| App/Onboarding/OnboardingFlow.swift | r24-clean | V8 layout, preset grid, pickerBinding pattern unchanged from last green build |
| App/RootTabs.swift | r24-clean | Summary replaces All apps; no global tint |
| App/SocialTimeMonitorApp.swift | r24-clean | demo routing incl. settings/detail |
| App/Stats/AllAppsScreen.swift | deleted | replaced by SummaryScreen |
| App/Summary/SummaryScreen.swift | r24-clean | tabs, pills, report; Core signatures all verified |
| App/Target/SettingsScreen.swift | r24-clean | familyActivityPicker, appTargets list |
| App/Target/TargetScreen.swift | r24-clean | the old failure site (deferred `let`) was rewritten away; presets/stepper clean |

## Shared (2 files)

| File | Status | Notes |
| --- | --- | --- |
| Shared/ReportContexts.swift | r24-clean | `.summary` context added |
| Shared/SharedSettings.swift | r24-clean | summaryPeriod/summaryDay added |

## SharedUI (13 files)

| File | Status | Issues found → fixes |
| --- | --- | --- |
| SharedUI/AppDetailCardView.swift | r24-clean | gains initialFocus (default nil) |
| SharedUI/AppRowViews.swift | r24-clean | AppTimeView deleted |
| SharedUI/BarView.swift | r24-clean | grow-on-appear; UIKit imported |
| SharedUI/ButtonStyles.swift | r24-clean | new: primaryAction + preset styles |
| SharedUI/Configurations.swift | r24-clean | AppTime/AllApps configurations deleted |
| SharedUI/DonutView.swift | deleted | replaced by RankedDonutView |
| SharedUI/HeroCardView.swift | r24-clean | statusParts (V4) |
| SharedUI/PeriodCardView.swift | r24-clean | linked total, focus, UIKit |
| SharedUI/RankedDonutView.swift | fixed-r25 | unused `total` and `rank` binding (run-24 warnings); rotation math verified correct (−90+90, trim, −90 = 12 o'clock) |
| SharedUI/RingMarkView.swift | r24-clean | code-drawn ring mark (V8) |
| SharedUI/SummaryConfiguration.swift | r24-clean | token + demoName item |
| SharedUI/SummarySkin.swift | r24-clean | rank colours, card modifier, focusItem |
| SharedUI/SummaryView.swift | fixed-r25 | `import UIKit` added for UIImpactFeedbackGenerator (r24 resolved it transitively; explicit is correct) |

## UsageReport (4 files)

| File | Status | Notes |
| --- | --- | --- |
| UsageReport/AllAppsScene.swift | deleted | replaced by SummaryScene |
| UsageReport/AppRowScenes.swift | r24-clean | AppTimeScene deleted; ManagedSettings import |
| UsageReport/SummaryScene.swift | r24-clean | new scene; shape mirrors built-green HomeTotalScene; Ranking/SummaryItem signatures verified |
| UsageReport/UsageReportExtension.swift | r24-clean | SummaryScene registered |

## Summary

Defects found by this review: **5** (HomeScreen deferred-let — the run 24
failure; DemoPeriod marker drift; three warnings; one missing import).
All fixed, then two more surfaced by the build runs and fixed:
`homeCard` without `@ViewBuilder` (run 26, if-expression rule) and the
non-exhaustive `dataSet` switches (run 27, narrow-enum fix). Final
verdict: **run 28 BUILD SUCCEEDED** and screens run 26 captured the
core 15 — the level for every file above is now **compiles** (and
**captured** for the screens in the manifest).
