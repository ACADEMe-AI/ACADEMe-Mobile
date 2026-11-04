# UI tests (integration_test on the Pixel 10)

Status: in progress. The table is updated after every pass.

## Current pass/fail

| Journey | File | Last result | Notes |
|---|---|---|---|
| Welcome → email sign-up → setup (English, birth year, Class 10, CBSE) → Home | `onboarding_test.dart` | PASS (64 s) | |
| Log out and log in again | `auth_test.dart` | PASS (157 s) | |
| Appearance dark and light | `appearance_test.dart` | fixed, re-running | test checked the wrong colour; now checks `AppPalette.isDark` |
| ASKMe real question and reply | `askme_test.dart` | PASS (98 s) | F1 (Sarvam empty reply) fixed on the server |
| Me: every settings screen opens | `me_settings_test.dart` | fixed, re-running | section titles are upper case; test used the wrong marker |
| Study: lesson through every card type, quiz right and wrong, keep, finish, chapter test | `study_test.dart` | PASS (167 s) | |
| Revision queue (empty, then kept and missed cards) | `revision_test.dart` | fixed, re-running | test helper bug |
| Folders: date, chapters, to-dos, tick, Home Today | `folders_test.dart` | fixed, re-running | F2, Add chapters default subject |
| Scan: Solve homework from gallery → read → ASKMe | `scan_solve_test.dart` | BLOCKED (Sarvam credits) | picker tap fixed; needs Sarvam |
| Scan: Check my answer → marks | `scan_check_test.dart` | BLOCKED (Sarvam credits) | |
| Scan: notes → folder → swipe lesson | `scan_notes_test.dart` | fixed, re-running (Sarvam) | |
| Courses: "Coming soon" chapters and lessons | `courses_test.dart` | PASS (101 s) | |
| Privacy and terms links open the browser | `privacy_test.dart` | PASS (131 s) | 4 links open Chrome |
| Notifications: primer → OS Allow → Me shows Allowed | `notifications_allow_test.dart` | PASS (81 s) | |
| Notifications: primer → OS Don't allow → Turn on in Settings → granted → Allowed on resume | `notifications_deny_test.dart` | fixed, re-running | test hung while the app was in the background |
| Password reset with the code from the server log | `password_reset_test.dart` | new, running | |
| Account: change password | `account_password_test.dart` | new, running | |
| Reset deep link `academe://reset?c=` over Home, then expired link | `deeplink_reset_test.dart` | new, running | |
| Paywall without billing, ASKMe free-limit sheet | `limits_test.dart` | new, running | own server on :8099 with `askme=2` |
| Test Store purchase, Pro card, Restore | `pro_purchase_test.dart` | new, running | |

Findings are in `tasks/reports/ui-test-findings.md`.
