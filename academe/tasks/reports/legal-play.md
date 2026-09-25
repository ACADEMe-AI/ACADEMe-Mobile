# Legal and Play Store workstream: report

2026-09-25. Public policy pages on academe.cc, Play Console answers, in-app
Privacy screen and a Report action on Pebby's answers.

## What was built

### Server: public pages (`server/internal/site`)

- `site.go`, `store.go`, `pages/{layout,index,privacy,terms,delete,support}.html`
  (embedded, `html/template`, no JavaScript, brand purple #564CF1, light and dark
  via `prefers-color-scheme`, 16 px gutters, tables scroll on phones).
- Routes: `GET /` (exact root only, `/{$}`, so unknown paths still 404),
  `GET /privacy`, `GET /terms`, `GET /delete-account`, `GET /support`,
  `POST /delete-account`.
- Headers: strict CSP (`default-src 'none'`, inline styles only,
  `form-action 'self'`, `frame-ancestors 'none'`), `nosniff`, `no-referrer`.
- `POST /delete-account` (form-encoded `email`): validates and lowercases the
  address, stores it in `deletion_requests` with the client IP, and emails a
  confirmation through the email package (reply-to support@academe.cc). Limits
  in SQL: one request per email per day and five per IP per day; over the limit
  it shows the same "Request received" page without storing or emailing, so it
  can't be used to probe accounts or spam an address. Rows older than a year are
  deleted on each request. Support finishes the deletion when the person replies
  from that address.
- `/child-safety`: **not built.** Play's Child Safety Standards policy applies
  to social and dating apps; ACADEMe has no user-to-user features.
- `internal/email/notice.go`: `SendNotice(ctx, to, subject, text)` for `*Resend`
  (plain text, reply-to support@academe.cc) and `Log`. New file only; the
  existing reset email code is untouched.
- `cmd/academe-api/main.go`: 4 lines, `site.RegisterRoutes` with the existing
  mailer (`mailer.(site.Mailer)`).

### Server: report an answer (`server/internal/chat`)

- `POST /chat/messages/{id}/report` `{"reason": "wrong|harmful|offensive|other",
  "note": "≤500"}` → 204. Only the student's own Pebby answers (404 otherwise);
  reporting again replaces the earlier report. `report.go` (service + handler),
  `Report` added to the `Store` interface and `PostgresStore`, route added to
  `RegisterRoutes`.

### Migration

- `0019_reports.sql`: `chat_reports` and `deletion_requests`. **No migration
  number was assigned to this workstream**; 0011–0018 were left free for
  numbered workstreams. Rename before merge if the orchestrator wants a
  different number. It is already applied to the local dev database (the file
  name is the version key).

### openapi.yaml

- Added `POST /chat/messages/{id}/report` and `POST /delete-account`.

### App

- `lib/ui/me/widgets/privacy_screen.dart`: a truthful four-line summary, links to
  https://academe.cc/privacy, /terms, /support ("Get a copy of my data") and
  /support#grievance, and the support email. Opens in the browser with
  `url_launcher`.
