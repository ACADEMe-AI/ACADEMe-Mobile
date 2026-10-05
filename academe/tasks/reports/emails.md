# Emails: themed templates, reset link, web reset page

## What you need to do first: verify academe.cc in Resend

Until the domain is verified, Resend refuses every send with 403. No real emails were sent while building this.

1. Go to resend.com → **Domains → Add domain** and enter `academe.cc`. Pick the region nearest India.
2. Resend then lists some DNS records. Add each one at **Namecheap → Domain List → academe.cc → Advanced DNS**, copying the host and value exactly:
   - **MX** on the `send` subdomain (host `send`), pointing at the feedback server Resend shows (for example `feedback-smtp.<region>.amazonses.com`, priority 10).
   - **TXT** on the `send` subdomain (host `send`): `v=spf1 include:amazonses.com ~all`.
   - **TXT** DKIM record, host `resend._domainkey`, with the long `p=…` public key Resend gives you.
   - Optional but recommended: a **DMARC** TXT record, host `_dmarc`, value `v=DMARC1; p=none; rua=mailto:support@academe.cc`. Tighten it to `p=quarantine` once mail is flowing.
3. Back in Resend, click **Verify DNS records** and wait until the domain shows **Verified**. Namecheap usually takes minutes, sometimes up to an hour.
4. Go to **API Keys → Create API key** with *Sending access* limited to `academe.cc`, and set `ACADEME_RESEND_API_KEY=re_…` on Railway. `ACADEME_EMAIL_FROM` is optional; the default is `ACADEME <no-reply@academe.cc>`.
5. `academe.cc` must point at the Railway service (see `hosting.md`), because email images, fonts and the Reset password / Open ACADEMe buttons are served from `https://academe.cc`.
6. For Android App Links: when the release keystore exists, set `ACADEME_ANDROID_CERT_SHA256` to its SHA-256 fingerprint. If you use Play App Signing, also add the **app signing key** fingerprint from Play Console → Setup → App signing. Separate the two with a comma, like `AB:CD:…:EF,12:34:…:56`. Until then, `/.well-known/assetlinks.json` returns 404 and Android opens reset links in the browser (the web page works fine on its own).

## What was built

### Email templates (`server/internal/email`)

- `templates/layout.html` is the shared `html/template` layout:
  - Table-based and inline-styled, 600 px wide at most, with 16 px gutters. Below 520 px it switches to tighter padding and smaller digit boxes.
  - `color-scheme` and `supported-color-schemes` metas, plus dark-mode overrides for Apple Mail and iOS Mail (`prefers-color-scheme`) and for Outlook.com (`[data-ogsc]`).
  - It is never pure white text on a light background. White appears only on the purple button.
  - A hidden preheader with filler, so mail apps don't pull body text into the preview line.
  - The ACADEMe cube logo sits next to the ACADEMe wordmark. In dark mode the logo gets a light tile so the cube's dark faces stay visible.
  - A rounded keycap card: 2 px `#12141A` border and a 6 px bottom edge. At the top is a lavender band with Pebby.
  - The footer has "why you got this email", support@academe.cc, and "ACADEMe · academe.cc".
  - No tracking pixels and no inline base64. All images come from `https://academe.cc/email/…`.
- Theme values come from `app_theme.dart`:
  - Colours: primary `#564CF1`, keycap edge `#12141A` (dark `#45476F`), amber tint `#FFE7A3` with ink `#8A6100`, lavender `#E7E6FF`, and the light and dark surfaces and text colours.
  - Fonts: headings use Baloo 2 800, subheads and buttons use Archivo 700, and the wordmark uses ArchivoWordmark. They load with `@font-face` from academe.cc, so Apple Mail and iOS show them. Where web fonts don't load (for example Gmail), text falls back to Arial Rounded, Trebuchet or Arial. Body text uses Noto Sans, then Segoe UI, Roboto or Arial.
