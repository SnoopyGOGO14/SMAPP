# Social Time Monitor — engineer checklists

Lists to consider and implement. Tick items as they land; add the session number or commit beside each. Detail and reasons are in `01-BUILD-SPEC-v2.md`.

## 1. Apple account and signing (person)

- [ ] Developer Program membership active; team ID noted in `PROGRESS.md`
- [ ] Three bundle IDs registered (app, `UsageReport`, `UsageMonitor`)
- [ ] App Group registered and enabled on all three
- [ ] Family Controls (Development) enabled on all three
- [ ] Family Controls (Distribution) requested for all three, dates recorded
- [ ] "Family Controls App and Website Usage" capability left off
- [ ] Automatic signing works for each target in Debug and Release
- [ ] Two test iPhones: one on iOS 17.4–18.x, one on the newest iOS

## 2. Project configuration

- [ ] Deployment target 17.4 on all targets
- [ ] Both extensions embedded in the app; bundle IDs prefixed by the app's
- [ ] Entitlements file per target with Family Controls and the App Group
- [ ] Extension Info.plist keys match Apple's templates
- [ ] `Core` package linked to all three targets; `ZoneStyle` excluded from `UsageMonitor`
- [ ] Zero third-party dependencies; zero network entitlements
- [ ] Build succeeds from a clean checkout with `xcodegen generate` and one build

## 3. Permissions and access

- [ ] Plain-language card precedes the system Screen Time prompt
- [ ] Declined state: explanation and retry
- [ ] Notification permission requested only when alerts or recaps are first switched on
- [ ] Authorisation re-checked on every return to the foreground
- [ ] Access banner when access is off or selection is empty
- [ ] Re-pick flow after access is re-granted
- [ ] Nothing else requested: no tracking prompt, location, contacts or photos

## 4. App selection and tokens

- [ ] Selection created with `includeEntireCategory: true`, and again after decoding
- [ ] Tokens stored through `SharedSettings` only
- [ ] Ordered list kept so rows hold their position
- [ ] `Label(token)` used for every icon and name; no bundled brand artwork
- [ ] Decision recorded: web domains counted or left out
- [ ] Removed or uninstalled apps drop out of the list cleanly

## 5. Report extension (`UsageReport`)

- [ ] Reads the App Group; never writes to it
- [ ] Filter limited to iPhone and to enabled tokens
- [ ] All totals computed in `makeConfiguration`; views only render
- [ ] One `PeriodChartView` for four periods
- [ ] Allowance for each view taken from `TargetMath`
- [ ] Placeholder, empty and short-history states
- [ ] Redraws after returning from the background
- [ ] Icons and names render inside the extension on both test iOS versions

## 6. Monitor extension (`UsageMonitor`)

- [ ] Imports limited to Foundation, DeviceActivity, UserNotifications
- [ ] Memory checked in Instruments, comfortably under 6 MB
- [ ] Six checkpoint events, each with `includesPastActivity: true`
- [ ] Sanity guard applied before any notification
- [ ] `lastCheckpoint` written; no other key written from here
- [ ] Notifications at 75% and 100% only, worded as approximate
- [ ] Works with the app force-closed and after a phone restart

## 7. Scheduling

- [ ] Daily mode: one repeating midnight-to-midnight activity
- [ ] Weekly mode: one activity spanning the user's week
- [ ] Restart on change of switches, master switch, target, mode; debounced to one restart
- [ ] Monitoring stopped while the master switch is off
- [ ] Behaviour confirmed across midnight, week start and a clock change

## 8. Interface and ease of use

- [ ] Setup completes in under a minute, three steps
- [ ] Target presets 1, 2, 3, 4 hours; custom in 15-minute steps
- [ ] Times as "2h 14m"; "46m left" in green and amber
- [ ] Zone shown as colour, word and symbol together
- [ ] Encouraging wording throughout
- [ ] Haptic on each switch; ring refreshes at once
- [ ] Stats tab remembers the last period
- [ ] Alert tap lands on the Today ring

## 9. Accessibility and appearance

- [ ] Dynamic Type to the largest accessibility size
- [ ] VoiceOver labels on ring, rows, bars
- [ ] Light and dark mode; contrast checked for all three zone colours
- [ ] Reduce Motion respected
- [ ] British English strings in a String Catalog

## 10. Privacy and App Review

- [ ] Privacy manifest in each target with current required-reason codes for UserDefaults
- [ ] Privacy label: no data collected
- [ ] Review notes explain self-monitoring, `.individual` authorisation, on-device data
- [ ] Listing text, icon and screenshots free of third-party brand names and logos
- [ ] Privacy policy page published

## 11. Device test matrix (person, at each gate)

| Scenario | iOS 17.4–18.x phone | Newest iOS phone |
| --- | --- | --- |
| Ring and all four charts agree with Settings › Screen Time | [ ] | [ ] |
| Switch off one app: its time leaves every view | [ ] | [ ] |
| Target change recolours ring and charts | [ ] | [ ] |
| Alerts arrive with app closed | [ ] | [ ] |
| Alerts arrive after phone restart, app still closed | [ ] | [ ] |
| Mid-day switch flip keeps morning usage in the count | [ ] | [ ] |
| First pick-up of the day: alert only after real use | [ ] | [ ] |
| Access switched off in Settings: banner on return | [ ] | [ ] |
| Access re-granted: re-pick flow works | [ ] | [ ] |
| Across midnight and across week start | [ ] | [ ] |
| YouTube in Picture in Picture and with audio in the background: observed counting noted | [ ] | [ ] |
| Days of history returned to the Month view (record the number) | [ ] | [ ] |
| Delete and reinstall | [ ] | [ ] |

## 12. Traps to keep in view

- Development builds can read usage directly in any region; App Store builds outside the EU cannot. Keep to the sealed-extension design.
- A status of "approved" can persist after the user switches access off. Trust the foreground re-check plus an empty report.
- `includeEntireCategory` reverts to false after decoding a saved selection.
- Threshold events can arrive early on iOS 26.x. Charts are the accurate figure; alerts are a nudge.
- Family Controls (Distribution) on the app alone leaves the extensions unable to ship. All three need it.
- Simulator results for Screen Time are unreliable. Judge on physical devices.

## 13. Definition of done for version 1

- [ ] Requirements R1 to R13 demonstrated on a device
- [ ] Gates A to D recorded as passed in `PROGRESS.md`
- [ ] Core tests pass; Release build has zero warnings
- [ ] Open decisions in the spec answered by the product owner
- [ ] Submitted to App Review
