# ACADEMe Pro: plan, billing and limits

Purchases run through **RevenueCat** (needed for Shipaton 2026). Google Play is the only store today. The server is the authority for limits; RevenueCat is the authority for who has paid.

## Pricing and limits

- One Play subscription, `academe_pro`, with two base plans:
  - `monthly`: ₹200/month, with an intro offer `first-month` at ₹100 for the first month.
  - `annual`: ₹1,999/year. The paywall headline is "₹1,999/year". "About ₹167/month · save 17%" appears only as smaller secondary text, as Play's subscriptions policy requires.
- RevenueCat entitlement `academe_pro` (server `ACADEME_REVENUECAT_ENTITLEMENT`, app `--dart-define=REVENUECAT_ENTITLEMENT`, both default `academe_pro`). Offering `default` with packages `$rc_monthly` and `$rc_annual`; the paywall shows only those two even if the offering also has lifetime.
- **Free** includes all lessons, revision, folders and reminders, plus ASKMe 10 messages a day, Scan 3 reads a day and Check my answer once a day. "Just keep the notes" is free; lessons made from notes are Pro only.
- **Pro** is unlimited, and future Pro features (mock exams, weekly parent report) come with it.
- The day resets at midnight in India. The server uses a fixed UTC+05:30 zone (India has no DST), so it doesn't need tzdata.
- Limits are defaults in `server/internal/config/config.go` and can be overridden with `ACADEME_FREE_LIMITS=askme=10,scan=3,check=1,lessons=0`. `0` means Pro only and `-1` means unlimited.

## Server (`server/internal/billing`, migration `0010_billing.sql`)

**Tables**
- `subscriptions`: one row per account. Columns: platform (RevenueCat store), product, base plan, purchase token (store transaction id), state, expires_at (null means a lifetime promotional grant), auto_renew, raw payload, event_at, and timestamps.
- `billing_events`: webhook event ids, used for idempotency.
- `usage_counts`: account, day, feature, count.