- `url_launcher: ^6.3.2` added to `pubspec.yaml` (pure platform channel, no
  native `.so`, so 16 KB alignment isn't affected).
- `lib/config/links.dart`: the site URLs and support@academe.cc.
- `lib/ui/me/widgets/help_screen.dart`: email corrected from `help@academe.app`
  to `support@academe.cc`.
- ASKMe Report: a flag icon under every Pebby answer opens
  `report_sheet.dart` (four reasons), calls `ChatRepository.report`, and shows a
  thank-you or failure snackbar. `_ReplyActions` moved from `chat_messages.dart`
  (which was at 299 lines) into `reply_actions.dart`. `ReportReason` enum in
  `domain/models/chat.dart`; `report` added to `ChatRepository`,
  `ChatRepositoryRemote`, `ChatApiService`, `FakeChatRepository` and
  `AskMeViewModel`.
- `AndroidManifest.xml`: strips `com.google.android.gms.permission.AD_ID`
  (Families rule on advertising ID; nothing in the app uses it).

### Documents (`docs/play/`)

`data-safety.md`, `content-rating.md`, `target-audience.md`,
`store-listing.md` (title 29/30, short 72/80, full 3165/4000, what's new
432/500), `subscriptions.md`, `ai-content.md`, `dpdp.md`,
`app-store-privacy.md`, `release-checklist.md`.

## Key decisions from the research

- **Target audience 9–12, 13–15, 16–17.** Class 6 is about age 11, so the
  Families policy applies; leaving 9–12 out would be misrepresentation.
  "Designed for Families" is no longer a separate program, and Teacher Approved
  is optional and chosen by Google. No ads, no AAID, no location, no unapproved
  ad SDKs. Email sign-up keeps Google Sign-In optional.
- **Nothing is "shared"** in Data safety: Sarvam, Railway, Resend and RevenueCat
  are service providers; Google Sign-In and Play Billing are user-initiated.
- **Photos: ephemeral = No** until Sarvam confirms Document AI job files are
  deleted. Our server never stores them, but Sarvam keeps the job for a while.
- **Generative AI policy applies** (Pebby is a central chatbot). The in-app
  Report action is the required reporting mechanism.
- **DPDP**: every user under 18 is a child, and verifiable parental consent
  (Rule 10) is mandatory from **13 May 2027**. No Fourth Schedule exemption fits
  an app company.

## How it was tested

- Go: `gofmt -l .` clean, `go vet ./...`, `golangci-lint run` 0 issues,
  `ACADEME_TEST_DATABASE_URL=… go test -race ./...` all green,
  `govulncheck` no called vulnerabilities. New tests: `site_test.go` (every page
  renders with CSP and the support address, unknown paths 404, form
  validation, confirmation email sent once, submitted input escaped),
  `site/store_test.go` (per-email and per-IP limits, one-year expiry, on real
  Postgres), `chat/report_test.go` (route table, ownership, Postgres upsert),
  `email/notice_test.go`.
- Ran the binary on :8095 against local Postgres: all pages 200, `/nope` 404,
  POST stores and logs the notice. Test row removed afterwards.
- Flutter: `dart format`, `flutter analyze` clean for all touched files (the 3
  remaining issues are in other workstreams' files), full `flutter test` 143
  passing, including new `test/ui/askme/reply_actions_test.dart` and
  `test/ui/me/privacy_screen_test.dart`.
- **Not run on the Pixel 10.** The rules reserve the emulator for the UI test
  agent. The Report sheet and the Privacy screen need a look there.

## Needs the user

1. Fill the `[[FILL: ...]]` placeholders: legal name, registered address,
   Grievance Officer name and postal address, court city, and Sarvam's retention
   of chat and Document AI data.
2. Point `academe.cc` and `www.academe.cc` at the Railway service
   (`docs/hosting.md`).
3. Make support@academe.cc a real, monitored inbox, and have someone review
   `chat_reports` and `deletion_requests` every week.
4. Get a lawyer to review `dpdp.md`, especially s.9(3) (is study progress
   "behavioural monitoring"?) and Rule 8(3) (one-year retention against our
   30-day purge).
5. Check RevenueCat's terms for a child-directed-services clause.

## Found in other workstreams' code (not changed)

- `purchases_service.dart` configures RevenueCat without `appUserID`, so an
  anonymous ID is created before `logIn`. Pass the account UUID in
  `PurchasesConfiguration`.
- The account purge doesn't delete the RevenueCat customer. Play's
  account-deletion policy and DPDP both expect processors to delete too. Call
  RevenueCat's delete-customer API in `PurgeDeleted`.
- USP 6 says "no metered generations on the syllabus", but the free plan limits
  ASKMe to 10 questions a day. That's a product decision, not a policy problem.
- The paywall must show ₹1,999/year as the headline, with ₹167/month only as
  secondary text (Subscriptions policy).

## Known limits and next steps

- Web deletion is handled by hand after the person replies from their address.
  Next: a signed confirm link in the email that schedules the deletion
  automatically.
- Report exists only on ASKMe answers. Add it to Check my answer marks and to
  lessons made from notes.
- There's no output moderation beyond the system prompt. Add a keyword filter
  in five languages and a helpline answer for self-harm.
- Data export ("Get a copy of my data") works by email only. Next:
  `GET /me/export`.
- DPDP by May 2027: consent notice and consent records at sign-up, the parent
  consent flow with DigiLocker, data processing agreements, a breach runbook
  and a decision on log retention (see `dpdp.md`).
- Policy pages are English only. Translate once the app's own text is
  translated.
