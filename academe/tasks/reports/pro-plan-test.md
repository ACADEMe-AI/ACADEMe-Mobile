# ACADEMe Pro: independent test report

Scope: server `internal/billing` (webhook, sync, limiter, purge), the chat and scan hooks, the app paywall and billing data layer, the release APK. No emulator was used. The Pixel 10 checks are queued in `tasks/reports/ui-test-requests.md` ("ACADEMe Pro: paywall, limits and Test Store").

## Bugs found and fixed

### Server

1. **Sync couldn't work with the real key.** The server called RevenueCat REST **v1** (`GET /v1/subscribers`). The project's secret key is a v2 key, and v1 refuses it: `403 {"code":7723,"message":"You're trying to use a secret API key incompatible with RevenueCat API V1."}`.
   - `revenuecat.go` now uses **v2**:
     - The project comes from `GET /v2/projects`.
     - Entitlements and products come from `/entitlements` and `/products`, cached for 10 minutes.
     - Then `GET /customers/{id}` (its `active_entitlements`), then `/subscriptions`, or `/purchases` for lifetime products.
     - Account deletion uses `DELETE /v2/projects/{p}/customers/{id}`; a 404 counts as done.
   - v1 had a second bug: a first `GET /v1/subscribers` answers **201**, which the old code treated as a failure (502). v2's GET doesn't create customers, and a 404 means "no Pro".
2. **Entitlement id.** The real project's entitlement is `academe_pro`, but the code had `"pro"` hard-coded. It's now `ACADEME_REVENUECAT_ENTITLEMENT`, default `academe_pro` (`config.go`, `main.go` and `Service.SetEntitlement`).
3. **Promotional grants were ignored.** RevenueCat sends a granted entitlement (the Shipaton judge path) as `NON_RENEWING_PURCHASE` with store `PROMOTIONAL`, which wasn't a handled event. `SUBSCRIPTION_EXTENDED` and `TEMPORARY_ENTITLEMENT_GRANT` were also dropped, so an extended subscription lost Pro at its old date. All three are handled now.
4. **Billing grace period.** `BILLING_ISSUE` used `expiration_at_ms`, so Pro ended at the old period end. It now keeps Pro until `grace_period_expiration_at_ms`, whichever of the two is later.
5. **EXPIRATION could remove Pro the student still had** (for example a judge with a lifetime grant whose Play subscription expired). When the secret key is set, EXPIRATION now re-reads the customer from RevenueCat and stores that answer, still idempotent on the event id. If RevenueCat is down it returns 502, so RevenueCat retries.
6. **TRANSFER lost the ordering watermark.** It deleted the `transferred_from` row, so a late, older RENEWAL for that account gave Pro back. It now stores an `expired` row stamped with the transfer's time.
7. **Sandbox purchases gave Pro in production.** Decision: `SANDBOX` webhook events, and sandbox subscriptions found by sync, count only for accounts listed in `ACADEME_BILLING_TESTERS`. The value is comma-separated account UUIDs, or `*` for a staging server. The default is none. A license-tester or TestFlight purchase must never unlock production Pro for free. Promotional grants arrive as `PRODUCTION`, so judges aren't affected. The local Test Store journey needs `ACADEME_BILLING_TESTERS=*`.
8. **Free answers through retry.** `POST /chat/threads/{id}/retry` asked Sarvam with no limit, so a free student over the limit could keep regenerating answers. Retry now takes an ASKMe use first and refunds it on failure. The old answer is deleted only after the use is granted, so a 402 keeps it. The app already maps this 402 to the Go Pro sheet (the app fork added a repository test).
9. **`/billing/sync` rate limit.** 10 a minute per account, following the auth limiter's pattern (in-memory sliding window, swept past 10k keys). Over the limit it returns 429 `too_many_requests`.
10. **Smaller fixes:**
    - `store_transaction_id` can be a number in RevenueCat's JSON; it's now tolerated.
    - The 402 message said "today's free askme"; it now says "ASKMe messages", "scans" or "answer checks".

