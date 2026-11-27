# Later — everything parked or deferred, one line each

The working-app push cut to the minimum; each item returns when its
trigger fires. 27 November 2026.

| Item | Where it waits | Trigger |
| --- | --- | --- |
| Host-driven Summary focus (`summary.f0…f7`) + legend | `parked/App/SummaryFocusLegend.swift`, the scene block in `parked/UsageReport/` | Gate A: taps never arrive inside the report |
| Single-report Home rows fallback | `parked/SharedUI/AppRowsView.swift`, `parked/UsageReport/AppRowsScene.swift`, the `singleRows` in `parked/App/HomeScreenRows.swift` | Gate A: per-row reports slow or blank |
| Context-name codec (App Group fallback) | `parked/Core/ContextCodec.swift` + tests, `parked/UsageReport/FallbackHomeTotalScene.swift` | Gate A: the report cannot read the App Group |
| `-mode` demo demonstrations | removed with the fallbacks | the fallbacks returning |
| Recap notifications (evening/Sunday) | removed (the wording survives in git history) | the owner answers DECISIONS row 6 "on" |
| Yearly tab | `SummaryPeriod.yearly` lives in git history | a device shows a year of history |
| Footer strip | `SummaryDefaults.showFooterStrip` in git history | DECISIONS row 11 "shown" |
| `DEVICE_UDID`-driven automatic device registration | never written (manual portal step instead) | more than one device to provision |
| Web domains (v1.1 opt-in) | research verdict + change list in `docs/monitoring-analysis.md` §4 | the owner answers DECISIONS row 5 |
| Per-app alerts | — | DECISIONS row 12 |
| Space Grotesk font, app icon, name | DECISIONS rows 1–2 + the asset work | the owner's answers |
| App Store submission | `docs/release.md` (16 steps) | a green device build |
| `[screens-all]` full-manifest capture run | screens.yml's full tier | the cloud returning + a green build |
