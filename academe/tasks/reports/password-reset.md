# Password reset (A6 Forgot password, A7 Check your email, A8 Reset password)

## What was built

### Server

- **Migration `0009_password_reset.sql`**: table `password_reset_codes` (account, HMAC of the code, attempts, `expires_at` 15 min, `used_at`, reset token hash, `completed_at`, `created_at`). The code is never stored in clear. It is hashed as HMAC-SHA256(token key, account + code).
- **`internal/auth/reset.go`, `reset_store.go`, `limiter.go`**, plus routes in `handler.go`:
  - `POST /auth/password-reset {email}` always returns `202 {"expiresIn":900}`, whether or not the email has an account. A password account gets a 6-digit code (`crypto/rand`), and asking again replaces the old code. A Google-only account gets an email telling the student to use Continue with Google. An unknown email sends nothing.
  - `POST /auth/password-reset/verify {email, code}` allows 5 attempts per code. The attempt counter goes up atomically in SQL before the code is compared, and the 5th wrong code burns it (`too_many_attempts`). A correct code returns `{resetToken, expiresIn}`, a single-use token (SHA-256 stored) that lasts 15 minutes. Spaces in the code are ignored.
  - `POST /auth/password-reset/complete {resetToken, password}` uses the same password rules as sign-up (8 to 128). It runs as one transaction: it marks the token used, sets the argon2id hash, and deletes every session of the account. It then returns a fresh `Session`, so the app lands signed in. A weak password does not use up the token. If the account was linked to Google in the meantime, the reset is refused.
  - Error codes: `wrong_code` 422, `too_many_attempts` 429, `code_expired` 410 (expired, used, replaced or never sent), `reset_expired` 410, `too_many_requests` 429, `invalid_password` 422.
  - Throttles, in memory: 3 requests per email per hour, 10 requests per IP per hour, and 30 verifies per IP per hour. They are checked before the account lookup, so being throttled reveals nothing. The IP comes from `RemoteAddr`, which `httpx.TrustClientIP` rewrites behind a proxy (`ACADEME_CLIENT_IP_HEADER`).
- **`internal/email`** (new):
  - `Resend` posts to `https://api.resend.com/emails` with a Bearer key.
  - `Log` logs `reset code sent` with the accountID and `googleOnly`, and adds the code only when `ACADEME_EMAIL_DEV=1`.
  - Branded HTML and plain-text templates: purple header, one box per digit, "expires in 15 minutes", "Didn't ask for this? You can ignore this email."
- **Config and main**: `ACADEME_RESEND_API_KEY` (unset means the Log sender, with a startup warning), `ACADEME_EMAIL_FROM` (default `ACADEME <no-reply@academe.cc>`), `ACADEME_EMAIL_DEV`.
- `openapi.yaml` documents the three routes.

### App

- **Routes** (under `_Light`): `/login/forgot`, `/login/forgot/code`, `/login/forgot/new-password`. The page glue is in `lib/routing/password_reset_pages.dart`. "Forgot password?" on the email log-in screen opens the Forgot screen with the email already typed in.
- **Screens** (`lib/ui/auth/widgets/`):
  - `forgot_password_screen.dart`: email field and Send code.
  - `reset_code_screen.dart` with `code_field.dart`: six digit boxes over one hidden number field, with one-time-code autofill and native paste. There is also a Paste code button that pulls the digits out of any text. Six digits verify automatically. The screen has states for a wrong code (red boxes), too many attempts or an expired code (field locked, "Send a new code" offered straight away), and "You can ask for a new code in 0:ss" counting down 30 s.
  - `new_password_screen.dart`: show/hide, the 8+ characters check, and Save and log in. After a celebration it goes home. An expired reset shows "Start again".
  - Pebby reacts on every screen: thinking, encouraging, covering its eyes or shy, and celebrating.
  - Shared pieces: `auth_page.dart` (the log-in layout), `failure_line.dart`, and `password_length_check.dart`. The sign-up screen now uses `password_length_check.dart` too.
- **View models**: `forgot_password_view_model.dart`, `reset_code_view_model.dart` and `new_password_view_model.dart`, all built on commands, plus `auth_failure_of.dart`.
- **Data**: `AuthRepository.requestPasswordReset`, `verifyResetCode` and `completePasswordReset` return `Result`. `completePasswordReset` saves the session exactly as log-in does. New `AuthFailure` values: `wrongCode`, `tooManyAttempts`, `codeExpired`, `resetExpired` and `tooManyRequests`, each mapped from its server code and given a message in `auth_failure_text.dart`.
- `FakeAuthRepository` has matching fakes. The accepted code is `482913`.

