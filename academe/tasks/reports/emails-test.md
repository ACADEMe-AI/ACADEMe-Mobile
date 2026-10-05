# Emails, reset link and web reset page: test report

I checked the work in `emails.md` on my own server build (port 8102, throwaway schema `emailtest8102`, dropped afterwards), with headless Chrome driven over CDP, Postgres race tests, and the unit suites. I didn't use the emulator. The Pixel 10 checks are in `ui-test-requests.md`.

## Bugs found and fixed

1. **The web reset page broke on any plain-http host other than localhost.** The page always set a `__Host-` cookie, and a `__Host-` cookie must be `Secure`. Chrome only keeps a Secure cookie on http for `localhost`. On the emulator (`http://10.0.2.2:…`) or a LAN IP, Chrome dropped the cookie (CDP showed `blockedReasons: InvalidPrefix`). Every save then answered 403 with the misleading "Open the link again" page. I reproduced this with headless Chrome against `http://192.168.29.2:8102`.
   - **Fix** (`server/internal/site/reset.go`): the cookie now depends on the request scheme. Over TLS, or with `X-Forwarded-Proto: https` (Railway sets it), it stays `__Host-academe-reset` (Secure, HttpOnly, SameSite=Strict, Path=/). Over plain http it becomes `academe-reset` (HttpOnly, SameSite=Strict, no Secure). The POST reads the cookie for its own scheme, so an http cookie is refused over https.
   - Retested in Chrome over the LAN IP: the form saved ("Password changed"), the same link then showed "This link has expired", the new password logged in and the old one got 401.
   - **Test:** `TestResetPageOverPlainHTTP`. The existing tests now send `X-Forwarded-Proto: https` and check the exact `__Host-academe-reset` name.
2. **The reset page accepted any string as the link.** Crafted `c=` values were escaped correctly (see below), but they still got a form, a cookie and an `academe://` link.
   - **Fix:** `validLink` now only accepts base64url with 1 to 64 characters, which is what the server issues. Anything else gets the 400 "Open the link again" page with no cookie.
   - **Test:** extended `TestResetPageShowsTheForm` with script markup, `javascript:`, an injected `&next=` parameter and a 65-character value.
3. **The Android `academe://` intent filter accepted every host.** It now lists only the `reset` and `open` hosts, which are the only ones the site and emails use (`AndroidManifest.xml`, two `<data>` lines).

## Tests added (no bug found)

- `TestResetCodeAndLinkRacePostgres` in `internal/auth/reset_race_test.go`. Over 20 rounds against Postgres, the 6-digit code and the link from the same email are redeemed in parallel. Each round, exactly one gets a reset token and the other gets an expired error. It passed with `-race -count=3`.
- `TestWelcomeEmailNeverBlocksSignUp` uses a mail provider that never answers, under `synctest`. Sign-up returns at fake time 0, and `Service.Wait()` returns at exactly the 30 s send timeout.
- `TestResendWelcomeEscapesTheName` now also covers `<script>alert("x")</script>' "`. The HTML has `&lt;script&gt;…&#34;…&#39;` and no `<script`.
- `test/routing/deep_links_test.dart` adds real cold-start routes, `/reset-password?c=…` and `/?c=…`, which are the strings Flutter's Android embedding actually passes. The old tests used `https://…` as the initial route, which Flutter never passes.
  - Flutter builds `[splash, New password]` for these routes.
  - After 5 s New password is still on top, because the covered splash's ticker is paused.
  - Back pops to the splash, which then goes to Welcome.

## Security review

