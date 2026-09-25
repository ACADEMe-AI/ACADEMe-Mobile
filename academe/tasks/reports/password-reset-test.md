# Password reset: security test report

Tester for the password-reset workstream. I read the server code (`reset.go`, `reset_store.go`, `limiter.go`, migration 0009, `internal/email`, the handler wiring in `handler.go` and `main.go`, `openapi.yaml`) and the app (`lib/routing/password_reset_pages.dart`, the three screens, `code_field.dart` and the three view models), then attacked it. I did not use the emulator.

## Verdict

The flow is sound. Codes and tokens come from `crypto/rand`, the attempt counter and single-use checks hold up under real concurrency against Postgres, all sessions are revoked, and logs don't leak the code. I fixed three hardening bugs (below) and added tests for each. At the coordinator's request I also fixed the medium finding: access tokens issued before a reset, a Google link or an account deletion request now get 401 right away (fix #4).

## Fixes I made (reset-owned files)

| # | Problem | Fix | Test |
|---|---|---|---|
| 1 | **The limiter sweep was O(n) on every call.** Once a limiter held more than 10,000 live keys (easy with many IPv6 addresses), every request scanned the whole map under the mutex. That is CPU amplification, and all reset traffic is serialised on the lock. | `limiter.go`: a `sweepAt` threshold. After a sweep it becomes `max(10000, 2*len)`, so sweeps are amortised O(1). | `limiter_test.go` `TestLimiterSweepIsAmortised` (synctest: the threshold doubles, and stale keys are gone after an hour) |
| 2 | **Unbounded per-email limiter keys.** Any string up to the 64 KiB body limit became a map key for an hour: about 640 KB per IP per hour. | `reset.go`: the IP limit is checked first. An address longer than 254 bytes then gets the same 202 without touching the per-email limiter or the database. | `TestResetIgnoresOverlongEmails` |
| 4 | **Old access tokens outlived a reset (medium).** Access tokens were checked only for signature and expiry, so a stolen one worked for up to 15 min after a reset, a Google link or a deletion request. | Migration `0020_token_revocation.sql` adds `accounts.tokens_valid_after timestamptz NOT NULL DEFAULT epoch`. `CompleteReset`, `LinkGoogle` and `ScheduleDeletion` set it (to the Go clock, truncated to µs, passed in as a parameter so DB/app clock skew can't reject the fresh token) in the same transaction as the session delete. The access token payload is now `accountID.issuedAtUnixMicro` (expiry = issued + 15 min), which also makes tokens unique below a second. `RequireAccount` → `Authenticate(ctx, token)` rejects a token issued before `tokens_valid_after`. `revoke.go` keeps a per-account cache: 30 s TTL, updated at once in-process on revoke, keeps the later value if a stale DB read races a revoke, amortised sweep. A purged account is gone, so the lookup is `ErrNotFound` → 401 (its tokens were already revoked when deletion was requested). | `reset_test.go` flow: old access tokens (sign-up and log-in) → 401 on `/me` right after complete, new one → 200. `revoke_test.go`: synctest two-instance test (revoking instance rejects at once; the other still passes at 28 s and rejects at 30 s; a later token works), cache keeps latest plus sweep, Google link revokes, tokens a millisecond apart differ. `reset_store_test.go`: `TokensValidAfter` is epoch before, equals the reset time after, and `ErrNotFound` for a missing account. |
| 3 | **IPv6 bypassed the per-IP limits.** Each client gets a /64, so one attacker could rotate through 2^64 addresses. | `handler.go` `clientIP`: v4-mapped addresses are unmapped, and IPv6 is keyed by its /64 prefix. | `TestClientIPGroupsIPv6By64` |

I also added `reset_race_test.go`, `TestPasswordResetRacesPostgres`, which runs against real Postgres through the real `Service`. It passed `-race -count=3`:
- 40 parallel wrong verifies from 40 IPs → exactly 4 `wrong_code` and 36 `too_many_attempts`, and the right code is then refused. The counter can't be raced.
- 40 parallel verifies with the right code → exactly 1 reset token.
- 40 parallel completes with that token → exactly 1 success and 39 `reset_expired`.

`reset_test.go` now exposes `service` on `resetEnv`, which the tests above use.

## Checklist

| Check | Result |
|---|---|
| Enumeration: response bodies and status codes | PASS. `/password-reset` returns `202 {"expiresIn":900}` for known, unknown, Google-only and malformed emails. `/verify` returns 410 `code_expired` for unknown and Google-only emails, and for a known email with no code. |
| Enumeration: timing | KNOWN LIMIT. A known account does a DB write plus a Resend call (live: 7 ms vs 1 ms with the log mailer; with Resend it will be hundreds of ms). A Resend outage returns 500 only for real accounts. Sign-up already leaks existence (409), so this adds nothing new. The fix would be a queued sender. |
| Enumeration via verify after requesting | KNOWN LIMIT (documented): after an attacker requests a code, `wrong_code` 422 vs `code_expired` 410 shows whether the account has a password. |
| Code entropy | PASS. `rand.Int(crypto/rand, 1e6)`, zero-padded to 6 digits, uniform. 5 tries per code and 3 codes per email per hour allow at most 15 guesses per account per hour (≈1/2800 per day). |
| Token entropy | PASS. `rand.Text()` gives 26 base32 characters (130 bits). Only its SHA-256 is stored. |
| HMAC key | `ACADEME_TOKEN_KEY` (32+ bytes, validated at start-up). The same key signs access tokens, but the domains are separate: `reset:<id>:<code>` vs `<id>.<unix>`. The code HMAC is bound to the account ID. Rotating the key invalidates live codes: verify then says `wrong_code` and burns attempts. That is acceptable at a 15-minute TTL, and rotating also forces a re-login. There is no key versioning. |
| Constant-time compare | PASS. `subtle.ConstantTimeCompare` on the HMACs. |
| Brute force racing the attempt counter | PASS. Atomic `UPDATE … attempts = attempts + 1 … RETURNING` with row locking. Proved by the concurrent Postgres test. |
| Reset token single use under concurrency | PASS. `completed_at IS NULL` in the UPDATE, inside a transaction. Proved by the concurrent test. |
| Expiry boundaries | PASS. The code is dead at exactly `expires_at` (`!now.Before`). The token is dead at exactly 15 min (`used_at > now-15m`). Both use the Go clock on both sides, so there is no DB/app clock mix. synctest covers both. |
| Revokes sessions, refresh and access tokens | PASS. `DELETE FROM sessions` and `tokens_valid_after` in the same transaction. Live: the old refresh token and both old access tokens get 401 straight after complete (fix #4). |
| Google-only account | PASS. It gets the "use Continue with Google" email and no code. Verify gives 410. If the account links Google between verify and complete, `CompleteReset` refuses (`password_hash IS NOT NULL`). |
| Email case and whitespace | PASS. `normalizeEmail` (trim + lower) runs on request, verify, sign-up and log-in. Live: requested as `"  Tess@Example.COM "`, verified as `TESS@example.com`. Mail goes to the stored address, never the typed one. Google-created accounts store `identity.Email` unnormalised (outside reset scope; Google already returns lowercase). |
| Limiter memory | FIXED (#1, #2, #3). Growth is now bounded by the request rate × 1 h, with amortised sweeps. |
| Limiter IP source with `ACADEME_CLIENT_IP_HEADER` unset | `RemoteAddr`. Correct when directly exposed. **Behind Railway's proxy, an unset header makes every client share the proxy IP**, so there are 10 reset requests an hour for the whole service. Production must set `ACADEME_CLIENT_IP_HEADER=X-Real-IP` (as `hosting.md` says). |
| Log lines never contain the code | PASS. `email.Log` adds `code` only with `ShowCode` (= `ACADEME_EMAIL_DEV=1`). The access log records only method, path and status. Errors carry no code. Live: the code appeared exactly once, in the dev line. `email_test.go` checks both modes. |
| Resend request format | PASS against the current docs (resend.com/docs/api-reference/emails/send-email): `POST https://api.resend.com/emails`, `Authorization: Bearer`, JSON `from`, `to[]`, `subject`, `html`, `text`, and snake_case `reply_to` (notice). Resend rejects a missing `User-Agent` with 403; Go sends `Go-http-client/1.1`, so this is fine. There is no `Idempotency-Key`: a timeout plus a retry by the student could send two emails, which is harmless because the second code replaces the first. Resend's default limit is 10 requests a second per team, and a Resend 429 becomes a 500. |
| HTML email escaping | PASS. `html/template` (contextual escaping). The only data is digits. JSON encoding escapes the subject. The recipient comes from the DB. |
| openapi | PASS. The three routes, bodies and every error code are documented. |

## Live run (own build on :8096, `ACADEME_EMAIL_DEV=1`, throwaway schema `resettest8096`, dropped afterwards)

| Step | Result |
|---|---|
| sign up | 201 |
| request `"  Tess@Example.COM "` / unknown email | 202 / 202, identical bodies |
| code read from the log | `"msg":"reset code sent",…,"code":"974878"` |
| verify for an unknown email | 410 `code_expired` |
| wrong code | 422 `wrong_code` |
| right code as `974 878`, email `TESS@example.com` | 200 + resetToken |
| the same code again | 410 |
| complete with `short` | 422 `invalid_password` (token not used up) |
| complete | 200 Session |
| complete again | 410 `reset_expired` |
| old refresh token | **401** |
| old access token on `/me` | 200 in the first run; **401** after fix #4 (rebuilt and re-run: both pre-reset access tokens 401, new access 200, refreshed access 200, and after `DELETE /me` the access token 401) |
| new access `/me`, new refresh | 200, 200 |
| old password / new password | 401 / 200 |
| 4th request in an hour | 429 `too_many_requests` |
| 6 wrong codes | 4× `wrong_code`, then `too_many_attempts` ×2 |

## Findings not fixed (not reset-owned, or design choices)

1. FIXED (#4): old access tokens after a reset, a Google link or a deletion request. What remains:
   - With more than one server instance, another instance may accept a revoked access token for up to 30 s (its cache TTL). This is documented in `server/AGENTS.md` §7 and in the openapi `bearer` scheme.
   - Plain log-out (`/auth/log-out`) ends one session only and leaves that device's access token valid until it expires (≤15 min). There is no "log out of all devices" route.
   - Tiny race: a refresh that rotates its session in the milliseconds between the reset's timestamp and its commit gets an access token newer than `tokens_valid_after`. Its session is deleted by the reset, so it lasts at most 15 min.
   - Access tokens issued before this deploy use the old format and are rejected once. The app refreshes on 401, so students don't notice.
2. FIXED (#4): tokens now carry the issue time in microseconds, so they differ below a second.
3. Low: outstanding reset tokens from earlier verifies are not revoked by a later completed reset. Each is still good for 15 min. Anyone holding one could already reset, so this is low value. `CompleteReset` could mark every row of the account complete.
4. Low: two perfectly concurrent requests can leave two unused codes. After the newer one is used, the older one becomes claimable (5 more guesses). This is negligible.
5. Deployment: `ACADEME_CLIENT_IP_HEADER` must be set behind Railway (see the checklist), and `ACADEME_EMAIL_DEV` must never be `1` in production.

## Definitions of done

- Server (re-run after fix #4):
  - `gofmt -l .` empty and `go vet ./...` clean.
  - `go test -race ./...` with Postgres: all green.
  - `govulncheck`: 0 vulnerabilities in called code.
  - `golangci-lint run`: 0 issues in auth and postgres. One gosec G304 in `internal/lessons/lessons_test.go:247`, which belongs to another workstream and appeared mid-run.
- App: `dart format` 0 changed in the reset files. Reset widget and repository tests: 25 passed. `flutter analyze`: 3 infos, all `unawaited_futures` in `test/ui/paywall/paywall_test.dart` (paywall workstream, mid-change). Full `flutter test`: 151 pass, 1 fail, `paywall_test.dart` "ASKMe over the limit opens the sheet" (the same paywall workstream, not reset).
- AGENTS.md in the reset files: no comments, no widget-returning methods, no hex/`Colors.*`, every file under 300 lines (largest: `reset_code_screen.dart`, 170). The files use `AppColors.primary` / `AppColors.error` for brand and error ink, the same as the existing log-in and sign-up screens (under `_Light`). Everything else goes through `context.palette`.

## Files

- Changed:
  - `server/internal/auth/limiter.go`
  - `reset.go`
  - `reset_store.go`
  - `handler.go` (`clientIP`)
  - `auth.go` (`Store` interface, `Service.revoked`, revoke on link and deletion, `tokens()`)
  - `store.go` (`TokensValidAfter`, `LinkGoogle` and `ScheduleDeletion` set `tokens_valid_after`)
  - `token.go` (issued-at in µs)
  - `middleware.go`
  - the tests and fakes: `reset_test.go`, `reset_store_test.go`, `store_test.go`, `token_test.go`, `fake_store_test.go`, `fake_reset_store_test.go`
  - `server/openapi.yaml`: the `bearer` scheme now documents the 401 conditions and the 30 s delay; the `complete` summary is updated
  - `server/AGENTS.md` §7
- Added:
  - `server/internal/auth/limiter_test.go`
  - `reset_race_test.go`
  - `revoke.go`
  - `revoke_test.go`
  - `server/internal/postgres/migrations/0020_token_revocation.sql`
