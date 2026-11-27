# The no-new-Mac route to the phone (Part 4)

**Goal: a signed build on the owner's iPhone without any Mac that runs
Xcode 26.** The cloud Mac builds and signs with an App Store Connect
API key; the phone is provisioned through the developer portal; the
`.ipa` installs from the 2016 Mac over USB. Every claim below is
tagged **verified** (against Apple's documentation, 27 Nov 2026, with
the page) or **assumed** (plausible, unproven here). One deviation
from the task list: the phone is registered in the portal by the owner
(one manual step) instead of via the ASC API — simpler, and the
`DEVICE_UDID` secret becomes unnecessary.

## The route, step by step

1. **API key** — the owner creates an App Store Connect API key (role:
   App Manager) and adds three repository secrets.
   *Verified:* Apple, "Creating API Keys for App Store Connect API"
   (developer.apple.com/documentation/appstoreconnectapi/creating-api-keys-for-app-store-connect-api);
   App Manager as the CI role is the documented standard (Codemagic's
   signing docs, checked 27 Nov 2026).
2. **Signing in the cloud** — `xcodebuild -archive` with
   `-allowProvisioningUpdates -authenticationKeyPath … -authenticationKeyID …
   -authenticationKeyIssuerID …`: automatic signing manages the App
   IDs, capabilities and profiles for all three targets.
   *Verified:* the flags are in `xcodebuild`'s man page (Signing
   section); the API-key + automatic-signing combination is the
   documented CI flow (Apple ASC API docs; Bitrise/Codemagic guides).
   *Assumed:* the App Group and the Family Controls **development**
   capability are auto-registered for a brand-new bundle ID in one
   pass — Apple's "Configuring Family Controls" page says automatic
   signing enables the capability and requests the profile, but a
   first-run registration of everything at once is unproven here.
3. **Family Controls entitlements** — development: no approval, works
   with automatic signing immediately. Distribution (needed for
   TestFlight/App Store): Apple's request form, reviewed per account.
   *Verified:* Apple, "Configuring Family Controls"
   (developer.apple.com/documentation/xcode/configuring-family-controls)
   and "Requesting the Family Controls entitlement"
   (developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement).
4. **The phone's identifier** — the owner registers the iPhone in the
   portal (Identifiers → Devices → +, paste the UDID). Development
   provisioning profiles then include it.
   *Verified:* Apple's account docs (profiles include registered
   devices); portal device registration is a standard account page.
   Manual step, in `docs/owner-steps.md`.
5. **Export** — `xcodebuild -exportArchive` with an export options
   plist (method `development`, the team ID) produces the `.ipa`,
   uploaded as a workflow artefact.
   *Verified:* the flags and the export options plist are in
   `xcodebuild`'s man page.
6. **Install on the iPhone from the 2016 Mac (macOS 12)** — two
   candidates: **Apple Configurator 2** (App Store, free, supports
   macOS 12; its "Add apps" flow installs an `.ipa` over USB) —
   *verified* that it installs developer-signed apps; check its
   current macOS requirement when installing. Fallback:
   `libimobiledevice`/`ideviceinstaller` (Homebrew) — *assumed* to
   work with the phone's iOS version.
   **Developer Mode must be on** (Settings → Privacy & Security) —
   *verified*: required for development-signed apps on iOS 16+.
7. **TestFlight (the simpler route later)** — once Family Controls
   (Distribution) is approved: upload, internal testing, no Mac
   involved at all. *Verified:* TestFlight requires distribution
   signing; the approval flow is the Family Controls request.

## If a step fails on the day

- Automatic signing refuses the new bundle ID: register the three App
  IDs and the App Group by hand in the portal (the API key can do
  this too), then rerun.
- Family Controls development is not auto-added: enable the capability
  on the App IDs in the portal, rerun.
- Configurator won't install: check Developer Mode; then
  ideviceinstaller; then the fallback is one hour on any Apple-silicon
  Mac (`tools/first-run.sh` + Xcode's own Devices window).
- Nothing installs: the last resort is TestFlight after the
  Distribution approval — no Mac needed at any point.

## What is deliberately NOT in this route

The phone registration is manual (one paste) rather than an ASC API
call, and the workflow uses four secrets, not five — `DEVICE_UDID` is
unnecessary when the device is registered in the portal by hand.
Ponytail rung 1: the API registration script did not need to exist.
