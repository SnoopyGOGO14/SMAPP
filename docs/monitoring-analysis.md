# How iOS behaviour shapes usage monitoring — research report

18 November 2026. Question from the product owner: how do iOS's various
functions affect monitoring of open-app usage; what is the simplest
method that disturbs nothing; and how does "the same app in a browser"
play out — can browser-viewed YouTube be added to the app's usage time,
or is it best ignored?

Method: Apple documentation (the `.md` trick) + Apple Developer Forums
+ browser-vendor sources. Every conclusion below carries a confidence
tag: **[doc]** verified against Apple documentation this session;
**[forum]** developer/user reports, plausible but not Apple-confirmed;
**[device]** unknown until Gate A — falsifiable only on hardware.

---

## 1. The measurement pipeline (and why ours is the simplest permitted)

iOS attributes usage to whichever app is **frontmost on screen**. That
recording is done by the system, continuously, at no cost to any
third-party app. Three routes exist for an app to read it:

| Route | What it gives | Verdict |
| --- | --- | --- |
| **DeviceActivity report extension** (ours) | Figures computed and drawn inside a sealed extension; the app never holds raw numbers **[doc: DeviceActivityReport]** | The simplest method that meets the brief. No background running, no battery cost beyond brief system wakeups of the ~6 MB monitor extension, no interference with any other iOS feature |
| Direct read (`DeviceActivityData.activityData(filteredBy:)`) | Raw figures in the app | **EU-only** for customer builds (iOS 26.4+); works in dev builds anywhere — a trap we have deliberately avoided **[doc + forum 844623]** |
| Anything else (private APIs, polling, proxies) | — | App Store rejection; no route exists around the sandbox **[doc: sandbox statement]** |

Nothing in our design runs in the background, uses location, VPN or
network, or subscribes to notifications from other apps — so there is
nothing to slow the device or disturb other features. The only
performance watch-item remains five small embedded reports on Home
(device check A9) **[device]**.

## 2. iOS behaviours and their effect on the numbers

| iOS behaviour | Effect on monitoring | Confidence |
| --- | --- | --- |
| App foregrounded | Counted (definition of "usage") | [doc] |
| **Background audio** (YouTube Premium, music apps) | App not frontmost → not counted. Users will think "I listened for 2h" but see minutes | [doc: "frontmost"] |
| **Picture in Picture** | Video keeps playing from a non-frontmost context; whether the source app keeps accruing is not documented | [device] |
| Lock screen / Home screen | Not app usage. Note: a segment's `totalActivityDuration` can include no-app screen time — never use segment totals as "app time" | [forum 722334] |
| Widgets, Live Activities, Dynamic Island | Interactions belong to widget extensions, not the app's frontmost time; expected to be near-zero, unverified | [device] |
| App Switcher previews | Not counted (not frontmost interaction) | [forum] |
| Split View / Slide Over | iPad-only; we filter iPhone devices only, so excluded | [doc: our filter] |
| Focus / Do Not Disturb | No effect on recording | [doc: no linkage] |
| Low Power Mode | No documented effect on recording or threshold timing; possible delivery delays unverified | [device] |
| **Time zone / travel** | Threshold events "accumulate based on the time zone of the scheduled start date" — flying across zones shifts the day's boundary vs local midnight. A London schedule mid-holiday in New York accrues on London time | [doc: DeviceActivityEvent overview] |
| Clock change (DST) | Day boundaries follow the calendar; Core handles 23 h / 25 h days (tested) but device totals may differ by an hour that day | [doc/tested] |
| Device restart | Monitoring is expected to persist; unverified | [device] |
| App deleted / offloaded | Its token goes silent; rows disappear (we clean up) | [doc: tokens void] + [device] for offload |
| Screen Time access revoked | Tokens void; status can still read "approved" — we already re-check on foreground and banner | [forum 746701] |
| **Share Across Devices** | Usage from iPad/Mac appears in iCloud-shared Screen Time; our filter pins `devices: [.iPhone]` so it never contaminates totals | [doc: our filter] |
| App Clips | Get their own bundle identity; not selectable through our picker flow unless the user picks them — edge case, ignored | [device] |
| Another app's own restrictions (Downtime, shields, third-party limits) | Do not affect recording — we observe, we never restrict | [doc] |

## 3. "The same app in a browser" — how each route plays out

The scenario matrix for YouTube, with what iOS attributes and whether
our app can see it **if web domains were enabled** (today our spec's
default is "websites: No" — see §5):

