# UI tests (integration_test on the Pixel 10)

Automated journeys live under `integration_test/`. The runner is
`tool/ui_test.sh` (Pixel 10 / `emulator-5554` by default).

## How to re-run the whole flow

```bash
# Local Postgres + stub AI (no Google/Sarvam token spend):
cd academe
./tool/ui_test.sh

# One journey:
./tool/ui_test.sh update_banner
./tool/ui_test.sh onboarding auth askme

# Against a live API (costs real AI credits for askme/scan):
UI_TEST_LIVE_API=1 API_BASE_URL=https://api.academe.cc ./tool/ui_test.sh auth
```

Local runs start `academe-api` on `:8099` with:

- `ACADEME_AI_PROVIDER=stub` and `ACADEME_TEST_MODE=1` (deterministic replies)
- Soft-update: `update_banner` journey sets `ACADEME_RECOMMENDED_BUILD=999`
  unless you override `UI_TEST_RECOMMENDED_BUILD`

Artifacts: `build/ui-test/<journey>/` (logs, screenshots, screenrecords).

## Current pass/fail (Codex ACADEMe GPT pass, 2026-11-09)

| Journey | File | Last result | Notes |
|---|---|---|---|
| Soft update banner appear + dismiss | `update_banner_test.dart` | PASS | Local stub API; recommended &gt; build |
| Welcome → email sign-up → setup → Home | `onboarding_test.dart` | PASS | |
| Log out and log in again | `auth_test.dart` | PASS | |
| Appearance dark and light | `appearance_test.dart` | PASS | |
| ASKMe question and reply | `askme_test.dart` | PASS | Stub AI locally |
| Me: settings screens | `me_settings_test.dart` | PASS | |
| Study: cards, quiz, keep, finish | `study_test.dart` | PASS | |
| Revision queue | `revision_test.dart` | PASS | |
| Folders: date, chapters, Today | `folders_test.dart` | PASS | |
| Courses catalogue | `courses_test.dart` | PASS | |
| Privacy / terms links | `privacy_test.dart` | PASS | |
| Notifications allow / deny | `notifications_*.dart` | PASS | |
| Password reset | `password_reset_test.dart` | PASS | Code from local server log |
| Account change password | `account_password_test.dart` | PASS | |
| Reset deep link | `deeplink_reset_test.dart` | PASS | |
| Free-limit / paywall copy | `limits_test.dart` / `pro_test.dart` | BLOCKED | Outdated paywall strings |
| Test Store purchase | `pro_purchase_test.dart` | BLOCKED | Needs RevenueCat test key |
| Scan Solve / Check / Notes | `scan_*.dart` | BLOCKED | Android 37 photo-picker selector |

Findings: `tasks/reports/ui-test-findings.md`. Requests: `ui-test-requests.md`.
