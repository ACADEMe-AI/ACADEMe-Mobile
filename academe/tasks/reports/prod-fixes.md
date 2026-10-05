# Pre-launch fixes (2026-10-05)

These are fixes for the findings in the release, backend and security audits from 2026-10-05. Nothing was committed, pushed or deployed, and no emulator or device was used. The other agent's working-tree changes are kept as they were: streaks (migration 0024), plurals, dates, back-to-chapter, keyboard and landscape.

## What changed

### 1. Release signing (`android/app/build.gradle.kts`)
- **With `android/key.properties`:** release builds are signed with the key it names (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). `storeFile` is resolved from `android/app/`.
- **Without it:**
  - A release APK still builds, signed with the debug key, for local checks.
  - Any build that runs `bundleRelease` stops straight away with:
    `android/key.properties is missing, so this bundle would be signed with the debug key and Play would reject it. Add android/key.properties with storeFile, storePassword, keyAlias and keyPassword, then build the bundle again.`
- **Git:** `android/.gitignore` already ignores `key.properties`, `**/*.jks` and `**/*.keystore`.
- **Docs:** the rule is now in AGENTS.md §10.

### 2. Public links
- **In-app links:** `lib/config/links.dart` points Privacy, Terms and Support at `https://api.academe.cc/…`. The integration test `privacy_test.dart` expects the same URLs.
- **Email templates:**
  - `layout.html` and `layout.txt` take every font, image and link from `SiteURL` (`https://api.academe.cc`).
  - The previews were regenerated.
  - A test now fails if `https://academe.cc` appears in an email.
- **Docs:**
  - Every Play Console URL in `docs/play/*.md` and `docs/hosting.md` is now `https://api.academe.cc/privacy` and `https://api.academe.cc/delete-account`. This covers the data safety, store listing, release checklist, app-store-privacy and subscriptions docs.
  - `docs/hosting.md` now says that `academe.cc` stays the marketing site, and that only the `api` record is needed on Railway.

### 3. H1: Argon2 memory DoS through reset complete
- **Token checked first:** `setPassword` in `internal/auth/reset.go` now looks up the reset token before doing anything else (`ResetAccount`: a SELECT on `reset_token_hash` that also requires `completed_at IS NULL` and `used_at > now − 15 min`). Only then does it hash the password. The `CompleteReset` transaction then re-checks the token in its `UPDATE … RETURNING`.
- **Rate limits:**
  - `POST /auth/password-reset/complete` now goes through the per-IP verify limiter (30 an hour). Over the limit it returns 429 `too_many_requests` with `Retry-After`.
  - `/auth/password-reset/link` was already behind the same limiter.
- **Hashing cap:**
  - The process runs at most 4 Argon2 operations at once. The cap is a buffered channel on `auth.Service` (one Service per process), and waiting for a slot gives up when the request's context is cancelled.
  - Every hash and verify path goes through it: sign-up, log-in (including the dummy hash), reset complete, the web reset form, and `POST /me/password`.
  - `POST /me/password` now applies its 5-an-hour limit to Google-only accounts too.
- **Test:** `TestJunkResetCompletesAreRejectedWithoutHashing` fires 200 parallel junk completes with 128-character passwords while all 4 hashing slots are held. Every request gets 410 `reset_expired` without waiting for a slot.

### 4. H2: reset links could be intercepted
- **Manifest:** the `academe://reset` and `academe://open` intent filter is gone. The only deep link left is the verified `https://api.academe.cc/reset-password` App Link.
- **Reset page:** the "Open in the app" (`academe://`) link is removed from `server/internal/site/pages/reset.html`.
- **`/open` page:** it no longer uses `intent://…;scheme=academe`. It now tells the student to open the app from the home screen, with a Google Play button.
- **App:** `lib/routing/deep_links.dart` accepts a reset token only from:
  - `https://api.academe.cc/reset-password?c=…` or `https://academe.cc/reset-password?c=…`;
  - the path-only route Flutter builds from that App Link (`/reset-password?c=…`).

  It rejects `academe://`, `http://`, other hosts and lookalike hosts. Tests cover each of these.

