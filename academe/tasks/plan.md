# Google AI provider bundle implementation plan

**Goal:** Make Google Cloud the first selectable ACADEMe AI provider bundle for
Pebby text generation and Scan OCR while preserving the existing feature
contracts and keeping Sarvam available as an inactive complete bundle.

**User Perspective:** Today ASKMe and Scan depend on the Sarvam key and can be
unavailable when Sarvam credits are exhausted. After this work, the server can
select Google as one complete provider bundle through configuration; the Flutter
app keeps the same routes and behavior.

**Reason for Change:** The current implementation exposes Sarvam-specific
types throughout chat, scan, lesson generation, handlers, tests, and public
descriptions. That prevents a safe provider switch and blocks end-to-end use
when the current provider is unavailable.

**Architecture:** Add a small provider-neutral contract package, Google
adapters using the official Go Gen AI SDK and Document AI client, and startup
configuration that selects exactly one complete bundle. Feature packages depend
on their consumer-owned contracts; adapters own Google request/response
translation and provider errors. No cross-provider fallback is added.

**Tech Stack:** Go 1.27.1, `google.golang.org/genai`,
`cloud.google.com/go/documentai`, Application Default Credentials, existing
stdlib HTTP and pgx patterns.

## Tasks

### Phase 1: Contracts and configuration

#### Task 1: Add provider-neutral AI contracts

**Files:** `server/internal/ai/`, chat/scan/lessons contract tests.

**User Perspective:** Feature behavior remains unchanged, but the server no
longer needs to know whether Google or Sarvam produced the result.

**Reason for Change:** Existing feature interfaces use `sarvam.Message` and
`sarvam.Page`, which makes provider switching impossible without duplicating
feature logic.

**Steps:** Define request/response types, the complete `Provider` interface,
stable provider errors, and conversion boundaries for chat, OCR, marking, and
lesson generation. Keep the first slice compatible with existing chat and scan
flows.

**Verification:** Contract tests compile with fakes and reject malformed or
unavailable provider results.

#### Task 2: Add validated Google provider configuration

**Files:** `server/internal/config/config.go`, config tests, `server/cmd/academe-api/main.go`.

**User Perspective:** Operators can select Google with one deployment setting;
misconfigured provider deployments fail before accepting traffic.

**Reason for Change:** Current startup only checks whether a Sarvam key exists
and silently disables AI when it does not.

**Steps:** Add `ACADEME_AI_PROVIDER`, Google Cloud project/location, Document AI
processor, and ADC-backed client configuration. Require all launch capability
settings for the selected bundle and reject unknown providers.

**Verification:** Table-driven config tests cover Google, Sarvam, missing values,
and invalid provider names.

### Checkpoint: Foundation

- [ ] Provider contracts and configuration tests pass.
- [ ] No feature package imports Google SDK types.
- [ ] No credentials are added to the repository.

### Phase 2: Google adapters

#### Task 3: Implement Vertex AI text adapter

**Files:** `server/internal/ai/providers/google.go`, adapter tests.

**User Perspective:** Pebby can generate a response through Google without any
Flutter change.

**Reason for Change:** The production provider decision is Google-first and
the current live path is Sarvam-only.

**Steps:** Use the official Go Gen AI SDK with Vertex AI configuration, map
ACADEMe chat requests to Gemini contents, enforce bounded output, decode
structured responses where required, and map authentication, quota, timeout,
and server failures to stable ACADEMe errors.

**Verification:** HTTP/client fakes cover successful text, empty output,
malformed output, timeout, quota, and authentication failures.

#### Task 4: Implement Document AI OCR adapter

**Files:** `server/internal/ai/providers/google.go` or a focused OCR adapter,
adapter tests.

**User Perspective:** Scan can read supported uploaded pages through Google
Document AI and return the same text contract as the current implementation.

**Reason for Change:** OCR is a separate Google Cloud capability and must stay
inside the same selected provider bundle without leaking Document AI types into
Scan.

