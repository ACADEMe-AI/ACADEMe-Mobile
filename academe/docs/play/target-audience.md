# Play Console: Target audience and content

Play Console → App content → Target audience and content.

Sources:
[Google Play Families policies](https://support.google.com/googleplay/android-developer/answer/9893335),
[Data practices in Families apps](https://support.google.com/googleplay/android-developer/answer/11043825),
[Families Self-Certified Ads SDK program](https://support.google.com/googleplay/android-developer/answer/9900633).

## Decision

**Target age groups: 9–12, 13–15, 16–17.** Leave 18 and over unticked (a
Class 12 student can be 18, but the app is designed for school students; ticking
18+ changes nothing for Families and only widens the audience we answer for).

Why 9–12 must be ticked: Class 6 starts at about age 11. Leaving it out while
the store listing, the setup sheet and the syllabus are for Class 6 would be
misrepresenting the audience, which Play treats as a policy violation that can
get the app removed. There is no honest way to stay out of the Families policy.

Consequences:

- **The Families policy applies in full** from the first release. Play reviews
  apps with children in the audience more strictly and more slowly.
- The app is **mixed audience** (children and teens). It is not "primarily
  child-directed", but every rule for children applies to any user whose age we
  don't know.
- **"Designed for Families"** is no longer a separate opt-in program. Its rules
  are now the Families policy, which applies automatically once the target
  audience includes under-13s. There is nothing extra to join.
- **Teacher Approved** is not required. Any app that meets the Families
  policies is eligible, and Google's teachers choose which apps to rate.
  There's no application form. Nothing to do.
- The Data safety section can show the **"Committed to follow the Play
  Families Policy"** badge. Tick it.
- Answer **"Does your app unintentionally appeal to children?"** is moot
  because we target them.
- Store listing, screenshots and the icon must be suitable for children.

## Families requirements, one by one

| Requirement | Status in ACADEMe |
|---|---|
| Target audience, Data safety and IARC answers accurate | This folder |
| Content accessible to children is appropriate for children | Lessons are syllabus content. Pebby's system prompt keeps answers to study topics (`server/internal/chat/sarvam.go`). The Report button exists (see `ai-content.md`). **Gap:** no separate output moderation filter before answers are shown |
| Must not transmit AAID, SIM serial, build serial, BSSID, MAC, SSID, IMEI, IMSI from children or unknown-age users | None read. `AD_ID` permission removed in `AndroidManifest.xml`. Check the merged manifest of each release: `aapt dump permissions app-release.apk` must not list `AD_ID` |
| Must not request the phone number through `TelephonyManager` | Not used |
| Location permission / precise location (child-only apps) | No location permission at all |
| Only SDKs approved for child-directed services; in mixed-audience apps unapproved SDKs only behind a neutral age screen, and sign-in must not *require* an unapproved SDK | **Needs checking, see below** |
| Ads only from Families Self-Certified Ads SDKs, no personalised ads to children | **No ads at all.** Declare "No" in the Ads section |
| Social features: safety reminder before exchanging free-form media; adult action before sharing personal info | No user-to-user features. Pebby is not another user |
| Augmented reality safety warning | No AR |
| Bluetooth through Companion Device Manager | No Bluetooth |
| Comply with COPPA, GDPR and local laws | India: DPDP Act (see `dpdp.md`). We don't market to the US or EU, but Play distributes worldwide: restrict countries to **India** at first to keep the legal surface small (Production → Countries/regions) |

### SDKs in the app and whether they're OK for a mixed audience

| SDK | Collects from the phone | Families status |
|---|---|---|
| `google_sign_in` (Sign in with Google) | Google account ID token, name, email | Optional: every student can sign up with email and password instead, so sign-in doesn't *require* it. Children under 13 in India need a Family Link supervised Google account for Google sign-in anyway. Keep email sign-up. **Uncertain:** whether Google Identity Services counts as "approved for child-directed services". Google doesn't publish a list for non-ad SDKs; this is a judgement call |
| `purchases_flutter` (RevenueCat) + Google Play Billing | Purchase data, our account UUID | Runs for every signed-in student, not only buyers: `BillingRepositoryRemote` configures the SDK at app start and calls `logIn(accountId)` whenever the shell opens (`lib/routing/router.dart`), so the SDK talks to RevenueCat on every session. **Check RevenueCat's terms of service for a child-directed clause before release.** If it forbids child-directed use, either keep the paywall behind a parent step or talk to Play Billing directly from our server |
| `flutter_local_notifications`, `flutter_secure_storage`, `shared_preferences`, `image_picker`, `url_launcher`, `http`, `rive`, `timezone` | Nothing sent off the phone | Fine |

Server-side processors (Sarvam, Railway, Resend) aren't SDKs in the app. They
are covered by the privacy policy and Data safety, not by the SDK rule.

## What we are not doing, and when it would be needed

- **Neutral age screen.** Not needed while every user gets the same experience
  and no unapproved SDK runs for unknown-age users. The optional birth year on
  the setup sheet is not a neutral age screen (it's skippable and not asked
  before data is processed). If an ad or analytics SDK is ever added, a neutral
  age screen (birth year, no hint of the "right" answer) must come first.
- **Parent step.** Not a Play requirement for us, but DPDP makes verifiable
  parental consent mandatory for under-18s from 13 May 2027 (see `dpdp.md`).
