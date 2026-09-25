# Account settings (Me → Account)

## What was built

### Server (`server/internal/auth`)

| Route | What it does |
|---|---|
| `GET /me` | Additive fields: `hasPassword` (bool) and `googleEmail` (absent when Google isn't linked). Every other response that carries an `Account` (sign-up, log-in, Google, reset, `PATCH /me`) now carries them too, so the app's cached account is always right. |
| `POST /me/password` | `{currentPassword?, newPassword}`. Verifies the current password with argon2id (skipped for a Google-only account, which lets it set a first password and use email log-in). New password follows the sign-up rules (8–128). In one transaction it sets the hash, moves `tokens_valid_after` and deletes every session; the local revocation cache is updated at once. Returns a fresh `Session` so this device keeps working. `403 wrong_password`, `422 invalid_password`, `429 too_many_requests`. |
| `POST /me/google` | `{idToken}`. Verifies the Google ID token and links it to the logged-in account, **keeping the password and sessions**. `409 google_taken` when that Google account belongs to another account, `401 invalid_google_token`, `503 google_unavailable`. |
| `DELETE /me/google` | Unlinks Google. Only when a password exists, otherwise `409 password_required`. |

- New files: `settings.go` (service), `settings_store.go` (SQL), `settings_handler.go` (handlers). Routes and error codes are in `handler.go`, and `openapi.yaml` is updated.
- Migration `0021_google_email.sql`: adds `accounts.google_email`, backfilled from `email` for accounts that are already linked.
- The existing `LinkGoogle` store method (the automatic link on `/auth/google` sign-in by matching email) now also stores `google_email`. It still clears the password and revokes sessions, because that path runs **without** proof of the existing account. That's why settings linking uses a new route: the existing flow can't be reused for a logged-in student. Calling `/auth/google` from settings would wipe the password when the emails match, or create a second account when they don't.
- Rate limit: the auth `limiter` allows 5 current-password checks per account per hour (`passwordChecksPerHour`). Every check counts, not just wrong ones, because counting only wrong attempts would need the limiter to report its state without recording a hit. A student changing their password normally uses one or two.
- Change password is compare-and-swap (`WHERE COALESCE(password_hash,'') = old`), so a concurrent change or reset can't be silently overwritten.

### App

- `Account` has `hasPassword` (default `true` for older cached sessions; `restoreSession` refreshes it from `GET /me` on launch) and `googleEmail`, and the session store keeps both.
- `AuthRepository`: `changePassword`, `linkGoogle` (Google picker → `POST /me/google`), `unlinkGoogle` (and signs the Google picker out). `changePassword` stores the fresh tokens from the response. New `AuthFailure`s: `wrongPassword`, `googleTaken`, `passwordRequired`, each with its message.
- `MeViewModel`: commands `changePassword`, `linkGoogle`, `unlinkGoogle`; getters `hasPassword`, `googleEmail`, `isPro` (from an optional `BillingRepository`, which the router now passes in).
- `lib/ui/me/widgets/sign_in_group.dart`: the Sign-in rows. Email; **Change password** or **Set a password** for a Google-only account; **Link Google / Not linked**, or **Google / <google email>** when linked. Tapping a linked row opens `unlink_google_sheet.dart` (Keep Google / Unlink). A Google-only account is told to set a password first. Rows show Linking… / Unlinking… while running, and a closed Google picker shows nothing.
- `lib/ui/me/widgets/password_screen.dart`: current password (only when one exists) plus new password, with the sign-up 8+ indicator and a keycap Save password button. On success it pops back, and the Account screen shows a snackbar. Errors show as a snackbar and the screen stays open.
- `delete_account_screen.dart`: a **Subscription** group with a notice that deleting the account doesn't cancel an ACADEMe Pro subscription bought on Google Play. It's always shown; for a Pro student it adds **Manage subscription**, which opens `https://play.google.com/store/account/subscriptions?package=com.academe.flutter`. Pro state comes from `BillingRepository.isPro` (the billing workstream's API, already in `lib/`).
- `SettingsRow` values are now one line with an ellipsis, capped at 200 wide, so a long Google or account email can't overflow the row.
- `account_screen.dart` no longer has any "coming soon".

## "Coming soon" left in `lib/`

Built (Me/Account): Change password and Linking Google in `account_screen.dart`, both removed.

Left as is:
- `lib/ui/me/widgets/language_sheet.dart:180` "More languages coming soon". This is a caption in the Me language picker, not a stub action; the 5 launch languages all work.
- `lib/ui/home/widgets/home_screen.dart:154,168,175,182`: ASKMe, Homework help, Answer checking, Flashcards.
- `lib/ui/shell/widgets/app_shell.dart:148` (ASKMe attach-sheet options other than camera and photos) and `:268` (Flashcards from ASKMe).
- `lib/ui/home/widgets/setup/board_step.dart:46`: "State boards are coming soon."
- `lib/ui/study/widgets/courses_view.dart:133,137,138`, `chapter_screen.dart:125` and `planned_lesson_row.dart:54`: lesson and chapter availability labels.

## Tests

- Server: `settings_test.go` (handler, via httptest and the real mux) covers change password (rules, wrong or missing current password, the old token and other devices' access and refresh tokens revoked, the fresh token works, old password refused, new one works), throttling after 5 checks, setting a password on a Google account (then email log-in works, and Google sign-in keeps the password), link and unlink (forged token, google_taken, the password and token kept after linking, password_required, no token), and Google not configured. `settings_store_test.go` runs against real Postgres and covers PasswordHash, ChangePassword (stale hash refused, sessions deleted, tokens_valid_after set), AddGoogle/RemoveGoogle, and the new Account fields. The existing handler, store and fake tests were updated.
- App: `test/ui/me/account_settings_test.dart` has widget tests for each state: an email account (link Google), google_taken, a closed picker, linked with a password (the unlink sheet, both Keep and Unlink), Google-only (Set a password, unlink refused), the password screen (disabled until valid, success pops with a message, wrong current password stays, a Google-only account sets one with no current field), and the delete notice for free and Pro students. `test/data/repositories/auth_account_settings_test.dart` covers the repository: fresh tokens stored, request bodies, a 403 not retried as a refresh, link, unlink, error mapping, and the Google sign-out. `me_view_model_test.dart` has the new commands and isPro. The existing delete test now scrolls to the confirm field.
- DoD: `gofmt`, `go vet` and `govulncheck` are clean, and `go test -race ./internal/auth` is green. `golangci-lint` and `go test ./...` only fail in `internal/billing` (`revenuecat.go` gofmt and `TestWebhookEvents`), which the billing agent is changing right now; they're not from this work. App: `dart format` is clean on the touched files, `flutter analyze` reports no issues, and all of `flutter test` passes.

## Needs the user

- Nothing new. Linking Google needs the same `ACADEME_GOOGLE_CLIENT_IDS` and `GOOGLE_SERVER_CLIENT_ID` as Google sign-in; without them the row says Google isn't ready yet.

## Known limits and future work

- The revocation cache is per instance, so other instances may accept an old access token for up to 30 s (as for reset and deletion).
- Signing in with Google on the log-in screen with a Google account that has the same email as an unlinked password account still links automatically and clears the password (existing pre-hijack defence). The student can set one again from Account.
- The password check counts all attempts, not only wrong ones (see above). A per-IP limit isn't needed because the route needs a valid access token.
- There's no email notice to the student when their password changes or Google is linked. Worth adding through the Resend mailer.
- The Account screen trusts the account cached at launch. If another device links Google mid-session, this device shows it after the next launch.