### 5. M1: per-account log-in limit
- **The limit:** `POST /auth/log-in` now has a per-email gate across all IPs: 20 an hour, multiplied by `ACADEME_AUTH_LIMIT_SCALE`. Over the limit it returns 429 `too_many_requests` with `Retry-After`.
- **What it counts:** every attempt. A real student never gets near 20 an hour, and counting only failures would need a refund path in the limiter.
- **Test:** `TestLogInLimitPerAccountAcrossIPs`. 20 attempts from 20 IPs get 401. The 21st gets 429 with `Retry-After: 3600`. The limit resets after an hour.

### 6. M2: welcome email
- **Subject:** always "Welcome to ACADEMe". The first name appears only in the heading and body, where it is escaped.
- **Sign-up limit:** the per-IP sign-up limit (10 an hour) runs before the account is created, so it also limits welcome emails. `TestThrottledSignUpSendsNoWelcome` proves it.

### 7. M3: scan uploads
- **Quota first:** `scan.Service.ReadUpload` takes the daily quota / Pro check before the multipart body is read, and refunds it if the read fails.
- **When the quota is used up:** the handler answers 402 without parsing the body. It reads the rest of the request into `io.Discard`, so nothing is buffered and the app still gets the 402 instead of a reset connection.
- **New caps:** 4 MB a page and 24 MB an upload (were 8 MB and 40 MB). How the numbers were chosen:
  - The app sends JPEGs at most 2000 px a side at quality 85, which come to about 0.5–2 MB each.
  - Ten pages at about 2 MB is 20 MB.
  - On top of that, one page may run up to 4 MB, plus the multipart overhead. That gives 24 MB.
- **Test:** `TestUploadIsReadOnlyAfterTheQuotaCheck`:
  - over quota → 402 with nothing read;
  - page too big → 422 and a refund;
  - upload too big → 413 and a refund;
  - fits → 201.

### 8. M4: advertising-ID library
- **Exclusion:** `configurations.configureEach { exclude(group = "com.google.android.gms", module = "play-services-ads-identifier") }`.
- **R8 rule:** `android/app/proguard-rules.pro` adds `-dontwarn com.google.android.gms.ads.identifier.**`. RevenueCat refers to the removed class only from `collectDeviceIdentifiers` and its attribution setters, which the app never calls.
- **Checked in a copy:**
  - `:app:dependencies --configuration releaseRuntimeClasspath` lists no ads-identifier, measurement or app-set library.
  - The merged release manifest contains `AD_ID` 0 times.
  - The permissions are unchanged.

### 9. Icons
- **Adaptive launcher icon** (`flutter_launcher_icons`, Android only, run with the existing dev dependency):
  - Files: `mipmap-anydpi-v26/ic_launcher.xml`, plus the foreground and monochrome PNGs at every density. The sources are in `assets/icon/` and are not bundled into the app.
  - Foreground: the ACADEMe cube (`academe_cube.png`) inside the 66% safe zone.
  - Monochrome: a white silhouette, for Android 13+ themed icons.
  - Background: white (`AppColors.lightSurface`). The dark surface colour hides the cube's dark-grey faces, and white matches the icon users already know.
  - The legacy PNGs and the iOS icons are unchanged.
- **Play icon:** `assets/icon/play_store_512.png`, opaque, 512 px.
- **Notification icon:**
  - `ic_stat_academe`: white on transparent, 24 dp, at five densities.
  - `res/raw/keep.xml` keeps it through resource shrinking.
  - `notification_service.dart` uses it, and a test checks the name and that each density exists.

### 10. Report on marks and on lessons made from notes
- **Server:** the existing report endpoint was chat-only, so there is a new additive route, `POST /reports {kind: check|lesson, id, reason, note}` → 204.
  - It returns 404 unless the account owns the item: a Check my answer scan (`scans.mode = 'check'`) or a user deck.
  - It returns 422 `invalid_report` for a bad kind or reason, an id over 100 bytes, or a note over 500 characters.
  - Code: package `internal/report` with handler, service and Postgres store.
  - Storage: `content_reports`, migration **0025**. Rows are deleted when the account is.
  - Documented in `openapi.yaml`.
  - Tests: a handler table test with a fake store, and a Postgres store test covering ownership, mode and upsert.
