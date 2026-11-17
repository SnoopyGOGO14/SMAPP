# Family Controls (Distribution) — request-form answers

One request per bundle ID (three in total), submitted by the Account Holder at:
https://developer.apple.com/contact/request/family-controls/

Replace `YOURORG` with the real organisation identifier first. Keep the wording
consistent across the three requests — reviewers may read them together.

The form's contact fields (name, email, phone) are the Account Holder's.
"App Apple ID" means the bundle identifier, e.g. `com.YOURORG.socialtimemonitor`.

---

## Shared narrative (paste into the description field of each request)

Social Time Monitor is a wellbeing app for the user's own device. It helps a
person see and self-limit the time they spend on social apps by:

- letting the user choose which of their own apps to watch, using the system
  `FamilyActivityPicker`;
- showing their usage in charts drawn inside the sandboxed Device Activity
  Report extension (usage data never leaves that extension);
- scheduling local reminder notifications when their own usage crosses
  thresholds they set (for example 75% and 100% of a daily limit).

Authorisation is requested with `.individual` for the device owner's own
self-monitoring only. There is no parental-control functionality, no account,
no server, no analytics, and no data collection — the App Store privacy label
states "no data collected". All data stays on the device.

---

## 1. Main app — `com.YOURORG.socialtimemonitor`

**How this app uses Family Controls / DeviceActivity:**

- Requests Screen Time authorisation with
  `AuthorizationCenter.shared.requestAuthorization(for: .individual)`.
- Presents the system `FamilyActivityPicker` so the user selects their own
  apps to monitor.
- Starts monitoring with `DeviceActivityCenter().startMonitoring` on a daily
  (and in weekly mode, weekly) repeating schedule with threshold events the
  user's own target defines, so the app can remind them when they approach
  or reach their self-set limit.
- Hosts `DeviceActivityReport` views rendered by its Device Activity Report
  extension, which is the only place usage figures are computed or drawn.

## 2. UsageReport extension — `com.YOURORG.socialtimemonitor.UsageReport`

**How this extension uses Family Controls / DeviceActivity:**

- A Device Activity Report extension. It receives the activity results the
  main app requests and renders the user's own usage charts (today ring,
  hourly/daily/weekly/monthly bars) inside its sandbox.
- It reads only non-usage settings (the user's target and switch states)
- from the shared App Group; it writes nothing and makes no network calls.
- Usage figures are displayed to the user and never exported anywhere.

## 3. UsageMonitor extension — `com.YOURORG.socialtimemonitor.UsageMonitor`

**How this extension uses Family Controls / DeviceActivity:**

- A Device Activity Monitor extension. It is woken by the system when the
  user's own usage crosses a threshold event the main app scheduled.
- On the 75% and 100% checkpoints it posts a local notification reminding
  the user of their self-set limit. No other processing; no UI; no network.
- It writes a small "last checkpoint" value (date and percentage) to the
  shared App Group so the app can offer an approximate recap message.

---

**After submitting:** record the three dates in `PROGRESS.md` under
"Waiting on the person" → entitlement requests. Approval commonly takes
days to weeks; development continues meanwhile on Family Controls
(Development).
