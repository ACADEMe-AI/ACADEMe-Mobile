# Play release checklist: ACADEMe 2.0.0 (update to com.academe.flutter)

Every step in order. ACADEMe ships as an **update to the existing listing**
(last upload 1.0.5, versionCode 6), so there's no "Create app" step, and the
new build must be signed with the **same upload key** as the old app.

## A. Before touching Play Console

1. [ ] Fill every `[[FILL: ...]]` in `server/internal/site/pages/*.html`:
       legal name, registered address, Grievance Officer name and postal
       address, court city (terms), and Sarvam's retention answer. `grep -rn
       "FILL:" server/internal/site/pages` must print nothing.
2. [ ] Deploy the server (see `docs/hosting.md`). The public pages live on
       `api.academe.cc`; `academe.cc` stays the marketing site. Open
       https://api.academe.cc/, /privacy, /terms, /delete-account and /support
       on a phone. They must load without logging in, and
       `curl -s https://api.academe.cc/privacy | grep -c FILL` prints `0`.
3. [ ] Server variables on Railway (`docs/hosting.md`):
       `ACADEME_GOOGLE_CLIENT_IDS` contains the **web** client ID the app
       passes as `GOOGLE_SERVER_CLIENT_ID`; `ACADEME_REVENUECAT_SECRET_KEY` and
       `ACADEME_REVENUECAT_WEBHOOK_AUTH` are set (`POST /billing/sync` no longer
       answers 503); `ACADEME_ANDROID_CERT_SHA256` holds the **Play App
       Signing** SHA-256 (Play Console → Test and release → App integrity) and
       the upload key SHA-256, comma-separated, and
       `https://api.academe.cc/.well-known/assetlinks.json` returns 200 with
       `com.academe.flutter`.
4. [ ] Google Cloud → Credentials: an Android OAuth client for
       `com.academe.flutter` with the **Play App Signing SHA-1**, and one with
       the upload key SHA-1 for sideloaded checks.
5. [ ] Submit the web deletion form with a test address: the page says
       "Request received" and the confirmation email arrives (Resend domain
       verified, `ACADEME_RESEND_API_KEY` set). Reply-to is support@academe.cc.
6. [ ] support@academe.cc receives mail and someone reads it. Grievances
       acknowledged within 48 hours.
7. [ ] `ACADEME_SARVAM_API_KEY` set in production; ASKMe and Scan work.
8. [ ] Reviewer account: create `play-review@academe.cc` with a password, class
       10 CBSE, English, with one folder and one finished lesson so every
       screen has content.
9. [ ] Upload signing: copy the old app's `android/key.properties` (keys
       `storeFile`, `storePassword`, `keyAlias`, `keyPassword`) and its
       keystore (`storeFile` resolves from `android/app/`) into this repo. Both
       are git-ignored. Without `key.properties`, `bundleRelease` stops with
       "android/key.properties is missing…", so a debug-signed bundle can't be
       built. `keytool -list -v -keystore android/app/<keystore> -alias
       academe` must show SHA-256 `66:40:CE:…:57:CD`, the same as Play Console
       → App signing → Upload key certificate. If the key is lost: Request
       upload key reset (takes a few days).
10. [ ] Version: `version: 2.0.0+N` in `pubspec.yaml`, with `N` higher than
       every versionCode ever uploaded to **any** track (Play Console → App
       bundle explorer), and at least 7.
11. [ ] Build without `API_BASE_URL` (it defaults to `https://api.academe.cc`
       in release):

       ```
       flutter build appbundle --release \
         --dart-define=GOOGLE_SERVER_CLIENT_ID=<web OAuth client ID> \
         --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_<public Play SDK key>
       ```

       Use RevenueCat's public Google Play key (`goog_…`), **never** the
       `test_…` Test Store key from `.env`. Check: `keytool -printcert -jarfile
       build/app/outputs/bundle/release/app-release.aab` shows `CN=ACADEMe`,
       not `Android Debug`; `strings` on `base/lib/arm64-v8a/libapp.so` inside
       the bundle finds `goog_` and `https://api.academe.cc`, and no `test_`.
12. [ ] Target API level meets Play's current requirement (Android 16 / API 36
       for updates from 31 Aug 2026; check Play Console → Policy status if
       unsure). `aapt dump badging` shows `targetSdkVersion`.
13. [ ] 16 KB pages: `zipalign -c -P 16 -v 4` passes and every `.so` has LOAD
       alignment ≥ 0x4000 (AGENTS.md §10).
14. [ ] Permissions: `aapt dump permissions` lists only `INTERNET`,
       `ACCESS_NETWORK_STATE`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`,
       Play Billing's `com.android.vending.BILLING` and AndroidX's own
       `com.academe.flutter.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (checked
       on the 2.0.0+7 release APK, 2026-10-05). **No** `AD_ID`, no
       `READ_MEDIA_*`, no location, no camera, no microphone.
       `./gradlew :app:dependencies --configuration releaseRuntimeClasspath`
       shows no `play-services-ads-identifier`.
