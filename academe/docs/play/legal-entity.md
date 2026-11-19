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

## Data fiduciary (filled for site pages)

| Field | Value |
|-------|--------|
| Legal / public operator name | ACADEMe |
| Registered / contact address | Hyderabad, Telangana, India |
| Grievance Officer (published title) | ACADEMe Grievance Officer |
| Grievance Officer email | support@academe.cc (subject: Grievance) |
| Grievance Officer postal address | Hyderabad, Telangana, India |
| Court jurisdiction | Hyderabad, Telangana |
| Scan / Document AI retention | Online Document AI: processed in memory, not persisted to disk; not used to train Document AI models; Google Cloud ToS + DPA; region asia-south1 |

**Note:** DPDP expects a published grievance contact. We publish a role title plus email and Hyderabad address. Replace the officer **name** with a real India-based individual when you appoint one. Lawyer review of `docs/play/dpdp.md` is still recommended before a large production push.

Check locally:

```bash
./tool/check_legal_placeholders.sh
```

Must print nothing before launch (`docs/play/release-checklist.md` step A1).

## Lawyer review

Still required for `docs/play/dpdp.md` (see `tasks/reports/legal-play.md`). Filling placeholders is not a substitute for legal review.
