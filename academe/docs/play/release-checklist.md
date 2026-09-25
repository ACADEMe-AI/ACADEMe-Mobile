# Play release checklist: ACADEMe 2.0.0 (update to com.academe.flutter)

Every step in order. ACADEMe ships as an **update to the existing listing**
(last upload 1.0.5, versionCode 6), so there's no "Create app" step, and the
new build must be signed with the **same upload key** as the old app.

## A. Before touching Play Console

1. [ ] Fill every `[[FILL: ...]]` in `server/internal/site/pages/*.html`:
       legal name, registered address, Grievance Officer name and postal
       address, court city (terms), and Sarvam's retention answer. `grep -rn
       "FILL:" server/internal/site/pages` must print nothing.
2. [ ] Deploy the server (see `docs/hosting.md`) with `academe.cc` and
       `www.academe.cc` pointing at it as well as `api.academe.cc`. Open
       https://academe.cc/, /privacy, /terms, /delete-account and /support on a
       phone. They must load without logging in.
3. [ ] Submit the web deletion form with a test address: the page says
       "Request received" and the confirmation email arrives (Resend domain
       verified, `ACADEME_RESEND_API_KEY` set). Reply-to is support@academe.cc.
4. [ ] support@academe.cc receives mail and someone reads it. Grievances
       acknowledged within 48 hours.
5. [ ] `ACADEME_SARVAM_API_KEY` set in production; ASKMe and Scan work.
6. [ ] Reviewer account: create `play-review@academe.cc` with a password, class
       10 CBSE, English, with one folder and one finished lesson so every
       screen has content.
7. [ ] Build: `version: 2.0.0+7` or higher in `pubspec.yaml`; `flutter build
       appbundle --release` without `API_BASE_URL` (defaults to production);
       signed with the **existing upload key** (`android/key.properties`, kept
       out of git). If the upload key is lost: Play Console → Setup → App
       signing → Request upload key reset (takes a few days).
8. [ ] Target API level meets Play's current requirement (Android 16 / API 36
       for updates from 31 Aug 2026; check Play Console → Policy status if
       unsure). `aapt dump badging` shows `targetSdkVersion`.
9. [ ] 16 KB pages: `zipalign -c -P 16 -v 4` passes and every `.so` has LOAD
       alignment ≥ 0x4000 (AGENTS.md §10).
10. [ ] Permissions: `aapt dump permissions` lists only `INTERNET`,
       `ACCESS_NETWORK_STATE`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`,
       Play Billing's `com.android.vending.BILLING` and AndroidX's own
       `com.academe.flutter.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (checked
       on the 2.0.0+7 release APK, 2026-09-25). **No** `AD_ID`, no `READ_MEDIA_*`, no
       location, no camera, no microphone.
11. [ ] Full test pass on the Pixel 10: sign-up, Google sign-in, setup sheet,
       lesson, ASKMe answer + Report, Scan all four modes, folder plan and
       reminder, Pro purchase with a licence tester, delete account.

## B. Play Console → App content (Policy → App content)

Do these before uploading to production; Play blocks review until all are done.

12. [ ] **Privacy policy**: `https://academe.cc/privacy`.
13. [ ] **App access**: "All or some functionality is restricted" → add the
       reviewer account from step 6 (email + password), with the note "Sign up
       is free. Pebby (ASKMe) and Scan need the internet. Pro features are
       available with a test purchase."
14. [ ] **Ads**: "No, my app does not contain ads".
15. [ ] **Content rating**: questionnaire per `content-rating.md`, category
       Reference, News, or Educational, email support@academe.cc.
16. [ ] **Target audience and content**: ages **9–12, 13–15, 16–17**
       (`target-audience.md`). Confirm the Families policy prompts. Store
       presence question: the app is designed for children and teens.
17. [ ] **Data safety**: every answer from `data-safety.md`, including the
       delete-account URL `https://academe.cc/delete-account` and the Families
       policy badge. Preview the listing card before submitting.
18. [ ] **Advertising ID**: "No, my app doesn't use advertising ID".
19. [ ] **Government apps**: No. **Financial features**: "My app doesn't
       provide any financial features". **Health apps**: none. **News app**:
       No.
20. [ ] **Photo and video permissions**: not applicable (Android photo picker,
       no `READ_MEDIA_IMAGES`). If Play asks, state that.
21. [ ] Any other declaration Play lists as "Action needed" (for example
       foreground services or exact alarms). We use neither; answer from the
       manifest.

## C. Monetisation

22. [ ] Payments profile active (merchant account) for India payouts.
23. [ ] Subscription `academe_pro` with base plans `monthly` (₹200) and
       `annual` (₹1,999), and the `first-month` ₹100 introductory offer on
       monthly (`subscriptions.md`). Activate them.
24. [ ] Service account with "View financial data" and "Manage orders and
       subscriptions" linked in RevenueCat; real-time developer notifications
       topic set to RevenueCat's; RevenueCat webhook to
       `https://api.academe.cc/billing/revenuecat/webhook` returns 2xx on a test
       event.
25. [ ] Licence testers (Setup → License testing) include the team's Google
       accounts; a test purchase, renewal and cancellation all update Pro in
       the app.
26. [ ] Paywall checked against the checklist in `subscriptions.md` (full
       price as the headline, intro offer terms, auto-renew, how to cancel,
       close button).

## D. Store listing

27. [ ] Main store listing from `store-listing.md`: name, short and full
       description, icon, feature graphic, 4–8 phone screenshots.
28. [ ] Category Education; tags; contact email support@academe.cc; website
       https://academe.cc.
29. [ ] Countries/regions: **India only** for 2.0.0.

## E. Testing tracks and release

30. [ ] Internal testing: upload the bundle, add testers, install from Play,
       repeat step 11 on a real device from the Play build (Play-signed).
31. [ ] Read the **pre-launch report** (Release → Testing → Pre-launch report):
       crashes, accessibility, security warnings. Fix anything red.
32. [ ] Closed testing (optional for an existing production app; mandatory
       14 days with 12 testers only for new personal accounts). Recommended:
       one week with 20+ real students and a parent or two.
33. [ ] Production release: release name "2.0.0", release notes = "What's new"
       from `store-listing.md`. **Staged rollout 10%**.
34. [ ] After review passes: watch Android vitals (crash rate < 1.09%, ANR
       < 0.47%), `chat_reports` and support mail for 48 hours, then 50%, then
       100%.

## F. After launch, every week

35. [ ] Review `chat_reports` (query in `ai-content.md`) and act on harmful
       ones the same day.
36. [ ] Handle web deletion requests: `SELECT * FROM deletion_requests ORDER BY
       created_at DESC`. When the person replies from that address, delete the
       account (same effect as in-app: set `deletion_requested_at` to 30 days
       ago so the next hourly purge erases it, or schedule it normally) and
       reply to confirm.
37. [ ] Reply to Play reviews; answer grievances within the promised times.
38. [ ] Any new SDK, permission, table or feature that sends data: update
       `data-safety.md`, the Data safety form, `/privacy` and the in-app
       Privacy summary in the same change.
