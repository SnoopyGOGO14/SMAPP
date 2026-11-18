# Build Mac setup — day one

For the person with a newer Mac (2018+ Intel until April 2027, or any Apple
silicon Mac for the long run). Roughly 30 minutes, plus Apple's entitlement
review time.

## 1. Install

- [ ] Xcode 26.3 or later from the Mac App Store (needs macOS Sequoia 15.6+).
- [ ] Homebrew: <https://brew.sh>, then `brew install xcodegen`.
- [ ] Sign into Xcode: Settings › Accounts › add the Apple ID that owns the
  Developer Program membership.

## 2. Get the project

```bash
git clone git@github.com:SnoopyGOGO14/SMAPP.git
cd SMAPP
xcodegen generate
open SocialTimeMonitor.xcodeproj
```

## 3. Replace YOURORG (if not already done)

Ask GLM for the organisation identifier replacement first, or edit yourself:
`project.yml` (bundleIdPrefix + three PRODUCT_BUNDLE_IDENTIFIER settings),
the three `.entitlements` files in `Config/`, and `AppGroupConfig.groupID`
in `Shared/SharedSettings.swift`. Then regenerate: `xcodegen generate`.

## 4. Portal prerequisites

Follow `docs/portal-steps.md`: three bundle IDs, the App Group, Family
Controls (Development) on all three, and the Family Controls (Distribution)
request for each (answers in `docs/AppStore/family-controls-request.md`).

## 5. Run on an iPhone

1. Plug in an iPhone on iOS 17.4 or later.
2. In Xcode: select the **SocialTimeMonitor** scheme and your device.
3. Signing: target › Signing & Capabilities › Team → select your team for
   all three targets (automatic signing).
4. Run. First install prompts the iPhone to trust the developer:
   Settings › General › VPN & Device Management › trust your profile.
5. You should see onboarding, then the real screens after you allow Screen
   Time access and pick apps.

## 6. Gate A — the first device check

The step-by-step checks are in `docs/device-checks.md`. In short:

1. Allow access, pick two or three apps, use one for five minutes.
2. Home's total should match Settings › Screen Time within a minute or two.
3. Removing an app from the selection removes its time.
4. Changing the target recolours the bar and moves the marker.

Record the result (and the iOS version) in `PROGRESS.md` under Gate A.