### App (the app fork's work, billing-owned files)

- **Pro carried over after an account switch** if the new account's log-in or plan refresh failed. `identify` now resets plan and customer on every account change.
- **"Already owned"** showed a generic error. It now says "This Google account already has Pro. Tap Restore purchases."
- **Entitlement** is configurable with `--dart-define=REVENUECAT_ENTITLEMENT` (default `academe_pro`); AGENTS.md table updated.
- **Paywall shows only monthly and annual**: `packagesOf()` keeps the `$rc_monthly`/`$rc_annual` package types, or custom packages billed every `P1M`/`P1Y`. Lifetime and anything else is dropped.
- New tests are in `test/data/services/purchases_service_test.dart`. `billing_repository_remote_test.dart` gained tests for the account switch, 402 on retry, and a sync that gets a 429 but leaves the store's Pro on. `paywall_test.dart` covers "already owned".

## Verified with no change needed

- **Webhook auth**: `subtle.ConstantTimeCompare`. A missing or wrong header gets 401; with the variable unset the route returns 503. Tested.
- **Replay and order**:
  - A repeated event id is ignored.
  - An older event can't overwrite a newer one, so an EXPIRATION that arrives before an earlier RENEWAL wins.
  - Tested in the fake store and in Postgres.
- **app_user_id**: RevenueCat anonymous ids, non-UUIDs and unknown accounts get 200 and are ignored.
- **Limiter concurrency**:
  - New Postgres test `TestPostgresTakeIsAtomic`: 40 parallel `Take(askme, 10)` give exactly 10.
  - 40 parallel refunds leave 0, never negative; the `count > 0` guard and the `CHECK (count >= 0)` constraint both hold.
  - 30 parallel `Service.Take` calls allow exactly 10.
- **Refund abuse**:
  - A refund only happens when the Sarvam call, or the save after it, fails, so the student gets nothing for the refunded use.
  - Retry needs a stored Pebby answer (409 otherwise), so "send, abort, retry" doesn't give free questions.
  - Blank scans (`ErrNoText`) are refunded, but they produce nothing.
- **Day rollover**: covered by the synctest test at IST midnight. The server's `resetsAt` read `2026-09-26T00:00:00+05:30` on the live run.
- **Expiry boundary**: `active()` is true a millisecond before `expires_at` and false at the instant (tested).
- **402 shape**: `{"error":{"code":"limit_reached","message":…,"requestId":…,"details":{"feature","limit","resetsAt"}}}`. `pro_only` has `limit: 0`. The openapi entries were checked, and 402 was added to `/chat/threads/{id}/retry`.
- **Paywall and Play policy**:
  - Annual headline "₹1,999/year"; "About ₹167/month · save 17% · renews automatically" appears only as the small caption.
  - Monthly reads "₹100 for the first month, then ₹200/month" plus "Renews automatically".
  - Store prices, including the intro phase, with fallbacks per plan.
  - Purchase outcomes: success syncs, pending shows a notice, cancel is silent, errors show a message. Restore handles "nothing found".
  - `appUserID` is set at configure, so no anonymous RevenueCat user is created. `logIn`/`logOut` run on account switch. The CustomerInfo listener is removed on dispose. With no key, the paywall says purchases aren't available.
- **AGENTS.md**: no comments, no widget-returning methods, palette via `context.palette`, every billing file under 300 lines (`revenuecat.go` is 298).
- **`purchases_flutter` 10.13.2** supports Test Store keys; they need 9.8.0 or later. A Test Store key in a **release** build crashes on purpose, so use it only in debug builds.

## Live run on :8101 (own build, local Postgres, real Sarvam and the real RevenueCat key; `ACADEME_FREE_LIMITS=askme=2`)

