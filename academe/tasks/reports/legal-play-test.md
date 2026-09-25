# Legal and Play Store workstream: test report

2026-09-25. Independent check of `tasks/reports/legal-play.md`, `docs/play/`,
`server/internal/site`, the chat Report route, migration 0019 and the app's
Report sheet and Privacy screen. No emulator was used. The Pixel 10 checks are
queued in `tasks/reports/ui-test-requests.md`.

## Verdict

The workstream holds up. The server pages, limits, escaping and Report route
all behave as described, and every check is green. The key policy decisions are
right. I fixed one small server weakness and a few statements in the listing,
the pages and the docs that the code doesn't back.

## 1. Accuracy against the code

**Release APK** (`flutter build apk --release`, about 2 min; not installed):
`com.academe.flutter`, versionCode 7, versionName 2.0.0, minSdk 24, targetSdk 36.
`aapt dump permissions` lists:

- `INTERNET`
- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `ACCESS_NETWORK_STATE`
- `com.android.vending.BILLING`
- `com.academe.flutter.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

There's no `AD_ID`, camera, media, location or microphone permission. Scan uses
the system camera intent and the photo picker. The docs are consistent with
this, but step 10 of the release checklist missed two of the permissions (fixed).

**Confirmed against the code:**

- **Scan photos** stay in memory only. The server zips them for Sarvam Document
  AI and stores just the text in `scans`, which has no image column.
- **Deletion** has a 30-day grace (`DeletionGrace`). Password log-in, Google
  sign-in, sign-up and password reset all cancel it. Scheduling a deletion drops
  every session.
- **The purge cascades** to `chat_reports`. I deleted a test account and its
  report row disappeared.
- **Pebby's prompt** carries the first name, class, board and language, plus the
  last 20 messages.
- **Access tokens** last 15 minutes. **Hosting** is Railway Singapore
  (`docs/hosting.md`).
- **Request logs** record method, path, status, duration and request ID. There's
  no IP and no email; `email.Log.SendNotice` logs only the subject.
- **The app sends no device info.** Its headers are only Content-Type, Accept and
  Authorization, and there's no timezone, locale, analytics or FCM.

**Gaps found and fixed:**

- **RevenueCat runs for every signed-in user, not only buyers.**
  `BillingRepositoryRemote` configures the SDK at start, and the shell calls
  `logIn(accountId)`. `target-audience.md` said it only ran on purchase. The
  privacy table now also says the SDK sends basic device details (OS and app
  version, country, IP).
- **IP use wasn't disclosed.** The password-reset limiter holds IPs in memory.
  `privacy.html` now says the IP is used briefly for limits and not logged. The
  web form's stored IP was already disclosed.
- **More settings are stored on the phone than the page said.** The daily goal
  and the streak, test and level switches live on the phone too, so
  `privacy.html` now says "reminder and study-goal settings".
- **`deletion_requests.ip`** is disclosed, expires after one year and is not app
  data, so Data safety "Approximate location = No" stands.

## 2. Policy accuracy (checked on the web today)

- **Families target ages 9–12, 13–15, 16–17:** correct. Mixed-audience apps
  must not *require* an SDK that isn't approved for child-directed services, and
  must use a neutral age screen before any such SDK runs. The doc's judgement
  call on Google Sign-In and RevenueCat stands; both are flagged for review.
- **Data safety "shared" vs service provider:** correct. The exceptions are
  service providers, legal requests, user-initiated transfers and anonymised
  data. RevenueCat's own guidance lists only Purchase history as required, and
  Device IDs only when ad-ID integrations are on.
- **AI-generated content:** correct. Chatbot apps must let users report or flag
  offensive output in the app without leaving it, and use those reports for
  moderation.
- **Account deletion URL:** correct. The page must name the app or developer
  and let people request deletion without reinstalling; an email or a form is
  enough. Play also expects service providers to be asked to delete, so the
  RevenueCat-on-purge gap stays open.
- **Subscriptions:** correct. Show the billed price and period as the headline
  (a monthly equivalent for an annual plan must not be), the offer terms before
  purchase, auto-renewal, a dismiss control, and an in-app link to cancel.
- **Metadata:** ALL CAPS and emoji rules apply to the title, icon and developer
  name, so the description's section headings are fine. I corrected the doc's
  wording.
- **DPDP:** the Rules were published on 13 Nov 2025. Rule 4 starts after one
  year (13 Nov 2026). Rules 3, 5–16, 22 and 23 start "eighteen months after
  publication"; some firms read that as 14 May 2027, so the doc now plans for
  13 May and notes the 14 May reading. MeitY's January 2026 idea of a 12-month
  window is for Significant Data Fiduciaries only. `dpdp.md` is updated.

## 3. Server site package (binary on :8097, local Postgres)

- **Pages:** `/`, `/privacy`, `/terms`, `/delete-account` and `/support` return
  200 `text/html`. Headers are CSP `default-src 'none'; style-src
  'unsafe-inline'; img-src 'self' data:; form-action 'self'; frame-ancestors
  'none'; base-uri 'none'`, `nosniff` and `no-referrer`.
- **Unknown paths:** `/nope`, `/index.html`, `/privacy/` and `/chat/threads/xyz`
  return 404, so `/{$}` doesn't swallow them. `/me` without a token gives a JSON
  401, and `POST /privacy` gives 405.
- **XSS:** posting `"><script>alert(1)</script>` returns 422 with the value
  escaped (`&#34;&gt;&lt;script&gt;…`). `<b>x@y.com` is escaped too.