- The button (`{{template "button"}}`) looks like the app's keycap: a purple face, a 2 px dark border and an 8 px dark bottom edge. Outlook on Windows gets a VML `v:roundrect` inside conditional comments instead. `html/template` strips HTML comments, so the conditional comments and the VML are built as `template.HTML` values in `email.go`, and the URL and label are HTML-escaped there.
- Every email has a matching plain-text part (`templates/*.txt`, `text/template`). Each HTML file's text twin is listed below:
  - **Reset** (`reset.html`/`.txt`): Pebby covering his eyes, "Reset your password", an amber "Expires in 15 minutes" pill, a big **Reset password** button linking to `https://academe.cc/reset-password?c=<link token>`, then "Already in the app? Type this code" with the 6 digits in themed keycap boxes. The subject is still `Your ACADEMe code is 123456`.
  - **Google-only** (`google.html`): "Continue with Google", explaining there's no password to reset, with an **Open ACADEMe** button linking to `https://academe.cc/open`.
  - **Welcome** (`welcome.html`): "Welcome to ACADEMe, Maya!" from Pebby, two short lines, and an **Open ACADEMe** button. The name is HTML-escaped, and control characters are stripped from the name before it goes into the subject.
  - **Deletion request** (`deletion.html`): themed version of the web deletion notice. Web deletion requests have nothing to undo, since nothing is scheduled until the person replies. So the button is **Contact support**, a `mailto:` link to support@academe.cc with the subject filled in. In-app deletion is undone by logging in, which the email explains.
- `resend.go` has one `send` used by `SendReset`, `SendWelcome` and `SendDeletionNotice`. Every email sets `reply_to: support@academe.cc`. `log.go` (used when no key is set) logs the account ID only. With `ACADEME_EMAIL_DEV=1` it also logs the code and the reset link. `notice.go` (plain-text notices) was removed.

### Reset link (server, `internal/auth`)

- Migration **`0022_reset_links.sql`** adds `password_reset_codes.link_hash bytea UNIQUE`. No number was assigned to this workstream; 0021 was taken by `0021_google_email.sql` mid-run, so I used 0022.
- `RequestPasswordReset` now makes a **link token** alongside the code: 16 bytes from `crypto/rand`, unpadded base64url (22 characters). Only its SHA-256 is stored, on the same row as the code, so it shares the code's 15-minute expiry, its 5 attempts, and being replaced by the next request.
- `reset_link.go`:
  - `RedeemResetLink` is rate limited by the same 30-per-IP-per-hour verify limiter. It then runs an atomic `UPDATE … attempts = attempts + 1 … RETURNING`, so a link counts as an attempt, and refuses when the attempts are used up or the link has expired. It marks the row used through the existing `MarkResetCodeUsed`, which makes it single-use and kills the code too, and returns a normal reset token.
  - `ResetWithLink` (the web page) checks the password first, so a weak password doesn't use up the link. It then redeems the link and calls `setPassword`, which is the same path `CompletePasswordReset` now uses. That path sets the hash, sets `tokens_valid_after`, deletes every session and updates the revocation cache. No session is created for the web.
  - `POST /auth/password-reset/link {linkToken}` → `{resetToken, expiresIn}`. Error codes: `reset_expired` 410, `too_many_attempts` 429, `too_many_requests` 429.
- Welcome email (`welcome.go`): sent after email sign-up and after a Google sign-in that creates an account. It runs on `Service.background` (`sync.WaitGroup.Go`) with a 30 s timeout, on a context that keeps the request's values but not its cancellation. `main` calls `defer authService.Wait()`, so shutdown waits for sends in flight. Failures are logged as Warn with the request ID and account ID. `Service.SetLogger` is set in `main`.
- `auth.ResetMailer` is renamed `auth.Mailer` and now has `SendWelcome` too.

### Web pages (`internal/site`)

- `GET /reset-password?c=…`:
  - Shows a themed form: new password and confirmation, a keycap **Save new password** button, and "Have ACADEMe on this phone? **Open in the app**" linking to `academe://reset?c=…`.
  - The GET never touches the database, so link scanners and prefetchers can't use up the link.
  - It sets `__Host-academe-reset`, a random nonce cookie: Secure, HttpOnly, SameSite=Strict, Path=/, 1 hour.
  - The form carries `t = HMAC-SHA256(ACADEME_TOKEN_KEY, "reset-form" ‖ nonce ‖ link)`.
  - Responses send `Cache-Control: no-store` and `Referrer-Policy: no-referrer`.
