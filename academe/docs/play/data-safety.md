# Play Console: Data safety answers

Play Console → App content → Data safety. Answers checked against the code on
2026-09-25 (`server/internal/postgres/migrations/0001`–`0019`, `lib/data/`,
`AndroidManifest.xml`, `pubspec.yaml`). Re-check whenever a plugin, SDK or
table is added.

Source for the form and its definitions:
[Provide information for Google Play's Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469).
RevenueCat's own guidance:
[Google Play's Data Safety (RevenueCat docs)](https://www.revenuecat.com/docs/platform-resources/google-platform-resources/google-plays-data-safety).

## Definitions that decide the answers

- **Collected** = sent off the phone (to our server or any SDK). Everything the
  app sends to `api.academe.cc` is collected.
- **Shared** = sent to a third party, **except** service providers acting on our
  instructions, legal requests, user-initiated transfers and anonymous data.
  Sarvam AI, Railway, Resend and RevenueCat are service providers, and Google
  Sign-In and Google Play Billing are started by the user, so **nothing is
  "shared"**.
- **Processed ephemerally** = kept only in memory and only for the request.
- **Optional** = every user can skip it. Data the app sends whenever a feature
  is used is marked **required**; only the profile fields on the skippable
  setup sheet are optional.

## Section 1: Data collection and security

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes**. Release builds refuse plain `http` (debug-only network config), the API is `https://api.academe.cc` behind Railway's TLS edge, and Sarvam, Resend, RevenueCat and Google are all called over HTTPS |
| Which of the following methods of account creation does your app support? | **Username and password** (email + password) and **OAuth** (Sign in with Google) |
| Do you provide a way for users to request that their data is deleted? | **Yes** |
| Delete account URL | `https://academe.cc/delete-account` |
| Committed to follow the Play Families Policy (badge) | **Yes**, because the target audience includes under-13s (see `target-audience.md`) |
| Independent security review (MASA) | **No** (optional; costs money; revisit later) |
| UPI | **No** |

## Section 2: Data types

Everything not listed as "Yes" below is **not collected**.

| Category | Data type | Collected | Shared | Ephemeral | Required / optional | Purposes |
|---|---|---|---|---|---|---|
| Location | Approximate location | No | | | | |
| Location | Precise location | No | | | | |
| Personal info | **Name** | Yes | No | No | Required | App functionality, Personalization, Account management |
| Personal info | **Email address** | Yes | No | No | Required | App functionality, Account management |
| Personal info | **User IDs** | Yes | No | No | Required | App functionality, Account management |
| Personal info | Address | No | | | | |
| Personal info | Phone number | No | | | | |
| Personal info | Race and ethnicity | No | | | | |
| Personal info | Political or religious beliefs | No | | | | |
| Personal info | Sexual orientation | No | | | | |
| Personal info | **Other info** | Yes | No | No | Optional | App functionality, Personalization |
| Financial info | User payment info | No | | | | |
| Financial info | **Purchase history** | Yes | No | No | Required | App functionality, Account management, Analytics |
| Financial info | Credit score | No | | | | |
| Financial info | Other financial info | No | | | | |
| Health and fitness | Health info / Fitness info | No | | | | |
| Messages | Emails | No | | | | |
| Messages | SMS or MMS | No | | | | |
| Messages | **Other in-app messages** | Yes | No | No | Required | App functionality |
| Photos and videos | **Photos** | Yes | No | **No** (see note) | Required | App functionality |
| Photos and videos | Videos | No | | | | |
| Audio | Voice or sound recordings / Music / Other audio | No | | | | |
| Files and docs | Files and docs | No | | | | |
| Calendar | Calendar events | No | | | | |
| Contacts | Contacts | No | | | | |
| App activity | **App interactions** | Yes | No | No | Required | App functionality, Personalization |
| App activity | In-app search history | No | | | | |
| App activity | Installed apps | No | | | | |
| App activity | **Other user-generated content** | Yes | No | No | Required | App functionality |
| App activity | Other actions | No | | | | |
| Web browsing | Web browsing history | No | | | | |
| App info and performance | Crash logs | No | | | | |
| App info and performance | Diagnostics | No | | | | |
| App info and performance | Other app performance data | No | | | | |
| Device or other IDs | Device or other IDs | No | | | | |

### What each "Yes" covers (keep this in sync with the code)

- **Name**: first and last name (`accounts.first_name`, `last_name`), from
  sign-up or Google. The first name goes to Sarvam inside Pebby's system prompt
  (service provider, so not "shared").
- **Email address**: `accounts.email`; used for log-in, password reset codes and
  deletion confirmations sent through Resend. No marketing email, so
  "Developer communications" is **not** ticked. Tick it if we ever send news.
- **User IDs**: our account UUID (also sent to RevenueCat as `app_user_id`) and
  the Google account subject ID (`accounts.google_subject`).
- **Other info**: birth year, class, board and app language from the setup
  sheet (`profiles`). The sheet has a "Later" button, so **optional**.
- **Purchase history**: `subscriptions` (product, base plan, state, expiry,
  auto-renew, purchase token, raw store payload) and RevenueCat's copy. The
  "Analytics" purpose follows RevenueCat's guidance because its dashboard
  charts revenue; untick it only if nobody uses those charts. We never see card
  or UPI details, so User payment info = No.
- **Other in-app messages**: ASKMe questions and Pebby's answers
  (`chat_threads`, `chat_messages`), sent to Sarvam to generate the answer.
- **Photos**: Scan uploads 1–10 photos to our server, which zips them and
  submits a Sarvam Document AI job. Our server never writes them to disk or the
  database. **Ephemeral = No** because Sarvam holds the job files for a while
  on its side and we have not confirmed how long. If Sarvam confirms files are
  deleted when the job finishes, this can become **Yes**.
- **App interactions**: study progress (`deck_completions`, `deck_positions`,
  `kept_cards`, `chapter_results`), quiz answers, XP (`xp_events`), thumbs
  up/down and reports on answers (`chat_messages.rating`, `chat_reports`), and
  daily feature counts for the free limits (`usage_counts`).
- **Other user-generated content**: folders, notes, to-dos and dates
  (`folders`, `folder_items`, `folder_todos`), text read from scans and marks
  (`scans`), lessons made from notes (`user_decks`), deletion reason.

### Deliberately "No", with the reason

- **Device or other IDs**: the app reads no Android ID, IMEI, MAC or advertising
  ID. `AndroidManifest.xml` strips `com.google.android.gms.permission.AD_ID`.
  RevenueCat never calls `collectDeviceIdentifiers()` in our code. **Open
  point:** `lib/data/services/purchases_service.dart` configures RevenueCat
  without an `appUserID` and calls `logIn` afterwards, so the SDK first makes a
  random anonymous ID (`$RCAnonymousID`). RevenueCat says Play hasn't treated
  that as a device ID, but setting `appUserID` to the account UUID in
  `PurchasesConfiguration` removes the question. If that isn't done and Play
  flags it, declare Device or other IDs (App functionality).
- **Crash logs / Diagnostics**: no crash or analytics SDK (no Firebase, no
  Sentry). If one is added, declare it.
- **In-app search history**: ASKMe history search filters on the phone only.
- **Files and docs**: the attach sheet shows a PDF tile but PDF upload is not
  built. Declare Files and docs when it is.
- **Approximate location**: we never derive location from IP. The web deletion
  form stores the IP only to rate-limit the form, and it is not app data.
- **Audio**: no microphone permission, no voice features yet.
- Server access logs (method, path, status, request ID; no IP, no body) are
  operational logs, not data the app collects about the user.

## Answers that change later

| When | Change |
|---|---|
| Voice questions (Sarvam speech) ship | Audio → Voice or sound recordings: collected, App functionality |
| PDF upload ships | Files and docs: collected, App functionality |
| Crash reporting or analytics added | App info and performance and/or App interactions → Analytics |
| Push notifications (FCM) added | Device or other IDs (FCM token): collected, App functionality |
| Marketing email | Email address → Developer communications |
| Sarvam confirms immediate deletion of Document AI job files | Photos → ephemeral **Yes** |