1. **Free plan**: `GET /me/plan` for a new account returned free, `limits.askme 2`, `usedToday 0` and `resetsAt` at the next IST midnight.
2. **Limit**: ASKMe #1 and #2 returned 200 (real Sarvam answers); #3 returned 402 `limit_reached` with details.
3. **Real sync**: `POST /billing/sync` against **real RevenueCat v2** returned 200 and plan free. That proves the key, project discovery and catalogue load; the customer doesn't exist, so the answer is 404, which means free.
4. **Webhook auth**: a wrong Authorization header returned 401.
5. **Sandbox**: a `SANDBOX` INITIAL_PURCHASE for a non-tester returned 200 and the plan stayed free.
6. **Pro on**: a `PRODUCTION` INITIAL_PURCHASE turned on Pro (play_store, active, limits null). ASKMe past the free limit returned 200, and `usedToday.askme` read 3.
7. **Pro off**: EXPIRATION re-read the customer from RevenueCat (not there), and the plan went back to free. The next ASKMe returned 402.
8. **Sync rate limit**: 11 fast syncs gave 200 ×9, then 429 ×2. The earlier syncs in this run count toward the minute.

**Clock-skew note from the run.** A webhook whose `event_timestamp_ms` was in the same second as, but just before, a sync was ignored, because sync rows are stamped with the server's `now`. That is the correct rule: sync is newer truth. It does mean the server clock must be NTP-synced. With seconds of skew, events generated right after a sync could be dropped until the next event or sync.

## Not verified (needs the user)

- **Parsing a real customer that has an entitlement.** Creating a throwaway RevenueCat customer and granting it an entitlement through the real API was blocked by this session's permission guard, because it writes to the shared RevenueCat project. The v2 parser is tested against JSON built from RevenueCat's published v2 schema: `Customer.active_entitlements`, `Subscription` (status, auto_renewal_status, gives_access, environment, store, entitlements) and `Purchase`. To confirm by hand (it creates and deletes one customer):

  ```
  K=$(sed -n 's/^REVENUE_CAT_API_KEY=//p' .env | tr -d '"\n\r'); P=https://api.revenuecat.com/v2/projects/proj6a5c04b0; ID=<account uuid>
  curl -X POST -H "Authorization: Bearer $K" -H 'Content-Type: application/json' $P/customers -d "{\"id\":\"$ID\"}"
  curl -X POST -H "Authorization: Bearer $K" -H 'Content-Type: application/json' $P/customers/$ID/actions/grant_entitlement -d '{"entitlement_id":"entld10f94425b","expires_at":<ms 30 days ahead>}'
  # POST /billing/sync as that account → plan pro, platform promotional
  curl -X DELETE -H "Authorization: Bearer $K" $P/customers/$ID
  ```

  The key's delete permission looks right: a DELETE of a customer that doesn't exist returned 404, not 403.
- **Webhook creation by API**: yes, it's possible. The following is not run; the deploy URL isn't final:

  ```
  curl -X POST https://api.revenuecat.com/v2/projects/proj6a5c04b0/integrations/webhooks \
    -H "Authorization: Bearer $REVENUE_CAT_API_KEY" -H 'Content-Type: application/json' \
    -d '{"name":"ACADEMe API","url":"https://api.academe.cc/billing/revenuecat/webhook","authorization_header":"<same value as ACADEME_REVENUECAT_WEBHOOK_AUTH>","environment":null}'
  ```

  It needs the `project_configuration:integrations:read_write` permission on the key. `environment: null` sends both production and sandbox. `event_types` left out means all events.

## Checks

- **Server**:
  - `gofmt -l .` is empty.
  - `go test -race ./...` passes, with Postgres, including the new `TestPostgresTakeIsAtomic`.
  - `govulncheck` reports no called vulnerabilities.
  - `golangci-lint` is 0 issues on billing, chat, scan, config and cmd.
  - Repo-wide lint shows 6 issues, all in other workstreams' files: `lessons/deck.go`, `email/email_test.go` and `site/*`.