- `POST /reset-password`:
  - Checks the cookie and the form token against the link (403 when they don't match).
  - If the two passwords differ it answers 422 without using the link. A weak password also gets 422.
  - Otherwise it calls `auth.Service.ResetWithLink`. Results: 200 "Password changed" (the cookie is cleared), 410 "This link has expired", 429 when throttled.
- `GET /open` has an **Open ACADEMe** keycap button: `intent://open#Intent;scheme=academe;package=com.academe.flutter;S.browser_fallback_url=<Play listing>;end`. It opens the app or falls back to the Play Store. There is also a **Get it on Google Play** button.
- `GET /email/{name}` serves the embedded email assets with a one-week cache and `Access-Control-Allow-Origin: *` for fonts:
  - `logo.png`: the cube, 96 px, shown at 40 px.
  - `pebby-wave.png` and `pebby-shy.png`: 264 px, cropped from `design/preview/poses-clear`.
  - Four font files: Baloo 2 800, Archivo 700 and the two ArchivoWordmark weights.
- `GET /.well-known/assetlinks.json` is built from `ACADEME_ANDROID_CERT_SHA256` (comma-separated, validated at start-up as 32 hex bytes) and returns 404 when that is unset.
- Site CSP gains `font-src 'self'`. Site `h1`s now use Baloo 2, and the layout gains `.keycap`, `.stack`, `.hero` and password inputs.
- `RegisterRoutes(mux, logger, site.Options{Store, Mailer, Resets, FormKey, AndroidCerts})`.
- The deletion confirmation now goes out through `SendDeletionNotice`, using the themed template.

### App

- `AndroidManifest.xml` has two new intent filters on `MainActivity`:
  - `https://academe.cc/reset-password` with `android:autoVerify="true"`.
  - The `academe` scheme, so `academe://reset?c=…` and the `/open` page's intent link reach the app.
- `lib/routing/deep_links.dart`:
  - `resetLinkToken(routeName)` reads `c` from `https://academe.cc/reset-password?c=`, `/reset-password?c=`, `academe://reset?c=` and `/?c=`. The last form is what Flutter pushes for `academe://reset` while the app is running.
  - `DeepLinkFilter` is a `WidgetsBindingObserver` registered in `main.dart`. While the app is running it swallows every other pushed link, such as `academe://open` or `/open`, so they don't push a second splash over the student's screen.
- `router.dart`: a reset link opens `NewPasswordPage` with `NewPasswordViewModel(linkToken: …)`. From a link, **Start again** replaces the page with Forgot password.
- `NewPasswordViewModel`:
  - Takes `resetToken` or `linkToken`. With a link token, Save first calls `AuthRepository.redeemResetLink`, keeps the reset token, then completes as before.
  - `too_many_attempts` now also shows "Start again".
- `AuthRepository.redeemResetLink` is implemented in `AuthRepositoryRemote`, `AuthApiService` and `FakeAuthRepository`. The fake's accepted link is `link-token`.

### openapi.yaml

Added `POST /auth/password-reset/link`, `GET`/`POST /reset-password`, `GET /open`, `GET /email/{name}` and `GET /.well-known/assetlinks.json`. The `/auth/password-reset` description now covers the link.

## Previews

- `ACADEME_EMAIL_PREVIEW=server/content-review/emails go test ./internal/email -run TestWritePreviews` writes `reset`, `google`, `welcome` and `deletion` `.html` and `.txt` files. The directory is git-ignored, and asset URLs point at the local copies.
- I rendered them with headless Chrome at 800 px, 390 px, and 390 px in dark mode, and checked the look, the mobile wrap of the code boxes, and dark-mode contrast. I also checked the web reset, open and broken-link pages served by my own build.

## How it was tested

- `internal/email` tests, all against an `httptest` Resend fake that decodes with `DisallowUnknownFields`:
  - the exact envelope: from, to, `reply_to`, subject;
  - the button URL with the link token, the digits, the VML fallback and the amber pill;
  - the Google-only email has no code and no reset link;
  - the welcome name is escaped in HTML and stripped of control characters in the subject;
  - the deletion email has the mailto button;
  - every email shares the layout: color-scheme meta, logo URL, Outlook conditionals, 600 px, reason, support and footer, with no `data:image`, `<script`, `{{` or `ZgotmplZ`;
  - a Resend 403 surfaces as an error;
  - the Log sender reveals the code and link only in dev.
- `internal/auth`, with fakes plus Postgres:
  - the link flow: 16-byte token, redeem, single use, the code dies with it, complete works, old sessions are revoked;
  - rejects: unknown, empty, over-long, replaced by a newer email, and code burned by 5 wrong guesses (429);
  - expiry after 15 minutes and the per-IP throttle, both with synctest;
  - `ResetWithLink`: a weak password doesn't use the link, success revokes sessions, a second use is refused;
  - the welcome email is sent once for sign-up and once for a new Google account, and not for later log-ins;
  - a Postgres store test: the link attempt is shared with the code, used links are refused, only the SHA-256 is stored.
- `internal/site`:
  - GET form: cookie attributes, no-store, no-referrer, the Open in the app link, the link escaped, 400 without a link;
  - the POST table: no cookie, a cookie from another visit, a token for another link, a token moved to another link, mismatched passwords, too short, saved (cookie cleared), already used (410), throttled (429);
  - email assets (types, 404, traversal gives 400);
  - assetlinks (404 when unset, exact JSON, a bad fingerprint fails start-up);
  - `/open` renders the intent link.
- App:
  - `test/routing/deep_links_test.dart`: every link shape, the running-app filter, a cold-start https link redeeming and completing, an expired link going to Start again then Forgot password, and a link pushed while the app runs landing on New password;
  - a repository test for `redeemResetLink`, both success and 410.
- Server DoD:
  - `gofmt` clean, `go vet ./...` clean, `go test -race ./...` with Postgres all green, and `govulncheck` finds no called vulnerabilities.
  - `golangci-lint`: 1 issue, a gocritic finding in `internal/lessons/deck.go`, which belongs to another workstream.
- App DoD: `dart format` 0 changed, `flutter analyze` no issues, full `flutter test` 189 passed.
- Live, on my own build on :8098 with `ACADEME_EMAIL_DEV=1` in a throwaway schema (`emails8098`, dropped afterwards), with curl:
  - sign-up logs the welcome email;
  - a reset request logs the code and link;
  - GET page (200, cookie as designed);
  - POST without the cookie 403, mismatched passwords 422, correct 200, again 410;
  - old password 401, new password 200;
  - `/auth/password-reset/link` 200 then 410;
  - assetlinks JSON; logo `image/png`.
- Not run on the Pixel 10 (the UI-test agent owns the emulator). Please check there:
  - `adb shell am start -a android.intent.action.VIEW -d 'https://academe.cc/reset-password?c=<token>' com.academe.flutter`
  - `adb shell am start -a android.intent.action.VIEW -d 'academe://reset?c=<token>' com.academe.flutter`

## Known limits

- **Gmail** ignores `@font-face` and dark-mode media queries, so it shows the fallback fonts. The Gmail apps apply their own dark-mode colour inversion. The layout avoids white-on-light text, so inverted emails stay readable.
- **App Links are unverified** until `ACADEME_ANDROID_CERT_SHA256` is set and academe.cc is served by Railway. Until then, Android opens the reset link in the browser, where the web page works, and the page offers "Open in the app".
- **Cold start**: a reset link opens New password as the only page, without the splash. Back from there closes the app, which is fine for a one-off task.
- **Opening the app from email while it's running**: `/open` and `academe://open` just bring ACADEMe to the front.
- **Old codes stay valid**: link tokens from before this deploy don't exist, so existing codes simply work as before.
- **Welcome email with more than one server**: the goroutine has an owner and a 30 s bound, but a crash (not a clean shutdown) loses a welcome email in flight. A durable outbox would fix that if it ever matters.
- **Web throttling**: the web form shares the in-memory reset limiter, which is per instance (see `password-reset.md`).
- **English only**: all emails and pages are in English.

## Future improvements

- Localised emails (hi, te, ta, bn) using the student's language, and Noto Sans web fonts for Indic scripts.
- A "your password was changed" notice after any reset.
- A signed "confirm deletion" link in the web deletion email, so deletion can be scheduled without a support reply.
- An iOS Universal Links `apple-app-site-association` file next to `assetlinks.json` when the iOS app ships.
- Send the reset email from the background group too, which removes the timing difference between known and unknown emails.
