# App Store review notes

**App:** Social Time Monitor (placeholder name; bundle `com.YOURORG.socialtimemonitor`)

## Purpose

Social Time Monitor is a wellbeing app for the user's own device. It shows
how long the user spends in apps they choose and compares it with a
self-set daily or weekly target, with colour zones and optional local
reminder notifications at 75% and 100% of that target.

## Screen Time usage

- Authorisation: `AuthorizationCenter.shared.requestAuthorization(for: .individual)`
  — the device owner authorises monitoring of **their own usage only**.
  There is no parental-control functionality and no child devices.
- App selection: the system `FamilyActivityPicker`; the app stores opaque
  tokens only.
- Display: usage figures are drawn entirely inside the sandboxed
  **Device Activity Report extension** (`UsageReport`). Figures never leave
  that extension; the main app cannot read them.
- Reminders: a **Device Activity Monitor extension** (`UsageMonitor`) is woken
  by threshold events on the user's own target and posts local notifications.

## Privacy

- No account, no server, no network code, no analytics, no third-party code.
- Everything stays on the device. The App Store privacy label declares
  **no data collected**.
- Privacy manifest (`PrivacyInfo.xcprivacy`) declares UserDefaults access
  only (own-app + App Group reasons CA92.1, 1C8F.1).

## How to review

1. Launch the app; complete onboarding (allow Screen Time access when
   iOS prompts; the app explains before the prompt).
2. Pick two or three apps in the system picker.
3. The Home screen shows a total for those apps today; compare with
   Settings › Screen Time.
4. Set a target on the Target tab; the bar and status line recolour
   (green → amber at 75% → red over 100%).
5. Optional: switch on Zone alerts; a notification arrives as usage
   crosses 75% / 100% of the target (worded as approximate; the extension's
   threshold events can fire early on some iOS versions, which the app
   guards against).

If Screen Time data is unavailable in review (for example on a fresh
simulator), demo mode renders the same screens from sample figures:
build and run with the launch arguments `-demo -screen home`
(debug builds only; App Store builds contain no demo code).
