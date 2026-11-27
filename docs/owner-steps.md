# Owner steps — from Developer Program to app on your iPhone

Click by click, no engineering needed. Written 27 November 2026; every
technical claim is in `docs/device-route.md` with its source.

## 0. Join the Apple Developer Program (once, ~$99/yr)

1. Go to developer.apple.com/programs and enrol as an Individual.
2. You get a Team ID (10 characters) — you'll need it in step 3.

## 1. Register the app's identifiers and your iPhone

1. Sign in at developer.apple.com/account.
2. **Identifiers → + → App IDs** — create these three (Bundle ID,
   explicit, no capabilities needed yet; the cloud signing turns the
   capabilities on):
   - `com.<your-org>.socialtimemonitor`
   - `com.<your-org>.socialtimemonitor.UsageReport`
   - `com.<your-org>.socialtimemonitor.UsageMonitor`
3. **Identifiers → App Groups** is not needed by hand if the build
   step below succeeds; if it fails, create the group
   `group.com.<your-org>.socialtimemonitor` and tick it on all three
   App IDs.
4. **Devices → +** — register your iPhone: paste its **UDID** (find
   it: Settings → General → About → tap the model number line until
   the UDID row appears, or use Apple Configurator on your Mac).
5. Put `<your-org>` (just the part after "com.", e.g. `yourname`)
   into `Config/org.txt` in the project — replace the single line
   `YOURORG` — or tell GLM and it does it.

## 2. Create the App Store Connect API key

1. Sign in at appstoreconnect.apple.com → **Users and Access →
   Integrations → App Store Connect API**.
2. **+** → name it "build machine" → role **App Manager** → Generate.
3. **Download API Key** (a `.p8` file — once only). Note the **Key ID**
   (shown in the table) and the **Issuer ID** (shown above the table).

## 3. Add the four repository secrets on GitHub

1. On the repo page: **Settings → Secrets and variables → Actions →
   New repository secret**, four times:
   - `ASC_KEY_ID` — the Key ID
   - `ASC_ISSUER_ID` — the Issuer ID
   - `ASC_KEY_P8` — the whole `.p8` file's contents (open it in
     TextEdit; paste everything, including the BEGIN/END lines)
   - `TEAM_ID` — your Team ID from step 0
2. While you are there, if you want the free cloud builds back:
   **Settings → General → Danger Zone → Change visibility → Public**
   (the repo was scanned on 27 November: no secrets in history —
   `docs/public-readiness.md`).

## 4. Run the device build

1. On the repo: **Actions → device → Run workflow → Run**.
2. Wait ~15 minutes; the run ends with an artefact
   **SocialTimeMonitor-ipa** — download and unzip it (the `.ipa`
   inside).

## 5. Turn on Developer Mode and install

1. On the iPhone: **Settings → Privacy & Security → Developer Mode →
   on** (it asks to reboot).
2. Plug the iPhone into your Mac. In **Apple Configurator 2**
   (App Store, free): drag the `.ipa` onto the phone → Add.

## 6. First run and the report

1. Open the app: allow Screen Time access, tick Social + YouTube,
   set a 1-hour target.
2. Use TikTok for five minutes.
3. **Settings → Diagnostics → Copy report** — paste it into a message
   to GLM. That single screen tells us which parts work with real
   data and which fallback (if any) to switch on.

## If any step fails

Tell GLM the step and what the screen said — `docs/device-route.md`
has a fallback for each, and the last resort is one hour on any
Apple-silicon Mac.
