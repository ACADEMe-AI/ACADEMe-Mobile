# App update policy (operator guide)

ACADEMe cannot install a new Android build without the student using **Google Play**. Remote update policy controls **when the app blocks or nags**, and the **API refuses old clients** so staying on an old APK (or sideloading one) does not keep working.

## What students experience

| Layer | Behavior |
|-------|----------|
| **Force** (`ACADEME_MIN_BUILD`) | After splash, a full-screen **Update required** screen. Only **Update on Google Play**: no tabs, no study. |
| **Soft** (`ACADEME_RECOMMENDED_BUILD`) | Dismissible banner on the home shell; **Update** opens Play. Dismissal is remembered until you raise `recommendedBuild` again. |
| **Server** | Authenticated and most API routes return **`403 upgrade_required`** when `X-App-Build` is below `minBuild`. Webhooks and public legal pages stay open. |

Reinstalling an old APK from elsewhere still hits the server gate. Uninstall is always possible on Android; force update means **old builds cannot use the product**, not that uninstall is disabled.

## Server variables

Set on the API service's deployment environment:

| Variable | Meaning |
|----------|---------|
| `ACADEME_MIN_BUILD` | Force update: block app when installed `versionCode` is **below** this. Use `0` to disable. |
| `ACADEME_RECOMMENDED_BUILD` | Soft update: show dismissible prompt when below this. Use `0` to disable. |
| `ACADEME_UPDATE_MESSAGE` | Short copy for both prompts (optional). |
| `ACADEME_UPDATE_URL` | Defaults to the Play listing for `com.academe.flutter`. |

Build numbers come from `pubspec.yaml` (`version: x.y.z+N` → **N** is `versionCode`). Release builds pass `--dart-define=APP_BUILD=N` (`tool/build_release_aab.sh` does this from `pubspec.yaml`).

## Choosing force vs soft

- **Force (`ACADEME_MIN_BUILD`):** Breaking API change, security fix, or broken build you must retire.
- **Soft (`ACADEME_RECOMMENDED_BUILD` only):** Improvements, copy, non-breaking features.

Typical rollout: ship new AAB to internal → production → raise `ACADEME_RECOMMENDED_BUILD` → after adoption, raise `ACADEME_MIN_BUILD` to drop old clients.

## Before production

Set update env vars when you ship a build students should move to (see `pubspec.yaml` version code). Until then, `0` means no force or soft prompts.

Design-only HTML mock (not in the app): `docs/play/feedback-updates-preview.html`. Shipped UI is in Flutter (`soft_update_banner.dart`, etc.).

## Feedback limits (same deploy)

`POST /me/feedback` is capped at **2 per account per IST day** and **5 per IST week** (Monday IST, same as billing). Stored in `account_feedback` (migration 0026). When `ACADEME_RESEND_API_KEY` is set, each submission also emails **support@academe.cc** with the student address on **Reply-To** (same Resend stack as reset/welcome).

## Implementation

- `GET /app/config`, env in `internal/config`, middleware in `internal/appconfig`
- Flutter: splash check, `UpdateRequiredScreen`, `SoftUpdateBanner`, `X-App-Build` on all API calls
- Spec: `tasks/spec-feedback-progress-app-updates.md`
