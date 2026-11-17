# Portal steps — for the person

Click-by-click. Do these on developer.apple.com with the Account Holder
login. Time estimate: 15–20 minutes, plus the request forms.

Before starting, decide the organisation identifier (for example
`com.yourname`) — it prefixes every identifier below. Replace `YOURORG`
accordingly.

## 0. Membership

- [ ] Join the Apple Developer Program ($99/year) if not already a member:
  developer.apple.com/programs → Enroll. The Account Holder identity matters:
  only they can submit the Family Controls requests in step 4.

## 1. Register the three bundle IDs

For each of these identifiers, repeat:

1. developer.apple.com → Account → **Certificates, Identifiers & Profiles**
   → **Identifiers** → **+**
2. Choose **App IDs** → Continue
3. Description: `Social Time Monitor` / `Usage Report extension` /
   `Usage Monitor extension`
4. Bundle ID: **Explicit**, enter:
   - `com.YOURORG.socialtimemonitor`
   - `com.YOURORG.socialtimemonitor.UsageReport`
   - `com.YOURORG.socialtimemonitor.UsageMonitor`
5. Capabilities: tick **Family Controls** (this is the Development
   capability) — the App Group is attached in step 2
6. Continue → Register

## 2. Register the App Group and attach it to all three IDs

1. **Identifiers** → switch the dropdown top-right from "App IDs" to
   **App Groups** → **+**
2. Description: `Social Time Monitor shared settings`
   Identifier: `group.com.YOURORG.socialtimemonitor` → Continue → Register
3. Back to **Identifiers** (App IDs list) → open the main app's ID →
   **App Groups** → tick enabled → **Edit**… tick the group → Continue → Save
4. Repeat for both extension IDs

## 3. What you can skip

- Profiles: automatic signing in Xcode handles them; nothing to create.
- Certificates: created on demand when Xcode first builds to a device.

## 4. Family Controls (Distribution) requests — one per bundle ID

1. Open https://developer.apple.com/contact/request/family-controls/
2. Fill the contact fields as the Account Holder
3. "App Apple ID": the bundle identifier, exactly as registered
4. Description: copy the matching section from
   `docs/AppStore/family-controls-request.md` (shared narrative + the
   section for that bundle ID)
5. Submit. Repeat for the other two bundle IDs.
6. Record the three submission dates in `PROGRESS.md`.

Development entitlement works immediately; Distribution is what lets
TestFlight and the App Store builds sign.

## 5. Tell GLM the identifier

Say the real organisation identifier in the chat (for example
`com.larryfield`). GLM will replace `YOURORG` in `project.yml`, the three
`.entitlements` files, and the request doc, then commit.

## 6. Build Mac (blocking all device work)

The 2016 MacBook Pro cannot run the required Xcode. Any of these unblocks
Sessions 0's device leg, Gate A, and later TestFlight:

- a 2018-or-later Intel Mac or any Apple silicon Mac (needs macOS Sequoia
  15.6+ for Xcode 26.3; Apple silicon stays valid past April 2027)
- a borrowed/second-hand Mac mini M-series is the cheapest long-term option
- Xcode 16 on a Sonoma Mac works for development and Gates A–C, but the
  final App Store upload still needs Xcode 26+