| Check | Result |
|---|---|
| Token entropy | 16 bytes from `crypto/rand`, 22 base64url characters (128 bits). Unguessable, and guesses are also limited per IP. |
| Storage | Only the SHA-256 is stored (`link_hash bytea UNIQUE`). Unsalted is fine for a random 128-bit value. The Postgres test confirms the raw token is never stored. |
| GET doesn't consume | `resetForm` never calls the store. Two GETs returned 200, then `/auth/password-reset/link` still gave 200. |
| Reuse | `/auth/password-reset/link` gave 200 then 410 `reset_expired`. A reused link on the web page gave 410 "This link has expired". |
| Attempts shared with the code | The link claim does `attempts = attempts + 1` on the same row. After 5 wrong codes the link gives 429 `too_many_attempts`, and using the link kills the code (410). Covered by the existing tests and the Postgres store test. |
| Code vs link race | Exactly one winner, since `MarkResetCodeUsed … WHERE used_at IS NULL` is the atomic gate. New Postgres test above. |
| `/auth/password-reset/link` limits | Shares the 30-per-IP-per-hour verify limiter. Empty or over-long tokens give 410 without a DB hit. The client IP comes from `TrustClientIP`, so it's the real client behind Railway. |
| Form token | `HMAC-SHA256(token key, "reset-form\0" + nonce + "\0" + link)`, compared with `hmac.Equal`. It is bound to both the cookie nonce and the link. Moving a token to another link or another cookie gives 403. |
| CSRF | The SameSite=Strict cookie and the HMAC form token are required. A cross-site POST has no cookie, so it gets 403. CSRF gains an attacker little here anyway, because they would need the link token, and with it they could reset directly. |
| Weak or mismatched password | 422, and the link is not used (checked before redemption). |
| XSS through `c=` | `html/template` escapes the value in the hidden input (attribute escaping) and in `academe://reset?c=` (query escaping). The `academe:` scheme is literal in the template, so `javascript:` can't reach the scheme. It was also safe with CRLF, quotes and `"><script>`. Now these values are rejected with 400 anyway. |
| Open redirect | `/open` takes no parameters and its intent link and Play link are constants. There is no redirect anywhere in `site`. |
| Headers | `Cache-Control: no-store`, `Referrer-Policy: no-referrer` (the link stays out of Referer), `nosniff`, and a strict CSP with no scripts, `form-action 'self'` and `frame-ancestors 'none'`. |
| Email name escaping | The HTML part is escaped by `html/template`, including in `<title>`. The subject has control characters stripped. The text part is plain text. |

**`assetlinks.json`**: this matches Google's format at developer.android.com/training/app-links/configure-assetlinks:
- a top-level array with `relation: ["delegate_permission/common.handle_all_urls"]`, `target.namespace: "android_app"`, `package_name` and `sha256_cert_fingerprints` (uppercase colon hex, checked at start-up);
- `Content-Type: application/json`, served from `/.well-known/`, with no redirect.

The manifest uses `autoVerify` only on the https filter, whose host is `academe.cc` and whose path is exactly `/reset-password`.

## Email rendering

- I regenerated the previews in `server/content-review/emails/` and screenshotted `reset`, `google`, `welcome` and `deletion` at 600 px, 390 px and 390 px dark.
  - None of them scroll horizontally.
  - At 390 px the six code boxes fit on one row.
  - The dark mode colours match `AppPalette.dark`: card `#171726`, edge `#45476F`, lavender `#2F2D63`, amber `#4A3B12`/`#FFC14D`, text `#F2F3F8`/`#A3A6C4`.
- **Theme:** the light colours match `app_theme.dart`: primary `#564CF1`, keycap edge `#12141A`, background `#F6F7FA`, text `#12141A`/`#5C6578`, tints `#E7E6FF` and `#FFE7A3`/`#8A6100`. The keycap button and card have a 2 px border and a thick bottom edge, as in the app.
- **Contrast (approximate):**

  | Text | Background | Ratio |
  |---|---|---|
  | Muted text `#5C6578` | White | about 5.9:1 |
  | Muted text `#5C6578` | Page `#F6F7FA` | about 5.5:1 |
  | White | Primary `#564CF1` | about 6:1 |
  | Amber ink `#8A6100` | Amber tint `#FFE7A3` | about 4.9:1 |

  All pass AA.
