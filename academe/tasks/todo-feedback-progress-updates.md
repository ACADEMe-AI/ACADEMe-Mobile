# Tasks: Feedback, My Progress API, app update policy

- [x] Task: Feedback migration + store
  - Acceptance: `feedback` table with account_id, category, message, context jsonb, created_at
  - Verify: `go test ./internal/feedback/...`
  - Files: `server/internal/postgres/migrations/00XX_feedback.sql`, `server/internal/feedback/store.go`

- [x] Task: `POST /me/feedback` + rate limits
  - Acceptance: 201 create; 429 after limits; OpenAPI updated
  - Verify: handler tests + `go test ./internal/feedback/...`
  - Files: `handler.go`, `service.go`, `openapi.yaml`

- [x] Task: Flutter feedback repository + Help submit UI
  - Acceptance: three categories submit; error/limit states
  - Verify: `flutter test test/ui/me/help_screen_test.dart`
  - Files: `lib/data/...`, `help_screen.dart`, `help_view_model.dart`

- [x] Task: `GET /me/progress` (Pro-only)
  - Acceptance: 403 free; 200 with weekly aggregates from study data
  - Verify: `go test ./internal/progress/...`
  - Files: `server/internal/progress/*`, `openapi.yaml`

- [x] Task: Flutter progress load + display
  - Acceptance: Pro screen shows API summary; free unchanged
  - Verify: `flutter test test/ui/progress/`
  - Files: `progress_view_model.dart`, `progress_screen.dart`

- [x] Task: Integration: My Progress unlock after purchase
  - Acceptance: hold gone after Test Store buy
  - Verify: `integration_test/progress_pro_test.dart` on Pixel harness
  - Files: `integration_test/progress_pro_test.dart`

- [x] Task: `GET /app/config` + env wiring
  - Acceptance: min/recommended build from env
  - Verify: `go test ./internal/appconfig/...`
  - Files: `server/internal/config/config.go`, `internal/appconfig/handler.go`

- [x] Task: Flutter update gate (force + soft)
  - Acceptance: force blocks; soft dismissible; opens Play URL
  - Verify: widget test + manual env bump
  - Files: `lib/ui/shell/widgets/soft_update_banner.dart`, `update_required_screen.dart`, router wiring

- [x] Task: Operator doc + roadmap changelog
  - Acceptance: `docs/play/app-update-policy.md`; roadmap entries
  - Verify: human read-through
  - Files: `docs/play/app-update-policy.md`, `tasks/roadmap.md`
