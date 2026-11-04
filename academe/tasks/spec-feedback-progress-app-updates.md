# Spec: In-app feedback, My Progress (Pro), and update policy

Status: **Implemented** (feedback, `GET /me/progress`, app config, client gates, tests).

## Assumptions (correct me before we build)

1. **Platform:** Android-first Flutter app (`com.academe.flutter`); server is Go `academe/server` on `api.academe.cc`.
2. **“Over-the-air updates”** means **remote update policy** (minimum / recommended build, force vs soft UI). It does **not** mean installing a new APK without the user going through **Google Play** (Play policy and AGENTS both assume store updates).
3. **My Progress (Pro)** stays a **Me** entry; data comes from existing profile + new read-only aggregates: not a port of the old monolithic progress UI.
4. **Feedback** is stored server-side and optionally forwarded by email (Resend already optional on server); no public “feedback feed” in v1.
5. **Pro unlock** continues to use **RevenueCat + `GET /me/plan`**; My Progress gate uses **`MeViewModel.isPro`** (shared `BillingRepository`), not a separate flag.
6. **Old codebase** (`ACADEMe-frontend` / lost session) is **reference only** for fields and copy, not file structure.

---

## Objective

### A. Help and feedback (submit in app)

Students tap **Report a wrong answer**, **Something isn’t working**, or **Suggest a feature**, write a short message, and submit while signed in. Support can triage from the database (and email if configured).

**User stories**

- As a signed-in student, I submit feedback with a category and message and see confirmation (or a clear error).
- As ops, I see rate-limited, authenticated submissions tied to `accountId`, not spam.

### B. My Progress (Pro, end-to-end)

**Already shipped (client):** `ProgressScreen` shows streak / level / XP / syllabus from `GET /me/profile`; free users see Pro hold; **`openProgress`** runs purchase via `UpgradeSheet` then `pro.load`.

**To complete (server + client):**

- **`GET /me/progress`** (Pro-only): read-only summary for the progress screen: weekly activity, lesson/chapter counts, optional subject breakdown: computed from existing study tables (no duplicate XP source of truth).
- Client: Pro users load this after unlock; show loading / error states; keep gate synced with billing.

**Explicitly out of v1 (roadmap F1b–F5):** streak calendar, freeze, leaderboards, achievements, weekly share card.

### C. App update policy (remote, operator-controlled)

Operator sets policy via **environment / config** (no app redeploy to change thresholds):

| Mode | Behavior |
|------|----------|
| **Soft** | Dismissible banner or sheet: “A new version is available” → opens Play listing. |
| **Force** | Blocking screen until `buildNumber >= minBuild`; only action is Update (Play). |

**Endpoint:** `GET /app/config` (no auth) returns `{ minBuild, recommendedBuild, updateMessage, updateUrl }` plus optional feature flags later.

Client reads **`package_info_plus`** (or existing version from `pubspec` / platform channel) once per cold start and after resume; compares to config.

---

## Current state: My Progress Pro unlock (verified in repo)

| Check | Result |
|-------|--------|
| Gate uses `me.isPro` | Yes: `ProgressScreen` listens to `MeViewModel` only. |
| `MeViewModel.isPro` | `_billing?.isPro` with `_billing.addListener(notifyListeners)`. |
| Purchase path | `me_navigation.openProgress` → `UpgradeSheet.show` → `pro.load.execute()` after success; `mounted` guarded. |
| Remote billing | `BillingRepositoryRemote.isPro` = plan **or** RevenueCat customer; purchase calls sync + `notifyListeners`. |
| Widget tests | `test/ui/progress/progress_screen_test.dart`: free hold vs Pro stats (**pass**). |
| Integration | `me_settings_test` opens My Progress (free hold copy); **no** journey yet for unlock-after-purchase on Progress screen. |

**Likely gap (manual QA):** After real Play purchase, if RC is Pro but `/me/plan` lags, UI should still unlock (`isPro` includes customer). If only server plan flips without RC listener, user must pull plan: already handled by `pro.load` after sheet.

**Acceptance for “unlock works”:** Integration test: free → open My Progress → complete Test Store purchase → hold gone → stats visible (follow `pro_purchase_test` patterns).

---

## Tech stack

- Flutter 3.x, MVVM, `ChangeNotifier`, commands, `Result<T>`, fakes in `testing/fakes/`.
- Go 1.25+, `http.ServeMux`, `internal/<feature>`, `httpx`, pgx, migrations in `internal/postgres/migrations/`.
- Email: existing Resend optional (`ACADEME_RESEND_API_KEY`).

---

## Commands

From `academe/`:

```bash
dart format lib test
flutter analyze
flutter test
flutter test integration_test/pro_purchase_test.dart   # device/emulator + Test Store
```

From `academe/server/`:

```bash
gofmt -l .
go vet ./...
go test ./internal/feedback/... ./internal/progress/... ./internal/appconfig/...
golangci-lint run
```

---

## Project structure (new / touched)