**Routes** (all in `openapi.yaml`)
- `GET /me/plan` returns plan, expiresAt, autoRenew, productId, basePlanId, platform, state, limits, usedToday and resetsAt. In `limits`, `null` means unlimited and `0` means Pro only.
- `POST /billing/sync` (signed in, 10 a minute per account, then 429 `too_many_requests`): reads the customer from the RevenueCat **REST API v2** with the secret key (project found from the key, entitlement and product catalogue cached 10 minutes; `GET /customers/{id}`, then `/subscriptions` or `/purchases` for the store details), stores the entitlement and returns the plan. Without `ACADEME_REVENUECAT_SECRET_KEY` it returns 503 `billing_unavailable`. The key must be a v2 secret key with customer read/write permissions (v1 keys are refused by v2 and v2 keys by v1).
- `POST /billing/revenuecat/webhook`: the `Authorization` header must equal `ACADEME_REVENUECAT_WEBHOOK_AUTH` (constant-time compare). If that variable is unset, the route returns 503.
  - Handled events: INITIAL_PURCHASE, RENEWAL, PRODUCT_CHANGE, UNCANCELLATION, SUBSCRIPTION_EXTENDED, NON_RENEWING_PURCHASE (promotional grants and lifetime), TEMPORARY_ENTITLEMENT_GRANT (active), CANCELLATION (canceled; Pro stays until it expires), BILLING_ISSUE (billing_issue; Pro stays until `grace_period_expiration_at_ms`), SUBSCRIPTION_PAUSED (paused; Pro stays until the period ends) and EXPIRATION (re-read from RevenueCat when the secret key is set, so a lifetime grant survives a subscription expiring; otherwise expired).
  - SANDBOX events and sandbox purchases found by sync count only for accounts listed in `ACADEME_BILLING_TESTERS` (comma-separated account UUIDs, or `*` for everyone on a staging server). Default: none, so a TestFlight or license-tester purchase never gives Pro in production.
  - TRANSFER marks the `transferred_from` accounts expired as of the event time (so a late older event can't bring Pro back) and re-syncs the `transferred_to` accounts from RevenueCat.
  - Idempotency: a repeated event id is ignored, and so is an event older than the stored one (compared by `event_timestamp_ms`).
  - Anonymous or unknown `app_user_id`s, events without the `academe_pro` entitlement, and TEST events get a 200 and are ignored.

**Limiter**
- `chat.Send` and `scan.Read`/`Check`/`SaveNotes(makeLesson)` call a small `Limiter` interface through `SetLimiter`.
- It returns 402 `limit_reached` or `pro_only`, with `error.details = {feature, limit, resetsAt}`. `httpx.Error` gained an optional `details` field; the change is additive.
- A use is counted atomically, before the Sarvam call, and refunded if the call fails.
- The notes aren't saved when the lesson is refused, so the app can offer "Just keep the notes".

**Account deletion**
- `auth.PurgeDeleted` now gets the purged account ids back from the store. It calls RevenueCat `DELETE /v2/projects/{project}/customers/{id}` through `auth.SubscriberDeleter`, which is wired only when the secret key is set.
- A failed delete is returned as an error with the account id, and `PurgeEvery` logs it. The account row is already gone at that point, so retry by hand.

**Tests** (all pass)
- Limiter with `testing/synctest`: rollover at IST midnight, refund, Pro only, and Pro expiry.
- Handlers against an httptest fake of the RevenueCat REST API: plan, sync (active, canceled, none, RevenueCat down), and DeleteSubscriber.
- Webhooks: auth (unset, missing, wrong), bad body, TEST, anonymous user, unknown account, each event type, duplicate event id, out-of-order event, and TRANSFER.
- Postgres store test.
- Chat and scan limiter tests in new `limit_test.go` files.
- Auth `purge_test.go`.

**Definition of done**
- `gofmt`, `go vet`, `go test -race ./...` and `govulncheck` are clean.
- `golangci-lint` reports one issue, in `internal/lessons/lessons_test.go` (another workstream's file).

## App

**Dependency**
- Added `purchases_flutter ^10.13.2`, the RevenueCat SDK. It pulls in Play Billing 8.3.0.
- It's set up with `--dart-define=REVENUECAT_GOOGLE_API_KEY` (and `REVENUECAT_APPLE_API_KEY` for iOS later). With an empty key, the paywall shows "Purchases aren't available on this device".
- RevenueCat is set up lazily with our account UUID as `appUserID`, so no anonymous RevenueCat id is created. `Purchases.logIn` and `logOut` handle account switches.
- `identify()` runs when Home opens and on log-out.

**Data layer**
- `PurchasesService` (`RevenueCatPurchasesService` plus a fake).
- `BillingApiService`.
- `BillingRepository`/`BillingRepositoryRemote`:
  - Pro means `/me/plan` says Pro, or `CustomerInfo` has an active `academe_pro`. The CustomerInfo listener switches the UI at once.
  - A purchase or restore then calls `/billing/sync`.
  - Manage uses `customerInfo.managementURL`, falling back to `https://play.google.com/store/account/subscriptions?sku=academe_pro&package=com.academe.flutter`.

**UI (`lib/ui/paywall`)**
- `ProViewModel`.
- `PaywallScreen`:
  - Pebby, a Material-icon list of benefits, and keycap plan tiles. Annual is preselected and marked "Best value".
  - Prices come from `storeProduct`, including the intro phase, and fall back to the defaults.
  - A Continue button and "Restore purchases".
  - Notices for pending, cancelled (silent), errors and "no purchase found".
  - Small print: "Renews automatically. Cancel anytime in Google Play." plus Terms and Privacy links.
- `ProManageScreen`: plan, renews-on or ends-on date, billing-issue warning, Manage in Google Play, and Restore.
- `ProCard` on Me: shows Free or Pro and opens the paywall or Manage.
- `LimitSheet`, a bottom sheet route at `/pro/limit`, says what the limit is, that it comes back at midnight, and offers Go Pro or Maybe later.

**Hooks**
- New failure values `ChatFailure.limitReached`, and `ScanFailure.scanLimit`, `checkLimit` and `proOnly`.
- ASKMe's failed-message bubble shows Go Pro and opens the sheet.
- Scan's problem view shows Go Pro, plus "Just keep the notes" (resaves with `makeLesson: false`) or "Back to your answer", and opens the sheet.

**Tests**
- `test/data/repositories/billing_repository_remote_test.dart` (MockClient, 8 tests).
- `test/ui/paywall/paywall_test.dart` (9 widget tests): default and store prices, unavailable, pending, cancelled, restore-none, network error, Pro card to paywall to Manage, the limit sheet, lessons Pro only, ASKMe limit, Scan limit.
- `router_test` updated.
- Screenshot journey: `integration_test/pro_test.dart`. It hasn't been run, because the emulator belongs to the UI test agent.

**Definition of done**
- `flutter analyze` is clean and the full `flutter test` suite is green.

**Release APK checks**
- 16 KB alignment: `zipalign -P 16` verified. Every `.so` has LOAD alignment ≥ 0x4000; RevenueCat ships no native libraries.
- `aapt dump permissions` shows:
  - Expected: INTERNET, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED.
  - New and expected: `com.android.vending.BILLING` (Play Billing).
  - New from RevenueCat: `ACCESS_NETWORK_STATE`, which it uses for connectivity checks. I left it in; a normal-level permission is harmless, and stripping it risks SDK crashes. Say if you want it removed.
  - Also present: androidx.core's internal `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (signature-level).
- AGENTS.md now lists BILLING and ACCESS_NETWORK_STATE.

## What you need to set up

### Play Console (package `com.academe.flutter`)

1. **Monetize → Products → Subscriptions → Create subscription**, product id `academe_pro`, name "ACADEMe Pro". Add the benefits.
2. **Base plans**:
   - `monthly`: auto-renewing, 1 month, ₹200 (INR; let Play convert other countries or set them). Turn on grace period and account hold.
   - `annual`: auto-renewing, 1 year, ₹1,999.
   - Activate both.
3. **Offer** on `monthly`: offer id `first-month`, eligibility "New customer acquisition", one phase "Single payment" or "Discounted recurring" at ₹100 for 1 month. Tag it if you like, then activate.
4. **License testers**: Settings → License testing, add the testers' Gmail accounts and set response "RESPOND_NORMALLY". Upload an internal-testing build with this code (versionCode above the current one) so Play Billing can find the product.
5. **Service account for RevenueCat**:
   - In Google Cloud (the project linked to Play Console), enable the *Google Play Android Developer API* and the *Google Play Developer Reporting API*.
   - Create a service account and a JSON key.
   - In Play Console → Users and permissions, invite the service account email with app access to ACADEMe and these permissions: View app information and download bulk reports, View financial data, Manage orders and subscriptions.
   - It can take up to 36 hours before RevenueCat can validate.
6. **Real-time developer notifications**:
   - In RevenueCat's Play app settings, connect Google Real-Time Developer Notifications. RevenueCat creates the Pub/Sub topic, or you create `projects/<gcp>/topics/revenuecat-rtdn` and grant `google-play-developer-notifications@system.gserviceaccount.com` Pub/Sub Publisher.
   - Paste the topic name into Play Console → Monetization setup → Real-time developer notifications, then send a test.
   - Our server does not receive Play RTDN directly; RevenueCat does, and it calls our webhook.

### RevenueCat dashboard

1. Create a project called "ACADEMe". Add a **Play Store app** with package `com.academe.flutter` and upload the service-account JSON from step 5.
2. **Products**: import `academe_pro:monthly` and `academe_pro:annual`.
3. **Entitlement** `academe_pro`: attach both products.
4. **Offering** `default` (mark it current):
   - Package `$rc_monthly` gets `academe_pro:monthly`.
   - Package `$rc_annual` gets `academe_pro:annual`.
5. **Webhook** (Integrations → Webhooks): URL `https://api.academe.cc/billing/revenuecat/webhook`. Set the Authorization header to a long random value, for example `Bearer <openssl rand -hex 32>`, and put the identical string in the server's `ACADEME_REVENUECAT_WEBHOOK_AUTH`. Send all events for production and sandbox.
6. **API keys**:
   - Public Android key `goog_…` goes into the app build as `--dart-define=REVENUECAT_GOOGLE_API_KEY=goog_…`. It's safe to ship.
   - The secret key `sk_…` (a **v2** secret API key) goes into the server env as `ACADEME_REVENUECAT_SECRET_KEY` and nowhere else. It's used for `/billing/sync` and for deleting customers when an account is purged.
   - Public iOS key `appl_…` goes in `REVENUECAT_APPLE_API_KEY` later.
7. **Shipaton judges**, either of:
   - (a) RevenueCat → Customers → find the judge's ACADEMe account UUID (the app user id; they sign up first) → **Grant promotional entitlement** `academe_pro` for 1 month or lifetime. RevenueCat sends a NON_RENEWING_PURCHASE webhook (store PROMOTIONAL, production), and the judge can also tap Restore purchases (or the app syncs), and Pro turns on. This is the simplest option and involves no payment.
   - (b) Play Console → Promo codes → create a subscription promo code for `academe_pro` (a free trial period). The judge redeems it in the paywall's Play sheet.
   - Or add judges as license testers, so they can buy with test cards on the internal track.

## Known limits

- `/billing/sync` is limited to 10 a minute per account (in memory, per server instance).
- The count check is atomic per feature. Concurrent requests can't go over the limit; a failed call is refunded.
- An account with a RevenueCat entitlement but no server row gets one on the next webhook or sync.
- If RevenueCat is down during a purge, that customer must be deleted by hand; the error log names the account id.
- The limit sheet shows "comes back at midnight", which is correct for students in India.

## What's left for iOS

- Create an App Store Connect subscription group with `academe_pro` monthly and annual (the intro offer is "Pay up front"/"Pay as you go" at ₹100 for 1 month).
- Add the App Store app in RevenueCat with the in-app purchase key (the StoreKit 2 `.p8`), attach the products to `academe_pro` and `default`, and build with `REVENUECAT_APPLE_API_KEY`.
- The app already picks the Apple key on iOS.
- Copy: the paywall's "Google Play" text and the Manage fallback URL become App Store ones (`https://apps.apple.com/account/subscriptions`); `managementURL` from RevenueCat already covers Manage.
- Enable the In-App Purchase capability in Xcode.
- No server change is needed. RevenueCat normalises App Store events into the same webhook, and `platform` will read `app_store`.

## Future improvements

- A Pro badge in ASKMe and Scan, and "3 of 10 left today" hints from `usedToday`.
- A Pro price A/B test via RevenueCat Experiments.
- Mock exams and the weekly parent report behind `academe_pro`.
- A retry queue for failed RevenueCat customer deletions.

## Tester follow-up

Independent verification, fixes and the RevenueCat v2 move are in `tasks/reports/pro-plan-test.md`.