- **App:**
  - `ReportSheet` moved to `ui/core/ui/` and takes a title. A new shared `ReportButton` (flag icon, tooltip "Report") is used by:
    - ASKMe's reply actions;
    - the Check my answer marks header ("Report these marks");
    - the lesson player top bar for decks made from notes (`u-` ids only, "Report this lesson").
  - Data layer: `ScanRepository.report` and `StudyRepository.reportLesson`, with the matching API service methods and fakes.
  - Widget tests cover both new places, and show that a normal lesson has no Report button.

### 11. "Coming soon" dead taps
- **ASKMe attach sheet:** only Camera and Photos remain. The PDF and From Study tiles are gone, and `onPick` now gives a `PhotoSource`.
- **ASKMe follow-ups:** "Make flashcards" is removed, along with the `onMakeFlashcards` parameter.
- **Home:** the fallback "… is coming soon" snackbars are gone, because the ask bar and quick-action callbacks are now required. They were always wired in the app.
- **Kept on purpose:** "Lessons coming soon", "Coming soon" chapter labels, "State boards are coming soon." and "More languages coming soon". These are information, not buttons.

### 12. RevenueCat anonymous ID
- **Configure only at sign-in:** `RevenueCatPurchasesService` configures the SDK only inside `logIn(accountId)`, with `appUserID` set to the account UUID. Offers, purchase and restore before sign-in return `unavailable` without calling the SDK.
- **Log-out:** it only forgets the account locally. It never calls `Purchases.logOut()`, which would create an `$RCAnonymousID`. A later `logIn` switches the user directly.
- **Test:** a method-channel test asserts that:
  - nothing is called before sign-in;
  - `setupPurchases` carries `appUserId`;
  - the SDK is configured once;
  - `logOut` is never sent.

### 13. `server/railway.json`
- **Settings:** `healthcheckPath: "/healthz"` and `restartPolicyType: "ALWAYS"`. `restartPolicyMaxRetries` was dropped because it only applies to `ON_FAILURE`.
- **Schema check:** every key exists in `https://railway.com/railway.schema.json`.

### 14. Play docs and the privacy page
- **`data-safety.md`:**
  - Checked against migrations 0001–0025.
  - "Other info" adds subjects and the stream.
  - "App interactions" adds study days and streaks, plus reports on marks and lessons.
  - Email adds the reset link and `google_email`.
  - The delete URL is on `api.academe.cc`.
  - The anonymous-ID open point is closed, and the ads library is noted as excluded.
  - "Files and docs" no longer mentions a PDF tile.
- **`store-listing.md`:**
  - The copy now covers subjects and streams, subject rows, chapter filters, streaks and the daily goal, account settings, and Report on marks and lessons.
  - "What's new" is 486 of 500 characters.
  - The URLs are on `api.academe.cc`, and the icon is `assets/icon/play_store_512.png`.
- **`release-checklist.md`:**
  - Rewritten section A: deploy and `api.academe.cc` checks, server variables (Google client IDs, RevenueCat, `ACADEME_ANDROID_CERT_SHA256`), the Android OAuth client with the Play-signing SHA-1, upload signing with the fingerprint check, a versionCode above every upload on any track, and the build command with `GOOGLE_SERVER_CLIENT_ID` and `REVENUECAT_GOOGLE_API_KEY=goog_…` (never `test_`) plus `strings` and `keytool` checks.
  - Steps renumbered.
- **`content-rating.md`:** the seeded-lesson list is corrected to 8 CBSE 10 lessons, none on reproduction.
- **`ai-content.md`:** Report now covers marks and lessons, and there is a weekly `content_reports` query.
- **`target-audience.md`:** notes the excluded ads library and that RevenueCat is configured with the account UUID only.
- **`privacy.html`:**
  - Covers subjects and the stream, study days and the streak, reset codes and links (hashed, 15 minutes, kept at most a day), the Google email, and reports on marks and lessons.
  - Resend's purpose now includes the welcome email and reset links.
  - The date is 5 October 2026.
  - The `[[FILL]]` placeholders are untouched.
- **In-app Privacy summary:** now mentions subjects and the streak.

## Definition of done