- **New server tests**:
  - `internal/billing/money_test.go`: sandbox testers, promotional lifetime, grace period, SUBSCRIPTION_EXTENDED, EXPIRATION re-read (including RevenueCat down), transfer ordering, sync rate limit, v2 parsing (grace, lifetime purchase, another entitlement only, never-seen customer, catalogue cached), the expiry boundary, and the 402 message.
  - `internal/billing/rcfake_test.go`: a v2 fake of RevenueCat.
  - `store_test.go`: the parallel test.
  - `chat/limit_test.go`: `TestRetryIsLimited`.
- **App**:
  - `flutter analyze` finds no issues.
  - `flutter test`: 187 pass and 2 fail, both in `test/routing/deep_links_test.dart`, which the password-reset workstream is changing (it isn't formatted yet either).
  - The billing and paywall tests all pass. The first full run, before those edits, was 158/158.
- **Release APK** (no key, not installed): every `.so` in all three ABIs passes `zipalign -c -P 16` and has LOAD alignment ≥ 0x4000.
  - Permissions: INTERNET, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, ACCESS_NETWORK_STATE and `com.android.vending.BILLING`, plus androidx's signature-level receiver permission. That matches AGENTS.md.
- **`dart format --output=none --set-exit-if-changed lib test testing`**:
  - The first run was clean: 271 files, 0 changed.
  - The final run flags only `test/routing/deep_links_test.dart`, which another agent is changing.
  - It can't be determined which files the earlier global format touched: everything is untracked, no report mentions it, and file times only show agents' edits.

## Known limits

- **Refund across midnight**: a use taken at 23:59:59 IST whose Sarvam call fails after midnight is refunded on the new day. That's at most one extra use, and only when the call fails.
- **Sync rate limit** is in memory, per instance. With several instances it's 10 a minute per instance.
- **Catalogue cache**: entitlements and products added in RevenueCat show up after at most 10 minutes. A product the server can't find in the catalogue falls back to its RevenueCat product id in `productId`.
- **v2 paging**: subscriptions and purchases are read with `limit=100` and no paging. That's plenty for one student.
- **App risks, noted by the app review and not changed**:
  - "save 17%" is hard-coded, so it's wrong for other currencies or Test Store prices.
  - The annual caption can clip "renews automatically" on narrow phones; the small print still says it.
  - Manage's Restore gives no feedback.
  - The limit sheet re-opens when the failed bubble scrolls back into view.

## Files changed

- **Server**:
  - `server/internal/billing/billing.go`
  - `server/internal/billing/revenuecat.go`
  - `server/internal/billing/handler.go`
  - `server/internal/billing/handler_test.go`
  - `server/internal/billing/money_test.go` (new)
  - `server/internal/billing/rcfake_test.go` (new)
  - `server/internal/billing/store_test.go`
  - `server/internal/chat/chat.go` (Retry)
  - `server/internal/chat/limit_test.go`
  - `server/internal/config/config.go` (`BillingTesters`, `RevenueCatEntitlement`)
  - `server/cmd/academe-api/main.go` (two lines)
  - `server/openapi.yaml`
- **App**:
  - `lib/domain/models/pro.dart`
  - `lib/data/services/purchases_service.dart`
  - `lib/data/repositories/billing_repository_remote.dart`
  - `lib/ui/paywall/view_models/pro_view_model.dart`
  - `lib/config/environment.dart`
  - `AGENTS.md` (one row)
  - `test/data/repositories/billing_repository_remote_test.dart`
  - `test/ui/paywall/paywall_test.dart`
  - `test/data/services/purchases_service_test.dart` (new)
- **Docs**:
  - `tasks/reports/pro-plan.md` (v2, entitlement, testers, sync limit)
  - `tasks/reports/ui-test-requests.md` (appended)
- **New server env**:
  - `ACADEME_REVENUECAT_ENTITLEMENT` (default `academe_pro`)
  - `ACADEME_BILLING_TESTERS` (default none; `*` for staging and the local Test Store run)
  - `ACADEME_REVENUECAT_SECRET_KEY` must now be a **v2** secret key.
