# Legal and privacy naming (confirmed in repo)

Use this when filling Play Console, Data safety, and `server/internal/site/pages/*.html`.

## Product naming (do not change without a store update)

| Field | Value |
|-------|--------|
| Public name | ACADEMe |
| Android package | `com.academe.flutter` |
| Play listing id | `com.academe.flutter` (same applicationId) |
| Support email | `support@academe.cc` |
| Policy host | `https://api.academe.cc` (not `www.academe.cc` for in-app or Play URLs) |

## URLs the app and Play must use

| Purpose | URL |
|---------|-----|
| Privacy policy | https://api.academe.cc/privacy |
| Terms | https://api.academe.cc/terms |
| Delete account (web) | https://api.academe.cc/delete-account |
| Support / Grievance Officer | https://api.academe.cc/support (#grievance) |

In-app sources: `lib/config/links.dart`, `lib/ui/me/widgets/privacy_screen.dart`, Paywall small print (`Routes` / hosting docs).

## Data fiduciary placeholders (still need you)

These strings must be filled in `server/internal/site/pages/*.html` before production deploy. Until then, pages show highlighted `[[FILL: …]]` spans.

| Placeholder | Files |
|-------------|--------|
| Legal name of developer or company | `privacy.html`, `layout.html` |
| Registered address, India | `privacy.html` |
| Grievance Officer name | `support.html` |
| Grievance Officer postal address | `support.html` |
| Court city (jurisdiction) | `terms.html` |
| Sarvam Document AI retention | `privacy.html` |

Check locally:

```bash
grep -rn 'FILL:' academe/server/internal/site/pages
```

Must print nothing before launch (`docs/play/release-checklist.md` step A1).

## Lawyer review

Still required for `docs/play/dpdp.md` (see `tasks/reports/legal-play.md`). Filling placeholders is not a substitute for legal review.