- **Limits:**
  - An email is stored once a day. A repeat is not stored, and neither is an
    upper-case variant.
  - One IP posted 7 times: 5 were stored, and every reply was 200 with an
    identical body.
  - 9 fresh requests produced 9 notice emails.
- **No account enumeration:** an address that has an account and one that
  doesn't get byte-identical pages (same md5). The handler never looks up
  accounts, so timing doesn't differ either. The existing account was not
  scheduled for deletion. I removed the test rows.
- **Fixed:** the per-IP limit counted each IPv6 address on its own, so one
  client could rotate through its /64. `site.clientIP` now groups IPv6 by /64,
  like `auth.clientIP`. New test: `TestClientIPGroupsIPv6ByNetwork`. The
  `openapi.yaml` summary still says "per IP address", which is fine.
- **`POST /chat/messages/{id}/report`:**

  | Case | Result |
  |---|---|
  | Owner reports a Pebby answer | 204 |
  | Owner reports again (reason and note replaced) | 204 |
  | A student message | 404 |
  | Another account's answer | 404 |
  | No token | 401 |
  | Bad or empty reason | 422 |
  | Note of 501 runes (Devanagari) | 422 |
  | Note of 500 runes | 204 |
  | Non-numeric, missing or overflowing ID | 404 |
  | Unknown field or bad JSON | 400 |

  The note is trimmed before it is stored.

## 4. Checks

- **Server:** `gofmt -l .` empty, `go vet ./...` clean, `golangci-lint run`
  0 issues, `go test -race ./...` all green with a real Postgres, and
  `govulncheck` reports no called vulnerabilities. I re-ran lint and tests on
  `internal/site` after my change.
- **App:** `flutter analyze` finds no issues. `reply_actions_test.dart` and
  `privacy_screen_test.dart` pass (3 tests). `dart format` makes no changes to
  the touched files.
- **AGENTS.md:** there are no comments in the owned Go, SQL, Dart, HTML or
  manifest files, and every file is under 300 lines. Widgets are classes, and
  colours follow the existing `AppColors`/`context.palette` usage.
  `chat_messages.dart` is now 228 lines.

## 5. Store listing

- **Lengths** (Python count): title 29/30, short description 72/80, full
  description 3157/4000 after my edits, What's new 432/500.
- **Truthfulness:** checked claim by claim in the code. Fixed:
  - "understands Hinglish" is removed from the listing and `index.html`. Nothing
    in the prompt backs it.
  - "a quick check every 2 to 3 cards" becomes "every few cards". The lesson
    prompt allows a gap of 1–3 cards.
  - "You choose the time" is reworded. The exam-day reminder is fixed at 7 am;
    only the evening nudge and the 3-day and day-before reminders use the
    chosen time.

  Everything else holds: hint-first Solve, Quiz me, terms kept in brackets,
  Scan's three modes with up to 10 pages, no stored photos, kept and missed
  cards, the Didn't know / Almost / Knew it ratings, the by-lesson chapter
  report, folder plans, Today on Home, XP only for right answers, no paywall in
  onboarding, the free limits and the prices.
- **Competitor names:** `grep -rniE "know ?unity|study ?drive"` over the repo
  (excluding build and .git) finds nothing.

## 6. Migration 0019

- **Contents:** `0019_reports.sql` only creates `chat_reports` (FK to
  `chat_messages` and `accounts`, from 0001 and 0004) and `deletion_requests`.
  It doesn't touch other tables and doesn't clash with `0020_token_revocation`
  (another workstream's `accounts.tokens_valid_after`).
- **How Migrate orders them:** `postgres.Migrate` takes an advisory lock and
  lists the files with `fs.Glob`, which returns them sorted by name. It then
  applies every file whose name isn't in `schema_migrations`, all in one
  transaction.
- **Gaps are safe:** the version key is the file name, not a counter, so
  0011–0018 can be added later and will still be applied.
- **The caveat:** on databases that already have 0019 and 0020 (local dev does
  today), a later 0011–0018 runs *after* them. On a fresh database it runs
  *before* them. That's harmless only if 0011–0018 don't depend on, or change,
  what 0019 or 0020 touch. Keep new migrations independent, or number them
  after 0020.

## Files changed by this test

- `server/internal/site/site.go`: IPv6 /64 grouping in `clientIP`.
- `server/internal/site/site_test.go`: new test for it.
- `server/internal/site/pages/index.html`: removed Hinglish; "every few cards".
- `server/internal/site/pages/privacy.html`: IP use; RevenueCat device details;
  settings kept on the phone.
- `docs/play/store-listing.md`: three claims; full-description count; scope of
  the metadata rule.
- `docs/play/target-audience.md`: when RevenueCat runs.
- `docs/play/release-checklist.md`: the actual permission list.
- `docs/play/dpdp.md`: commencement dates and the 12-month proposal.
- `tasks/reports/ui-test-requests.md`: Pixel 10 checks for the Report sheet and
  the Privacy screen.

## Open items for other workstreams (not changed)

- **App delete screen** (`delete_account_screen.dart`) doesn't say that deleting
  the account doesn't cancel the Google Play subscription. `subscriptions.md`
  requires it, and it lists less than the web page does (no folders, notes or
  scans).
- **`account_screen.dart`**: the Google row always says "Not linked", and
  changing the password or linking Google shows "coming soon".
- **RevenueCat:** pass `appUserID` in `PurchasesConfiguration`, and delete the
  customer on purge (already in the workstream report).
- **Listing wording:** the full description names a ₹100 first-month offer. The
  Metadata policy bans promotional pricing in the title, icon and developer
  name, and Play reviewers can be strict. If the listing is rejected, drop that
  clause.