## How it was tested

- **Handler tests** (`server/internal/auth/reset_test.go`, with a fake store and fake mailer) cover:
  - the full flow, including that every earlier session is revoked, the old password fails and the new one works;
  - enumeration safety (known, unknown, Google-only and malformed emails get the same body; mail goes only to real accounts);
  - the per-email and per-IP throttles, and their reset after an hour (`testing/synctest`);
  - 5 attempts then burned, and a replaced code being refused;
  - code and token expiry (`synctest`);
  - the token being single-use.
- **Postgres store test** (`reset_store_test.go`) runs against a real database.
- **Resend client tests** run against `httptest`: payload, auth header, HTML/text content, the Google-only variant, and a 403 error. A separate test checks that the Log sender shows the code only in dev.
- The full server definition of done is clean: gofmt, vet, golangci-lint (0 issues), `go test -race ./...` with the database, and govulncheck.
- **App**:
  - widget tests for each screen state (`test/ui/auth/forgot_password_screen_test.dart`, `reset_code_screen_test.dart`, `new_password_screen_test.dart`), covering auto-verify, wrong code, too many attempts, an expired code, the resend countdown, paste, show/hide, success and an expired reset;
  - repository tests with `MockClient` in `test/data/repositories/auth_repository_remote_test.dart`.
  - `flutter analyze` finds no issues in my files. The one warning is in `integration_test/auth_test.dart`, which belongs to the UI-test agent. The full `flutter test` suite is green (135 tests).
- **Real server**: my own build ran on :8092 with `ACADEME_EMAIL_DEV=1` in a throwaway schema, which I dropped afterwards. With curl I went through: sign-up; reset request for a known and an unknown email (identical 202 bodies); a wrong code (422); the right code with a space in it (200 plus a token); reusing that code (410); a short password (422); complete (200, and `/me` works with the new token); completing again (410); the old refresh token (401); the old password (401); the new password (200); 5 wrong codes (the 5th returns 429 `too_many_attempts`, after which the right code is refused too); and the 4th request in an hour (429).
- I did not run the app on the Pixel 10 (the UI-test agent owns the emulator).

## What the user must do: Resend for academe.cc

1. Sign up at resend.com and go to **Domains → Add domain → `academe.cc`**. A subdomain such as `mail.academe.cc` also works if the root domain is already used for other mail.
2. Add the DNS records Resend shows at your DNS host, exactly as shown:
   - **SPF**: an `MX` record and a `TXT` record (`v=spf1 include:amazonses.com ~all`) on the `send` subdomain that Resend names.
   - **DKIM**: the `TXT` record `resend._domainkey` with the public key Resend gives you.
   - **DMARC** (optional, recommended): `TXT` at `_dmarc.academe.cc`, for example `v=DMARC1; p=none; rua=mailto:you@academe.cc`. Tighten it to `p=quarantine` once mail is flowing.
3. Wait until Resend shows the domain as **Verified**. Then go to **API Keys → Create API key** with "Sending access" limited to `academe.cc`.
4. On the server, set `ACADEME_RESEND_API_KEY=re_…`. `ACADEME_EMAIL_FROM` is optional; the default is `ACADEME <no-reply@academe.cc>`. Never set `ACADEME_EMAIL_DEV=1` in production.

## Known limits

- The throttles live in one process's memory. They reset on restart and are not shared between replicas. Move them to Postgres or Redis when there is more than one instance.
- Timing: a request for an existing account waits for Resend, so it is slower than one for an unknown email. Sign-up already reveals whether an email is taken (409), so this gives nothing new away. Send mail from a background queue if that matters.
- `verify` can tell "code burned" (429) apart from "no code" (410) for an email an attacker requested a code for. Sign-up already leaks existence, so this was left as is.
- Emails are English only. Old `password_reset_codes` rows are kept until the account is deleted.
- New screens have no Pixel 10 run and no integration-test journey yet.

## Future improvements

- Localised emails in hi, te, ta and bn, using the student's language.
- A cleanup job for reset rows older than a day, run from `PurgeEvery`.
- Android SMS Retriever or Gmail one-tap for code autofill.
- A "your password was changed" notice email after a completed reset.
