# Google AI provider bundle tasks

- [~] Task 1: Add provider-neutral AI contracts
  - Acceptance: chat, OCR, marking, lesson generation, and review have stable contracts; feature packages do not import provider SDK types.
  - Verify: `go test ./internal/ai ./internal/chat ./internal/scan ./internal/lessons`
  - Files: `server/internal/ai/`, `server/internal/chat/`, `server/internal/scan/`, `server/internal/lessons/`

- [x] Task 2: Add validated Google provider configuration
  - Acceptance: exactly one complete provider bundle is selected; invalid Google configuration fails startup validation.
  - Verify: `go test ./internal/config ./cmd/academe-api`
  - Files: `server/internal/config/`, `server/cmd/academe-api/main.go`

- [x] Task 3: Implement Vertex AI text adapter
  - Acceptance: Google text requests map to the ACADEMe contract and provider failures map to stable errors.
  - Verify: adapter contract tests with no network calls.
  - Files: `server/internal/ai/providers/`, provider tests

- [x] Task 4: Implement Document AI OCR adapter
  - Acceptance: Google OCR returns ordered extracted text and stable errors without leaking Document AI types.
  - Verify: adapter tests with fake clients.
  - Files: `server/internal/ai/providers/`, provider tests

- [x] Task 5: Wire Google into chat and scan
  - Acceptance: ASKMe and Scan resolve the same configured provider bundle with no silent fallback.
  - Verify: service tests and local startup smoke test.
  - Files: `server/internal/chat/`, `server/internal/scan/`, `server/cmd/academe-api/main.go`

- [x] Task 6: Wire Google into lesson generation and review
  - Acceptance: writer and reviewer use the same active bundle and existing validation remains enforced.
  - Verify: lesson generator tests and controlled fake run.
  - Files: `server/internal/lessons/`, `server/cmd/academe-lessons/`

- [ ] Task 7: Update privacy, OpenAPI, and deployment configuration
  - Acceptance: public provider wording and deployment documentation match Google-first behavior.
  - Verify: legal placeholder and OpenAPI checks.
  - Files: `server/openapi.yaml`, `server/internal/site/pages/`, docs

- [ ] Task 8: Benchmark and production smoke test
  - Acceptance: Google passes agreed quality, safety, latency, and cost thresholds before activation.
  - Verify: benchmark report and live smoke test with approved credentials.
  - Files: `tasks/reports/`

`[~]` means the current implementation slice is provider-neutral for chat,
OCR, and lesson generation; marking-specific contracts and live Google
validation remain in the production-readiness tasks.