```
server/internal/feedback/     store.go, handler.go, service.go, feedback_test.go
server/internal/progress/     handler.go, service.go (read models from study/profile)
server/internal/appconfig/    handler.go (GET /app/config from env)
server/postgres/migrations/   NNNN_feedback.sql

lib/data/repositories/        feedback_repository.dart, progress_repository.dart, app_config_repository.dart
lib/data/services/            feedback_api_service.dart, progress_api_service.dart, app_config_api_service.dart
lib/ui/me/view_models/        help_view_model.dart (or feedback_view_model.dart)
lib/ui/me/widgets/            help_screen.dart (form + submit), feedback_sheet.dart
lib/ui/progress/              progress_view_model.dart, progress_screen.dart (load GET /me/progress)
lib/ui/shell/                 update_gate.dart (force + soft), wired from router or shell init
lib/config/                   read build number for compare

test/ui/me/                   help_screen_test.dart
test/ui/progress/             progress_screen_test.dart, progress_view_model_test.dart
integration_test/             progress_pro_test.dart, feedback_submit_test.dart

tasks/spec-feedback-progress-app-updates.md   (this file)
docs/play/app-update-policy.md                (operator how-to)
```

---

## API design (additive)

### `POST /me/feedback`

- Auth: bearer required.
- Body: `{ "category": "wrong_answer" | "bug" | "feature", "message": string, "context": object? }`
  - Optional `context`: `{ "deckId", "chapterId", "threadId" }` when launched from study/ASKMe later.
- Validation: message 10–2000 chars; category enum.
- Responses: `201` `{ "id": "..." }`; `422` validation; `429` `too_many_requests` + `Retry-After`.
- **Rate limits (feedback):** per account **2 per IST day**, **5 per IST week** (Monday IST, same as billing). Responses: `429` with `error.details.scope` `day` or `week`.

### `GET /me/progress`

- Auth: bearer required.
- **403** `pro_required` if not Pro (server enforces; client already gates).
- **200** example:

```json
{
  "weekStartsOn": "2026-11-03",
  "daysActiveThisWeek": 4,
  "lessonsFinishedThisWeek": 12,
  "chapterTestsThisWeek": 2,
  "xpThisWeek": 180,
  "bySubject": [{ "id": "science", "name": "Science", "lessonsDone": 5 }]
}
```

Computed from existing study progress / XP events: **no new write path**.

### `GET /app/config`

- No auth.
- **200:**

```json
{
  "minBuild": 8,
  "recommendedBuild": 10,
  "updateMessage": "Bug fixes and faster ASKMe.",
  "updateUrl": "https://play.google.com/store/apps/details?id=com.academe.flutter"
}
```

Server env (example):

- `ACADEME_MIN_BUILD=8`: force block below this.
- `ACADEME_RECOMMENDED_BUILD=10`: soft nudge below this.
- `ACADEME_UPDATE_MESSAGE`, `ACADEME_UPDATE_URL` (optional overrides).

`minBuild=0` disables force; `recommendedBuild=0` disables soft.

---

## Code style

Follow `academe/AGENTS.md` and `server/AGENTS.md`: no comments in code, camelCase JSON, table-driven Go tests, widget tests with `PebbyStandIn`, one public widget per file.

Example handler shape:

```go
func (h handler) submit(w http.ResponseWriter, r *http.Request) error {
    // decode, validate, rate-limit, store, optional email, 201
}
```

---

## Testing strategy

| Layer | What |
|-------|------|
| Go unit | Feedback validation, rate limit 429, progress aggregation from fake store |
| Go HTTP | `httptest` on new routes |
| Flutter unit | Repositories with fake API; progress VM |
| Flutter widget | Help submit states; progress loading/error/Pro body |
| Integration | Feedback submit; Progress unlock after purchase; optional config force/soft with mock server |

---

## Boundaries

- **Always:** OpenAPI updated in same commit as routes; migrations forward-only; Pro gate on client **and** server for `/me/progress`; no secrets in repo.
- **Ask first:** New Flutter dependency (`package_info_plus` if not already present); changing Play listing URL; email template content.
- **Never:** Silent APK sideload; remove rate limits on authenticated write endpoints; store passwords/tokens in feedback rows.

---

## Success criteria (definition of done)

1. All three help rows submit feedback successfully when signed in; 429 shown with retry hint when limited.
2. Free user: My Progress shows hold; Pro user: stats + **`GET /me/progress`** data; after Test Store purchase, hold clears without app restart.
3. Setting `ACADEME_MIN_BUILD` above device build shows force screen; `recommendedBuild` alone shows dismissible soft prompt.
4. `flutter analyze` zero issues; `flutter test` green; new Go packages tested; `openapi.yaml` documents all three endpoints.
5. `docs/play/app-update-policy.md` explains how you choose force vs soft on Railway/env.

---

## Open questions (need your answers)

1. **Feedback email:** Store-only OK for v1, or must every ticket email `support@academe.cc` via Resend?
2. **Progress UI:** Besides weekly counts, do you want a **7-day activity strip** (like old app) or keep the current minimal stats + one summary block?
3. **Force update:** Block **entire app** at splash, or allow Me → Log out only?
4. **Soft reminder:** Once per day max, or every cold start until updated?
5. **Priority:** Ship **feedback + progress API** first, then **app config**, or all one PR?

---

## Implementation plan (after spec approval)

See `tasks/plan-feedback-progress-updates.md` and `tasks/todo-feedback-progress-updates.md`.

Phases:

1. Server: migrations + feedback + rate limits + OpenAPI + tests.
2. Flutter: feedback repository + Help UI + tests.
3. Server: progress read service + `GET /me/progress` + tests.
4. Flutter: progress VM + screen data + integration unlock test.
5. Server: `GET /app/config` + env in `internal/config`.
6. Flutter: version check + force/soft UI + operator doc.
7. Roadmap changelog + full `flutter test` / Pixel smoke.

**Do not start Phase 1 until you confirm the open questions and mark this spec approved.**
