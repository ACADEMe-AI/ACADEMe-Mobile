# Apple App Store: privacy "nutrition labels" (for the iOS release)

App Store Connect → App Privacy. Not needed for the Play launch; kept here so
iOS starts from the same facts as `data-safety.md`.
Source: [App privacy details on the App Store](https://developer.apple.com/app-store/app-privacy-details/).

Apple's rules differ from Play's in two ways that matter:

- Apple has **no "service provider" exemption for disclosure**: data sent to
  Sarvam, Railway, Resend or RevenueCat on our behalf is still "collected" by us.
  (Play's "shared" and Apple's "collected" are different questions.)
- Data processed only in real time and not kept can be left out only if it meets
  *all* of Apple's optional-disclosure criteria. Scan photos are core to a
  feature and Sarvam keeps job files for a while, so declare them.

## Tracking

**Does this app track users?** **No.** No ads, no data broker, no linking with
other companies' data for advertising. No App Tracking Transparency prompt
needed.

## Data collected

All of it is **linked to the user** (it sits under their account) and **not
used for tracking**.

| Apple category | Data type | Purposes |
|---|---|---|
| Contact Info | Name | App Functionality, Product Personalization |
| Contact Info | Email Address | App Functionality |
| User Content | Photos or Videos | App Functionality |
| User Content | Other User Content (ASKMe questions, notes, to-dos, folder names, scan text, answer reports) | App Functionality |
| Identifiers | User ID (account UUID, Google or Apple subject ID) | App Functionality |
| Purchases | Purchase History (subscription via RevenueCat) | App Functionality, Analytics (only if RevenueCat charts are used) |
| Usage Data | Product Interaction (lessons reached, quiz answers, XP, ratings, daily feature counts) | App Functionality, Product Personalization |
| Other Data | Birth year, class, board, language | App Functionality, Product Personalization |

**Not collected**: Health & Fitness, Financial Info (card details stay with
Apple), Location, Sensitive Info, Contacts, Emails or Text Messages, Audio Data,
Gameplay Content, Customer Support (support happens by email, outside the app),
Browsing History, Search History (ASKMe history search runs on the phone), Device
ID, Advertising Data, Diagnostics (no crash SDK).

Change these when Play's change: voice questions → Audio Data; crash reporting →
Diagnostics (Crash Data); push notifications → Device ID only if the token is
tied to the user.

## Other App Store items that come with this

- **Sign in with Apple** (Guideline 4.8): required on iOS because we offer
  Sign in with Google. Add it before the iOS release.
- **Account deletion in the app** (Guideline 5.1.1(v)): done (Me > Account >
  Delete my account); the web page helps too.
- **Age rating**: Apple's questionnaire asks about unrestricted web access,
  user-generated content and (since 2025) AI chat features. Answer like
  `content-rating.md`; expect 9+ or 13+ because of the AI chatbot.
- **Kids category**: don't choose it. It bans third-party analytics and
  requires parental gates on links and purchases; our audience is 11–18, not
  mainly under-11s.
- **Privacy manifest** (`PrivacyInfo.xcprivacy`): list required-reason APIs
  used by Flutter plugins (`UserDefaults` via shared_preferences, file
  timestamps). Most plugins ship their own; check the Xcode privacy report.
- **Privacy policy URL**: https://academe.cc/privacy.
