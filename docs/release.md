# Release checklist — from "build Mac arrives" to "submitted"

Each step tagged **person** (needs the owner's hands/accounts) or
**builder** (GLM can do it from the repo). 27 November 2026.

| # | Step | Who | Where |
| --- | --- | --- | --- |
| 1 | Apple-silicon Mac arrives | person | — |
| 2 | Day one on the Mac: `tools/first-run.sh` — Xcode ≥ 26, XcodeGen, Core tests, simulator build | person (GLM wrote the script) | `tools/first-run.sh` |
| 3 | Join the Apple Developer Program (individual or org) | person | developer.apple.com |
| 4 | Register the bundle IDs + App Group; note the real organisation identifier | person | `docs/portal-steps.md` |
| 5 | Replace `YOURORG` everywhere; regenerate the project | builder | `project.yml`, `Shared/SharedSettings.swift`, the three `.entitlements` |
| 6 | Set the signing team; build + run on the iPhone | person | Xcode |
| 7 | Submit the three Family Controls (Distribution) requests | person | `docs/AppStore/family-controls-request.md` (answers drafted) |
| 8 | Gate A on the device (~30 min) | person | `docs/gate-a-card.md`; paste results into `PROGRESS.md` |
| 9 | Fix any FAILs with the fallback switches | builder | `docs/gate-a-outcomes.md` |
| 10 | Answer `DECISIONS.md` (12 rows) | person | `DECISIONS.md` |
| 11 | Apply the answers (name, icon, fonts, defaults) | builder | the file+line table in `DECISIONS.md` |
| 12 | Real-device screenshots at 1206 × 2622 (+ 1320 × 2868) | person | `docs/AppStore/screenshots.md` |
| 13 | Finalise the listing (name, keywords, pricing, countries) | person | `docs/AppStore/listing.md` |
| 14 | Privacy "nutrition label" in App Store Connect (collects: nothing) | person | `docs/AppStore/privacy-policy.md` |
| 15 | Upload from Xcode 26+; submit for review with the review notes | person | `docs/AppStore/review-notes.md` |
| 16 | Answer any reviewer questions (Family Controls answers drafted) | person + builder | `docs/AppStore/family-controls-request.md` |

Note: uploads from Intel Macs stop being accepted in April 2027, and
from April 2027 apps built with the iOS 27.1 SDK also need iPhone Duo
screenshot sizes (`docs/AppStore/screenshots.md`).
