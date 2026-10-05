# Fix-ups

## 1. Add chapters opens on an empty subject (UI F2, roadmap E10)

Root cause: `AddChaptersScreen` hides "Coming soon" chapters but still offered
every subject from `StudyViewModel.subjects` and selected the first one. When
that subject had only unwritten chapters (Class 10 CBSE: Computer
Applications), the list stayed empty.

Fix: `lib/ui/study/widgets/add_chapters_screen.dart` offers only subjects that
have at least one chapter with lessons, so the default is always pickable.
The "No chapters for your class yet." note still covers the case with none.

Test: `test/ui/study/catalogue_test.dart` "Add chapters offers only subjects
with lessons to pick" (Maths all coming soon, Science has lessons). It failed
before the fix and passes after.

## 2. Log-in, sign-up and Google rate limits (roadmap A10)

Server, `internal/auth`:

- `limiter.go`: new `wait(key)` returns 0 when the hit is allowed, or how long
  until the next one is. `allow` now calls it.
- `throttle.go` (new): the entry limits and `admit`, which sets `Retry-After`
  (whole seconds, rounded up) and returns `429 too_many_requests`. `clientIP`
  (IPv6 grouped by /64, behind `TrustClientIP`) moved here from `handler.go`
  to keep that file under 300 lines.
- Limits, in memory per instance, like the reset throttles:

| Route | Limit |
|---|---|
| `POST /auth/log-in` | 50 an hour per IP, and 10 per 15 minutes per email + IP (email normalised, capped at 254 bytes in the key) |
| `POST /auth/sign-up` | 10 an hour per IP |
| `POST /auth/google` | 30 an hour per IP |

  Every request counts, successful or not. The check runs after the body is
  decoded and before any password hashing.
- `openapi.yaml`: new `components/responses/Throttled` (with the
  `Retry-After` header), used as `429` on the three routes. The limits are in
  each summary.

App: `too_many_requests` already mapped to `AuthFailure.tooManyRequests`
("That's a lot of tries. Wait a little and try again.") for every auth call,
and the log-in, sign-up and Google screens show the failure text. New tests
lock this in:
`test/data/repositories/auth_repository_remote_test.dart` (429 on sign-up,
log-in and Google) and `test/ui/auth/login_email_screen_test.dart` (the
message shows on the log-in screen).

Server tests (`internal/auth/throttle_test.go`, `testing/synctest`): for each
limit, N requests go through, request N+1 gets 429 with the exact
`Retry-After`, another IP still gets through, and the same IP gets through
again after the window. Also `wait` counts down to the oldest hit.

## 3. Environment variables in the docs

The server reads (`grep -rhoE 'ACADEME_[A-Z0-9_]+' server --include='*.go'`):
`ACADEME_ADDR`, `PORT`, `ACADEME_DATABASE_URL`, `ACADEME_TOKEN_KEY`,
`ACADEME_CLIENT_IP_HEADER`, `ACADEME_GOOGLE_CLIENT_IDS`,
`ACADEME_ANDROID_CERT_SHA256`, `ACADEME_SARVAM_API_KEY`,
`ACADEME_SARVAM_MODEL`, `ACADEME_RESEND_API_KEY`, `ACADEME_EMAIL_FROM`,
`ACADEME_EMAIL_DEV`, `ACADEME_REVENUECAT_SECRET_KEY`,
`ACADEME_REVENUECAT_WEBHOOK_AUTH`, `ACADEME_REVENUECAT_ENTITLEMENT`,
`ACADEME_FREE_LIMITS`, `ACADEME_BILLING_TESTERS`; tests only:
`ACADEME_TEST_DATABASE_URL`, `ACADEME_EMAIL_PREVIEW`.

- `docs/hosting.md`: removed `ACADEME_GOOGLE_PLAY_SERVICE_ACCOUNT` and
  `ACADEME_BILLING_RTDN_SECRET`. Added `ACADEME_REVENUECAT_ENTITLEMENT`,
  `ACADEME_BILLING_TESTERS` and `ACADEME_ANDROID_CERT_SHA256`, the real
  `ACADEME_FREE_LIMITS` default and the two test-only variables. The grep in
  the doc missed names with digits (`SHA256`), so it now uses `[A-Z0-9_]`.
- `tasks/reports/deploy.md`: `ACADEME_ANDROID_CERT_SHA256` added to "unset on
  purpose" (`assetlinks.json` answers 404 until it is set).
- `server/AGENTS.md` §12: added the eight variables it was missing and a
  line about the test-only ones. The app `AGENTS.md` table lists
  `--dart-define`s, and it was already correct.
- `tasks/reports/hosting.md` (an old report) still names the two legacy
  variables. I left it as a record of that time.

## 4. Small known-issue fixes (§11)

1. **Purge expired sessions and old reset rows (A11).** `Store.PurgeExpired`
   deletes sessions past `expires_at` and reset-code rows a day past
   expiry. `PurgeEvery` runs it every hour. Test:
   `TestPurgeExpiredSessionsAndResetCodes` (Postgres).
2. **Password length counted in UTF-16 by the app, in runes by the server.**
   `SignUpViewModel.isLongEnough` counts runes. Sign-up, New password and
   Me → Password all use it. Test: `sign_up_view_model_test.dart` (four
   emoji is 8 UTF-16 units but only 4 characters, so it is too short).
3. **Bidi characters in welcome-email subjects.** `dropControl` also drops
   `unicode.Bidi_Control` (RLO, isolates, marks). ZWJ and ZWNJ, which Indic
   names need, are kept. Test: `TestResendWelcomeEscapesTheName`.
4. **`lesson-pipeline.md` said prompt v3.** It now says `lessons-v4`, which
   matches `internal/lessons/prompts.go`.
5. **`openapi.yaml` was not valid YAML.** The `/reset-password` description
   has an unquoted `: ` in it (from `HEAD`), so it would not parse. The
   description is now quoted.

Checked and found stale: "Router never disposes Home / ASKMe / Study / Me view
models". `AppShell.dispose` already disposes them, and `_HomePage` disposes
`_primer` and `_pro`. I did not change that row. The docs agent can close it.

Not done, because none of these is a quick, clearly safe code fix:
- Revoking earlier reset tokens on a later reset. Doing it in the
  `CompleteReset` transaction can deadlock two concurrent completions.
- Splitting `courses_view.dart` (307 lines). The UI test agent owns it.
- `SHAPE-LANGUAGE.md` dead links. These are design docs.

## Definition of done

Server: `gofmt -l .` is empty, `go vet ./...` passes, `golangci-lint run`
finds 0 issues, `go test -race ./...` passes with `ACADEME_TEST_DATABASE_URL`
set, and `govulncheck` reports 0 vulnerabilities our code calls.
App: `dart format` makes no changes, `flutter analyze` finds no issues and
`flutter test` passes in full (197 tests). No device run, per the agent
rules. The Pixel 10 belongs to the UI test agent.

## Roadmap

A10, A11 and E10 are ticked. Removed from the known issues: F2, "no rate
limits", the password length mismatch, bidi in subjects, the stale
hosting-doc row and the prompt-version row. Added one row: the new limits
are per instance and per IP.

## Known limits and next steps

- The limits live in one process's memory. A second instance doubles them,
  and a restart resets them. Move them to Postgres or Redis together with
  the other throttles.
- A school or cybercafé behind one IP gets 50 log-ins, 10 sign-ups and 30
  Google sign-ins an hour in total. If real schools hit this, raise the
  per-IP numbers or key them on IP + email for sign-up too.
- The app shows a generic "wait a little" message. It does not read
  `Retry-After`. A countdown could use the header later.
