# Account settings: test report

Tester: account-settings. I didn't use the emulator. I ran my own server on :8103, in its own Postgres schema, which I dropped afterwards.

## Verdict

The work holds up. I fixed one real bug in the app: the Manage subscription row didn't update when Pro state changed. I also added a server race test. No server bugs found.

## Checks

### Change password
- **Current password:** `checkPassword` hashes it with argon2id and compares using `subtle.ConstantTimeCompare`. A current password longer than 128 characters is refused before hashing, so a huge input can't be used to waste CPU.
- **Rate limit:** the `passwordCheck` limiter allows 5 checks per account per hour and counts every attempt. `TestChangePasswordThrottlesGuesses` covers it.
- **Google-only accounts:** a Google-only account has an empty hash. The current-password check is skipped and the compare-and-swap uses `COALESCE(password_hash,'') = ''`. `TestSetPasswordOnGoogleAccount` passes, and a later Google sign-in keeps the password because the account is found by its Google subject first.
- **Revocation:** in one transaction the server sets the new hash and `tokens_valid_after`, and deletes every session. The revocation cache is updated on this instance. Access tokens carry their issue time in microseconds, so the fresh token (issued at or after `validAfter`) is accepted and all older ones are refused.
- **The app's 403 handling:** `authorized()` only refreshes the token on a 401. A 403 `wrong_password` maps to `AuthFailure.wrongPassword`, and the repository test checks that it isn't retried.
- **Concurrent changes:** I added `TestChangePasswordRacesPostgres` to `settings_store_test.go`. It runs 5 parallel changes with the right current password against real Postgres. Exactly one succeeds, the other four get `ErrWrongPassword` from the compare-and-swap, and logging in with the winning password works. It passed 3 times with `-race`.

### Google link and unlink
- **Another account's Google:** the unique `google_subject` index turns this into `ErrGoogleTaken`, which returns 409 `google_taken`. The store test covers it.
- **Unlinking without a password:** a single `UPDATE … RETURNING` returns 409 `password_required` and leaves Google linked. I also checked this over curl.
- **Audience check:** linking goes through the same `GoogleVerifier` as sign-in. That checks the issuer, the audience (`slices.Contains(clientIDs, aud)`), expiry, `email_verified` and the RS256 signature.
- **Backfill:** `UPDATE accounts SET google_email = email WHERE google_subject IS NOT NULL` is correct. Google-created accounts got their email from Google, and auto-linked accounts were matched by email, and `PATCH /me` never changes the email. I checked it in a rolled-back transaction. The dev DB has no linked accounts yet.
- **GET /me:** `Account` has no hash field, only `hasPassword` and `googleEmail`. No response carries a hash, which I checked in the curl output.
- **Existing Google log-in:** `TestGoogleIDTokensVerify`, `TestGoogleSignIn`, `TestGoogleSignInLinksEmailAccount`, `TestGoogleSignInUnconfigured` and `TestGoogleLinkRevokesAccessTokens` all pass.

### Delete screen
- **Notice text:** Play's account deletion rules say that extra steps, such as cancelling a subscription, must be clearly stated. The notice says deleting the account doesn't cancel a Pro subscription bought on Google Play and tells the student to cancel it there. That's accurate: the server's subscriber delete removes the RevenueCat record but doesn't cancel the Play subscription.
- **Manage link:** it shows only when `isPro` is true. Tests cover both the free and the Pro case.

## Bug fixed

**The Manage subscription row went stale.** `MeViewModel.isPro` read `BillingRepository.isPro`, but the view model never listened to billing, and the delete screen only rebuilt when the delete command changed. If Pro loaded or was restored after the screen opened, the row never appeared. The screen also had its own copy of the Play URL, separate from the billing repository's.

- `lib/ui/me/view_models/me_view_model.dart`: the view model now subscribes to billing and unsubscribes on dispose. A new getter, `manageSubscriptionUrl`, returns `billing.manageUrl`, falling back to `BillingRepository.playSubscriptionsUrl`.
- `lib/ui/me/widgets/delete_account_screen.dart`: the screen now rebuilds from the view model. I removed its `manageSubscriptionUrl` constant; it now uses the view model's URL, which means RevenueCat's management URL when there is one.
- `test/ui/me/account_settings_test.dart`: new test "Manage subscription appears once Pro arrives", and the URL check now uses the view model.

## End-to-end run on :8103

| Step | Result |
|---|---|
| 1. Sign up | 200, `hasPassword: true`, no `googleEmail` |
| 2a. Change password with a wrong current password | 403 `wrong_password` |
| 2b. Change password with the right one | 200 with fresh tokens |
| 3a. Old access token on `GET /me` | 401 `invalid_token` |
| 3b. New access token on `GET /me` | 200 |
| 4a. Log in with the old password | 401 `wrong_credentials` |
| 4b. Log in with the new password | 200 |
| `POST /me/google` with Google not configured | 503 `google_unavailable` |
| Account made Google-only via SQL, then `DELETE /me/google` | 409 `password_required`; `GET /me` shows `hasPassword: false` and the `googleEmail` |
| Set a password with no current password | 200 |
| `DELETE /me/google` again | 200 |
| Log in with the new password | 200 |

## Definition of done

- **Server:**
  - `gofmt -l .` is empty and `go vet ./...` is clean.
  - `go test -race ./...` is green, with the database URL set.
  - `govulncheck` finds nothing our code reaches.
  - `golangci-lint run` reports 0 issues in `internal/auth`. The one issue in the whole repo is in `internal/lessons/deck.go:89` (gocritic `argOrder`), which belongs to another workstream.
- **App:** `dart format` is clean, `flutter analyze` finds no issues, and the full `flutter test` passes.
- **AGENTS.md:**
  - None of the settings files has a comment.
  - No methods return widgets.
  - Colours come only from `AppColors` or `context.palette`.
  - No `Opacity`.
  - All files are within 300 lines. `auth_repository_remote.dart` is exactly 300, so the next addition should move the `_authError` mapping out.

## Notes, no action needed

- **Brief race while the password changes:** if another request on the same device gets a 401 before the change-password response arrives, it tries to refresh with the old refresh token. That fails and clears the session, and `_start` then saves the new tokens again. The window is tiny and the Account screen is idle while saving.
- **Length counting differs:** the app counts password length in UTF-16 units and the server counts runes. An emoji-heavy password could pass the app's 8+ check and still get a 422, which the app shows as a message.
- **Lapsed subscriptions:** a student whose subscription is lapsed or on hold isn't `isPro`, so they get the notice without the Manage link. The notice still tells them to cancel in Google Play.