| Check | Result |
|---|---|
| `gofmt -l .` | prints nothing |
| `go vet ./...` | clean |
| `golangci-lint run` | 0 issues |
| `go test -race -count=1 ./...` with `ACADEME_TEST_DATABASE_URL` | every package ok; the store tests ran against Postgres |
| `go tool govulncheck ./...` | 0 vulnerabilities affecting our code |
| `go mod tidy` | no diff |
| `dart format --set-exit-if-changed lib test testing integration_test` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 234 passed |
| `flutter build appbundle --release` in a copy without `key.properties` | fails in about 1 s with the error in item 1 |
| `flutter build apk --release` in the same copy | builds (debug-signed, for local checks only) |
| `flutter build appbundle --release` in the copy with a throwaway keystore | builds and is signed by the throwaway key; the keystore was deleted afterwards |

The copy is in the session scratchpad and has no `build`, `.dart_tool`, keystores, `.env` or `server/`.

## What the user still has to do

1. **Signing:**
   - Copy the old app's `android/key.properties` to `academe/android/key.properties`, and its keystore (`my-release-key.jks`) to `academe/android/app/`. The source paths are in the release audit, B1.
   - Run `keytool -list -v -keystore android/app/my-release-key.jks -alias academe`. The SHA-256 must be `66:40:CE:…:57:CD`, matching Play Console → App signing → Upload key certificate.
   - If it doesn't match, or the password is lost: Request upload key reset.
2. **Build:** use RevenueCat's public Play key (`goog_…`, never the `test_` key in `.env`) and the web OAuth client ID:
   ```
   flutter build appbundle --release \
     --dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id> \
     --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_…
   ```
   Then check:
   - `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab` shows `CN=ACADEMe`;
   - `strings` on `libapp.so` finds `goog_` and not `test_`.
3. **Version:** make the versionCode higher than anything uploaded to any track (Play Console → App bundle explorer). Bump `pubspec.yaml` to `2.0.0+8` if a 7 was ever uploaded.
4. **Play status:** check in Play Console that Production is unlocked for this app. The public Play page returns 404 (release audit, B5).
5. **Legal:** fill every `[[FILL: …]]` in `server/internal/site/pages/*.html`. `grep -rn "FILL:" server/internal/site/pages` must print nothing.
6. **Deploy:** commit this work, then deploy the server from a clean tree. That applies migrations 0023, 0024 and 0025, plus the security fixes and the new email templates. Re-run the probes in the backend audit, B1.
7. **Railway variables:**
   - `ACADEME_GOOGLE_CLIENT_IDS` (must include the web client ID);
   - `ACADEME_REVENUECAT_SECRET_KEY` and `ACADEME_REVENUECAT_WEBHOOK_AUTH`, with the same value in the RevenueCat webhook;
   - `ACADEME_ANDROID_CERT_SHA256`: the Play App Signing SHA-256 and the upload key SHA-256, comma-separated. Check that `https://api.academe.cc/.well-known/assetlinks.json` returns 200.
8. **Google Cloud:** an Android OAuth client for `com.academe.flutter` with the Play App Signing SHA-1, and one with the upload SHA-1.
9. **Play Console:**
   - Privacy policy: `https://api.academe.cc/privacy`.
   - Delete account URL: `https://api.academe.cc/delete-account`.
   - Advertising ID: **No**.
   - Data safety answers from `docs/play/data-safety.md`.
   - Upload `assets/icon/play_store_512.png` as the app icon.
   - Make sure nothing still points at the old `www.academe.cc/privacy`, which is the 13+ policy.
10. **DNS:** delete the Namecheap parking A record on the `academe.cc` apex, which breaks TLS there. Optionally add a DMARC record.
11. **Railway hygiene** (backend audit S1–S4): set backup schedules, grow the volume, upgrade to Pro, and add an uptime monitor on `/healthz`.
12. **After installing from Play:**
    - Check the themed icon and the status-bar icon.
    - Open a reset email link (it should open the app once App Links verify).
    - Report a marks screen and a notes lesson, and confirm rows land in `content_reports`.

## Judgement calls to review
- **Launcher icon background:** white, not the dark surface colour. To switch, change `adaptive_icon_background` in `pubspec.yaml` and `ic_launcher_background` in `res/values/colors.xml`, then rerun `dart run flutter_launcher_icons`.
- **Log-in limit:** the per-email limit counts every attempt, so someone can lock one account out of password log-in for an hour. Reset and Google still work.
- **`/open` page:** it no longer opens the app directly, because that needed the custom scheme. It sends people to the home screen or Google Play.