| How it's watched | iOS attributes it to | Our app can count it? |
| --- | --- | --- |
| YouTube **app** | YouTube app token | Yes — today's design |
| **Safari** tab, youtube.com | Safari *app* time **and** the domain `youtube.com` (WebDomainActivity, separate figure) | Domain: yes, if the user selects it in the picker (the picker has a Web Domains section; the filter takes `webDomains:`) **[doc]**. Safari app time: only if the Safari app token is also selected — which counts *all* browsing, not just YouTube |
| Safari **Private** tab | Safari app time only; **domain-level detail is not reported for private tabs** | Domain: no — permanent blind spot **[forum/reports]** |
| **Chrome** | Chrome app time; domain reporting depends on the browser adopting `STWebpageController` — Chrome's coverage is partial/flag-dependent, not guaranteed | Domain: not reliable **[forum; STWebpageController doc: "any third-party browser that contributes web usage via STWebpageController"]** |
| **Firefox** | Firefox app time only (Mozilla has not adopted the reporting API; feature request open) | Domain: no **[forum/Mozilla issue]** |
| **Brave** | Brave reports domains (it integrated STWebpageController) | Domain: yes **[vendor commits]** |
| **Home-screen web app** (Add to Home Screen) | Runs as its own standalone web app, not inside Safari; interacts with Screen Time as its own entry (documented Shield/Downtime behaviour) | As its own app-like entry; cannot be merged with youtube.com | [forum/webkit] |
| **In-app browser** (link inside another app) | Host app's foreground time (SFSafariViewController reports against the host bundle) | As that app's time — a Facebook-embedded YouTube link counts as Facebook | [doc/vendor code] |
| A browser that sets `suppressUsageRecording` | Nothing reported at all — the API lets browsers opt out entirely | No | [doc: STWebpageController] |

**Can YouTube-in-browser be *added* to the app's YouTube total?**
Technically the figures both exist once web domains are selected, and
summing two non-overlapping activity streams is arithmetic we could do
in the Summary. But iOS never tells us that `youtube.com` and the
YouTube app are the same service — both are opaque tokens — so any
"merge" is a display convention we invent, correct only if we guess the
domain↔app pairing right, and it must never also select the *browser
app* token or all Safari time would pour in.

## 4. What enabling web domains would actually cost us

Small, contained work — the platform has done the heavy lifting:

1. `Aggregator` walks `category.applications` only; add the
   `category.webDomains` walk (`WebDomainActivity.totalActivityDuration`
   is iOS 16+) and give domain items their own Summary rows.
2. Checkpoint events already accept `webDomains:` — pass the selected
   domain tokens through `MonitoringScheduler`.
3. `SharedSettings`/summary configuration gain a domain-item kind.
4. Guidance in the picker: select the domain, **not** the Safari app,
   or browser rows will over-count.
5. New device checks: private-tab blind spot, Chrome/Firefox reality
   check, home-screen web-app attribution.

## 5. Recommendation

**Keep v1 as shipped (ignore browser views) — but support web domains
as a close-following v1.1 opt-in, not a merge.** Reasons:

- Most of the brief's audience watches in the apps; the browser path's
  biggest single behaviour (Safari normal tabs) is countable, but its
  second-biggest (private tabs) never will be, and coverage across
  Chrome/Firefox is inconsistent — a "YouTube total" that silently
  varies by browser is worse than an honest app-only figure.
- Displaying `youtube.com` as **its own row** ("YouTube (web)") is
  honest, cheap (§4), and lets the user judge; merging invites
  double-count and pairing mistakes for zero additional truth.
- Never select browser app tokens alongside domains (over-count); keep
  browsers out of the suggested picks.

If the owner wants it in v1, §4 is the whole change — say the word.

## 6. New obstacles found that we had not covered

1. **Time-zone accrual** (§2) — worth a line in Settings or a device
   check; anyone monitoring on holiday gets London-midnight days.
2. **Private tabs and `suppressUsageRecording` browsers** — structural
   blind spots; document in the App Store copy ("Safari tab time on
   selected sites; private windows are not included").
3. **Segment totals include no-app screen time** — never sum segment
   totals as app time (our Aggregator already sums per-app only, safe).
4. **Home-screen web apps** get their own Screen Time identity — a
   user's "YouTube icon on the Home Screen that is really the website"
   shows as a separate entry, fracturing their mental total.
5. **Widget/Live-Activity interactions** expected ≈ 0 but unverified.
6. **Low Power Mode delivery timing** for threshold alerts unverified.

## 7. Sources

- Apple: DeviceActivityReport, DeviceActivityEvent ("accumulate based
  on the time zone of the scheduled start date"; STWebpageController
  contribution), DeviceActivityFilter (`webDomains:`),
  WebDomainActivity.totalActivityDuration, FamilyActivityPicker
  ("categories, applications, and web domains"), STWebpageController
  (incl. suppressUsageRecording), activityData EU limits.
- Apple Developer Forums: 722334 (segment totals), 746701 (access
  withdrawal), 844623 (EU entitlement dev-vs-distribution), 804771
  (suppressUsageRecording usage).
- Community/vendor: Brave STWebpageController commits (brave-ios#8566,
  brave-core#3939); Mozilla Firefox iOS issue #14975 and feature
  request; reddit nosurf report (Firefox app-time only); Apple Support
  and third-party write-ups on private-tab exclusion; WebKit/openpwa
  on home-screen web apps' standalone identity.