**Steps:** Process page bytes with the configured OCR processor, preserve page
order and extracted text, enforce size/time limits, and map provider failures.

**Verification:** Adapter tests cover MIME types, empty documents, page text,
and provider failures without network calls.

### Phase 3: Feature wiring

#### Task 5: Wire Google into chat and scan

**Files:** `server/internal/chat/`, `server/internal/scan/`, main wiring,
provider integration tests.

**User Perspective:** ASKMe and all Scan modes use the selected Google bundle
with the existing API response shapes and limits.

**Reason for Change:** A provider adapter that is not wired into feature paths
does not make the app work end to end.

**Steps:** Replace Sarvam-specific feature dependencies with provider-neutral
contracts, preserve prompt and validation behavior, configure one active bundle,
and remove mixed-provider or silent fallback paths.

**Verification:** Chat and Scan service tests pass with fakes; startup tests
prove every capability resolves to the same provider bundle.

#### Task 6: Wire Google into lesson generation and review

**Files:** `server/internal/lessons/`, `server/cmd/academe-lessons/`, lesson
tests and configuration.

**User Perspective:** Lesson generation can run using Google, with drafts still
blocked from serving until validation and review pass.

**Reason for Change:** The provider switch must cover the complete bundle, not
only live chat and OCR.

**Steps:** Replace Sarvam-specific lesson message and status types with shared
contracts, use one active provider for writer and reviewer, preserve resumable
generation and validation, and update CLI flags to provider-neutral names.

**Verification:** Existing fake generator tests pass; adapter contract tests
run for Google and Sarvam; no real provider call is required for unit tests.

### Checkpoint: End-to-end provider slice

- [ ] Local server starts with Google configuration and ADC.
- [ ] ASKMe and Scan use Google in a smoke test.
- [ ] Lesson generator uses Google in a small controlled run.
- [ ] Existing API and Flutter models require no provider-specific changes.

### Phase 4: Production readiness

#### Task 7: Update privacy, OpenAPI, and deployment configuration

**Files:** `server/openapi.yaml`, privacy pages, deployment docs, provider
spec and roadmap.

**User Perspective:** The app’s privacy explanation and operational setup match
the provider actually receiving student requests.

**Reason for Change:** Current public text says student data is sent to Sarvam,
which would be inaccurate after Google activation.

**Steps:** Replace provider-specific public contracts with the approved Google
Cloud wording, document required environment variables, and record the active
provider decision without adding secrets.

**Verification:** Legal placeholder checks, OpenAPI consistency checks, and a
repository search for stale current-provider claims pass.

#### Task 8: Benchmark and production smoke test

**Files:** benchmark fixtures and reports under `tasks/reports/`; no real
student data.

**User Perspective:** Google is activated only after we know its output works
for the actual ACADEMe languages and workflows.

**Reason for Change:** Provider selection must be based on measured quality,
safety, latency, and cost rather than availability alone.

**Steps:** Run anonymized chat, OCR, marking, and lesson samples; record cost,
latency, correctness, language quality, and failure behavior; teacher-review
lesson samples before serving them.

**Verification:** Benchmark report records pass/fail thresholds and a rollback
configuration.

## Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Google SDK API changes | High | Pin dependencies and keep adapter tests contract-focused |
| Provider-specific output differences | High | Validate all outputs at the ACADEMe boundary |
| Missing ADC or IAM permissions | High | Fail startup with an actionable configuration error |
| Google cost exceeds budget | High | Model/output limits, quotas, batch generation, and per-capability cost reports |
| Privacy documentation becomes stale | High | Update public provider wording in the same implementation slice |

## Open questions

- Google Cloud project ID, location, and Document AI processor ID.
- Whether the production workload will use workload identity federation or a
  securely injected service-account credential configuration.
- Board rubric sources for marking validation.
- Benchmark thresholds for Google activation.