- **Button:** a real `<a href>` (`https://academe.cc/reset-password?c=…`, `/open`, or a mailto for deletion). Outlook gets a VML roundrect with the same escaped href.
- **Plain text:** every email has a text part with the full URL, the code and the footer.
- **Pitfalls:** no `<script>`, `<form>`/`<input>`, `<link>` or `@import`, and no `data:` images. The only `<style>` block is in the head: font faces, a mobile media query and dark overrides. Inline styles carry the layout, so clients that strip `<style>` still render it. The layout tables have `width`. The tables without it are intentional shrink-wrap tables (logo row, pill, digit boxes, and the button table inside the non-Outlook branch). The digit cells have `width`/`height` attributes.
- **Names:** there are no names of other apps or sites in the templates, pages or previews.
- **Assets:** every image and font URL in the rendered emails is `https://academe.cc/email/<file>`. Each preview's rewritten file path exists in `internal/site/email/`. On my server:

  | Asset | Content-Type |
  |---|---|
  | `logo.png`, `pebby-shy.png`, `pebby-wave.png` | `image/png` |
  | `archivo-700.ttf`, `baloo2-800.ttf`, `wordmark-500.ttf`, `wordmark-600.ttf` | `font/ttf` |

  All seven files return 200 with `Cache-Control: public, max-age=604800`, `Access-Control-Allow-Origin: *` and `nosniff`. A missing file gives 404, `/email/` gives 404 and traversal gives 400.

## Welcome email

- It is sent through `Service.background.Go` with `context.WithoutCancel` plus a 30 s timeout. A failure is logged as Warn and never reaches the sign-up response. The new test proves a hung provider doesn't delay sign-up.
- In `main`, `defer authService.Wait()` is registered after `defer pool.Close()`, so shutdown runs `srv.Shutdown`, then waits for the sends in flight, then closes the pool.

## App deep links

- `resetLinkToken` accepts `https://academe.cc/reset-password?c=`, `/reset-password?c=`, `academe://reset?c=` and `/?c=`. It rejects other hosts, missing or empty `c`, `/open` and `academe://open`.
- While the app runs, `DeepLinkFilter` is registered before `runApp`, so it runs before the app's own handler. It swallows everything except reset links.
- `emails.md` says a cold-start link opens New password as the only page and that Back closes the app. In fact Flutter puts the splash underneath, and Back plays the splash and then shows Welcome or Home. That is better behaviour, and it's now tested.
- The two deep-link tests the brief called failing already passed when I started. The whole file (7 tests) passes.

## Checks

- **Server:**
  - `gofmt -l .` is empty.
  - `go vet ./...` is clean.
  - `go test -race ./...` with Postgres passes in every package.
  - `govulncheck` finds 0 called vulnerabilities (1 in a required module that isn't called).
  - `golangci-lint` reports 1 issue, gocritic `argOrder` in `internal/lessons/deck.go:94`. It isn't in this workstream's files, so I left it to its owner.
- **App:** `dart format` changed nothing, `flutter analyze` finds no issues, and the full `flutter test` passes 192 tests.

## Files changed

- `server/internal/site/reset.go`: scheme-aware reset cookie, and base64url-only link validation.
- `server/internal/site/reset_test.go`: `X-Forwarded-Proto` helpers, the plain-http test, and the crafted-link cases.
- `server/internal/auth/reset_race_test.go`: the code-vs-link race.
- `server/internal/auth/reset_link_test.go`: the hanging mailer test.
- `server/internal/email/email_test.go`: script and quote escaping of the name.
- `server/openapi.yaml`: the GET `/reset-password` description now covers the http cookie.
- `android/app/src/main/AndroidManifest.xml`: `academe://` limited to the `reset` and `open` hosts.
- `test/routing/deep_links_test.dart`: the cold-start and back tests.

## Known limits and notes

- **Proxy header:** production depends on Railway sending `X-Forwarded-Proto: https`, which it does for every https request. If a deploy dropped that header, the page would use the plain cookie over https, which still works but without the `__Host-` guarantees.
- **Email fonts:**
  - `baloo2-800.ttf` is 421 KB. That's heavy for a font that is only loaded by clients that support `@font-face`; a subset (Latin, only the heading glyphs) would cut it to about 30 KB.
  - The font is cached for a week, and so is a 404 for an unknown name.
- **Bidi characters in subjects:** Unicode format characters such as RLO in a first name survive into the subject, because only control characters are stripped. Stripping all of category Cf would also remove ZWJ/ZWNJ, which Indic names need, so I left it.
- **Outlook for Windows:** `border-radius` and the thick bottom edge on the digit boxes don't render there, so the digits show in square boxes. That is acceptable.