15. [ ] Full test pass on the Pixel 10: sign-up, Google sign-in, setup sheet,
       lesson, ASKMe answer + Report, Check my answer + Report, a lesson from
       notes + Report, Scan all four modes, folder plan and reminder (the
       status-bar icon is the white cube), Pro purchase with a licence tester,
       a reset email link opening the app, delete account.

## B. Play Console → App content (Policy → App content)

Do these before uploading to production; Play blocks review until all are done.

16. [ ] **Privacy policy**: `https://api.academe.cc/privacy`.
17. [ ] **App access**: "All or some functionality is restricted" → add the
       reviewer account from step 8 (email + password), with the note "Sign up
       is free. Pebby (ASKMe) and Scan need the internet. Pro features are
       available with a test purchase."
18. [ ] **Ads**: "No, my app does not contain ads".
19. [ ] **Content rating**: questionnaire per `content-rating.md`, category
       Reference, News, or Educational, email support@academe.cc.
20. [ ] **Target audience and content**: ages **9–12, 13–15, 16–17**
       (`target-audience.md`). Confirm the Families policy prompts. Store
       presence question: the app is designed for children and teens.
21. [ ] **Data safety**: every answer from `data-safety.md`, including the
       delete-account URL `https://api.academe.cc/delete-account` and the Families
       policy badge. Preview the listing card before submitting.
22. [ ] **Advertising ID**: "No, my app doesn't use advertising ID".
23. [ ] **Government apps**: No. **Financial features**: "My app doesn't
       provide any financial features". **Health apps**: none. **News app**:
       No.
24. [ ] **Photo and video permissions**: not applicable (Android photo picker,
       no `READ_MEDIA_IMAGES`). If Play asks, state that.
25. [ ] Any other declaration Play lists as "Action needed" (for example
       foreground services or exact alarms). We use neither; answer from the
       manifest.

## C. Monetisation

26. [ ] Payments profile active (merchant account) for India payouts.
27. [ ] Subscription `academe_pro` with base plans `monthly` (₹200) and
       `annual` (₹1,999), and the `first-month` ₹100 introductory offer on
       monthly (`subscriptions.md`). Activate them.
28. [ ] Service account with "View financial data" and "Manage orders and
       subscriptions" linked in RevenueCat; real-time developer notifications
       topic set to RevenueCat's; RevenueCat webhook to
       `https://api.academe.cc/billing/revenuecat/webhook` returns 2xx on a test
       event.
29. [ ] Licence testers (Setup → License testing) include the team's Google
       accounts; a test purchase, renewal and cancellation all update Pro in
       the app.
30. [ ] Paywall checked against the checklist in `subscriptions.md` (full
       price as the headline, intro offer terms, auto-renew, how to cancel,
       close button).

## D. Store listing

31. [ ] Main store listing from `store-listing.md`: name, short and full
       description, icon (`assets/icon/play_store_512.png`), feature graphic,
       4–8 phone screenshots.
32. [ ] Category Education; tags; contact email support@academe.cc; website
       https://academe.cc (the marketing site; leave empty if it isn't live
       with a valid certificate).
33. [ ] Countries/regions: **India only** for 2.0.0.

## E. Testing tracks and release

34. [ ] Internal testing: upload the bundle, add testers, install from Play,
       repeat step 15 on a real device from the Play build (Play-signed).
35. [ ] Read the **pre-launch report** (Release → Testing → Pre-launch report):
       crashes, accessibility, security warnings. Fix anything red.
36. [ ] Closed testing (optional for an existing production app; mandatory
       14 days with 12 testers only for new personal accounts). Recommended:
       one week with 20+ real students and a parent or two.
37. [ ] Production release: release name "2.0.0", release notes = "What's new"
       from `store-listing.md`. **Staged rollout 10%**.
38. [ ] After review passes: watch Android vitals (crash rate < 1.09%, ANR
       < 0.47%), `chat_reports` and support mail for 48 hours, then 50%, then
       100%.

## F. After launch, every week

39. [ ] Review `chat_reports` (query in `ai-content.md`) and act on harmful
       ones the same day. Also review `content_reports` (Check my answer marks and
       lessons made from notes).
40. [ ] Handle web deletion requests: `SELECT * FROM deletion_requests ORDER BY
       created_at DESC`. When the person replies from that address, delete the
       account (same effect as in-app: set `deletion_requested_at` to 30 days
       ago so the next hourly purge erases it, or schedule it normally) and
       reply to confirm.
41. [ ] Reply to Play reviews; answer grievances within the promised times.
42. [ ] Any new SDK, permission, table or feature that sends data: update
       `data-safety.md`, the Data safety form, `/privacy` and the in-app
       Privacy summary in the same change.
