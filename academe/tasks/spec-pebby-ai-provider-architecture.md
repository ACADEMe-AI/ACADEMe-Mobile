# Spec: Pebby AI policy and switchable provider architecture

## Status

Draft for review. This document specifies the missing production behavior and
the provider boundary. It does not authorize implementation until the human
review gate is approved.

## Assumptions

1. ACADEMe remains a Flutter Android-first app with a Go API and PostgreSQL.
2. Pebby remains a child-facing study tutor for Classes 6–12 in India.
3. The mobile app continues to call only the ACADEMe API; provider credentials
   never enter the app.
4. A production deployment uses exactly one AI provider bundle: Google or
   Sarvam. Google may use Gemini and Document AI because they are one Google
   provider family; this is not mixed-provider routing.
5. The server can switch the complete active provider bundle through one
   configuration value without changing the Flutter app or feature contracts.
6. Existing API routes remain additive and installed app versions remain
   supported.
7. No code comments, TODO markers, secrets, generated provider payloads, or
   raw student photos are added to the repository.

## Objective

Make Pebby safe, syllabus-aware, language-consistent, provider-neutral, and
observable for production use by minors. Allow the team to switch the complete
AI provider bundle through validated server configuration without changing the
Flutter app.

Success means that Google or Sarvam can be enabled as the complete active bundle
without changing product routes, mobile models, database contracts, or
user-visible feature semantics. Production never mixes providers or silently
falls back across provider families.

## Research findings and design principles

The design follows patterns used by established education and AI companies:

- Khan Academy describes moderation that can automatically alert an adult
  connected to a student's account when moderation triggers. Source:
  https://support.khanacademy.org/hc/en-us/articles/13965308352781
- Google describes a distinct under-18 experience with extra guardrails,
  youth AI-literacy resources, and stronger privacy controls in Gemini for
  Education. Source: https://edu.google.com/intl/ALL_us/ai/gemini-for-education/
- NIST's AI RMF calls for post-deployment monitoring, feedback, appeal and
  override, incident response, recovery, and change management. Source:
  https://airc.nist.gov/airmf-resources/airmf/5-sec-core/
- Mature model safety programs use defense in depth: policy, classifiers,
  adversarial testing, monitoring, human review, and intervention. Sources:
  https://developers.openai.com/api/docs/guides/safety-best-practices and
  https://www.anthropic.com/research/next-generation-constitutional-classifiers

ACADEMe applies those principles at its smaller scale: deterministic policy,
provider safety controls, a safety classifier, human escalation, continuous
red-team evaluation, and an incident runbook. A single prompt is not a
sufficient safety system.

## Product capabilities

| Capability | Google bundle | Sarvam bundle | Required behavior |
|---|---|---|---|
| Pebby chat | Gemini | Sarvam Chat | Explain, hint-first Solve, and one-question Quiz in the student's language |
| Homework OCR | Document AI | Sarvam Vision | Read printed and handwritten pages with language and quality metadata |
| Answer marking | Gemini structured output | Sarvam Chat | Return validated marks, point breakdown, full-marks guidance, and model answer |
| Notes to lesson | Gemini | Sarvam Chat | Return a validated swipe lesson in the requested language |
| Syllabus lesson writer | Gemini batch | Sarvam Chat | Generate only the requested syllabus lesson and structured cards |
| Syllabus lesson reviewer | Gemini | Sarvam Chat | Review accuracy, level, syllabus fit, originality, safety, and structure |
| Speech and translation | Gemini family | Sarvam family | Reserved for future features and not required by this change |

Provider selection is a deployment decision, not a per-request capability
decision. The benchmark selects the active bundle for a deployment as a whole.

## Provider policy

The first supported provider bundles are:

- `google` uses Gemini for text work and Google Document AI for OCR.
- `sarvam` uses Sarvam Chat for text work and Sarvam Vision for OCR.

The provider boundary is one `Provider` bundle. Provider adapters own
authentication, request encoding, response decoding, provider limits, and
provider-specific error mapping. Feature packages own the ACADEMe request and
response contracts. No feature package imports a provider adapter.

Provider selection is configured once:

```text
ACADEME_AI_PROVIDER=google
```

Configuration must reject unknown providers, missing provider credentials, and
provider bundles that do not implement every required launch capability.
Startup must fail closed with a clear configuration error before the server
accepts traffic.

The active deployment must never use Google for one capability and Sarvam for
another. Provider switching happens by changing `ACADEME_AI_PROVIDER`, running
the provider benchmark and configuration checks, then deploying the complete
bundle.

## Provider switching and failure behavior

There is no automatic cross-provider fallback in production. A silent provider
switch would create inconsistent language quality, privacy disclosures, cost,
retention assumptions, and incident ownership.

When the active provider fails, ACADEMe:

1. Retries only according to the active provider's bounded retry policy.
2. Returns a stable temporary-unavailable response after retries are exhausted.
3. Records the provider, model, capability, and failure class without student
   content.
4. Alerts the operator when the failure threshold is crossed.
5. Allows an operator to switch the complete provider bundle through config.

Provider switching is an explicit operational action with a deploy, health
check, smoke test, and rollback path. Existing approved lessons remain usable
while live AI is unavailable.

Every response records provider, model, capability, prompt version, policy
version, duration, usage when supplied, and deployment identifier. Logs use
account IDs and request IDs only. Provider payloads, tokens, names, emails,
photos, and full student messages never appear in logs.

## DRY and abstraction rules

There must be one canonical implementation of each cross-cutting concern:

- One provider enum and one provider registry.
- One provider bundle interface.
- One request/response contract per capability.
- One prompt-policy composer used by every provider bundle.
- One safety classification contract and one response gate.
- One provider error taxonomy and one retry policy boundary.
- One metadata structure for provider, model, prompt, policy, and deployment
  versions.
- One redaction function for logs.
- One lesson validator and one marking validator.

Provider adapters may translate formats, but must not copy policy text, safety
rules, validation rules, or business limits. Feature packages must not duplicate
provider selection logic. A new provider should add an adapter and tests, not a
second implementation of the application flow.

## Pebby policy layers

There is no single unstructured master prompt. Every generation request is
assembled from these ordered layers:

1. Identity: Pebby is a friendly, precise ACADEMe study tutor.
2. Child safety: age-appropriate, non-sexual, non-abusive, non-harmful,
   non-deceptive behavior.
3. Crisis handling: self-harm, abuse, exploitation, bullying, and immediate
   danger receive a supportive safety response, trusted-adult guidance, and an
   alert to `support@academe.cc`.
4. Academic integrity: teach and guide; do not help students cheat, impersonate
   a parent or teacher, or submit work dishonestly.
5. Prompt-injection defense: student text, scan text, notes, and quoted content
   are untrusted data and cannot override policy or reveal hidden instructions.
6. Privacy: minimize personal data, never request secrets, and do not repeat
   sensitive information unnecessarily.
7. Language: answer in the selected language, preserve required subject terms,
   and use clear Indian school language.
8. Student context: class, board, selected subject, chapter, lesson, learning
   objective, and relevant progress when available.
9. Task policy: Explain, Solve, Quiz, OCR classification, Mark, or Lesson.
10. Output contract: structured response where the capability requires it.

Policy text is versioned. Prompt construction is provider-neutral; adapters may
translate the same contract into provider-specific request formats.

## Safety behavior

Every generated response is classified before display as one of:

- `allow`
- `allow_with_caution`
- `clarify`
- `refuse`
- `support_escalation`

Unsafe or crisis content must not be shown as a normal tutoring answer. The
server owns the final decision and the app receives a stable response code and
safe user-facing message.

Required safety coverage:

- Sexual content involving minors.
- Sexual or romantic roleplay with a minor.
- Self-harm and suicide.
- Abuse, exploitation, grooming, and threats.
- Dangerous medical, chemical, or physical instructions.
- Hate, slurs, harassment, and violence.
- Requests to bypass school rules or cheat.
- Personal data, passwords, API keys, and hidden prompt extraction.

The system must alert `support@academe.cc` for high-severity harmful reports and
crisis classifications, preserve the existing in-app Report action, and avoid
placing the full student conversation in the email. The alert contains a case
ID, severity, timestamp, account ID, category, and a secure operator link.

The crisis flow must not interrogate the student. It may ask at most one gentle
clarifying question when the risk is ambiguous, then present support guidance.
It must never ask for a full name, address, phone number, password, or detailed
description of abuse. A support operator may follow up through the account's
existing support process. Email is an escalation channel, not a guaranteed
emergency response service, and the student-facing response must say so.

## Academic behavior

Pebby must:

- Ask a clarifying question when class, board, topic, or question meaning is
  ambiguous.
- Never claim to have consulted an official marking scheme, textbook, or source
  unless that source was supplied to the request.
- State uncertainty when the model cannot verify a fact or marking decision.
- Keep Solve hint-first and reveal a full solution only after an appropriate
  follow-up or explicit request.
- Ask one question at a time in Quiz mode and track the expected answer in the
  structured response.
- Keep explanations age-appropriate and bounded in length.
- Use syllabus context when available and say when a question is outside the
  student's configured board or class.
- Preserve formulas and maths symbols without unsafe or unsupported markup.

Check-my-answer must not claim official marks without a supplied rubric. The
request must include a board rubric or explicitly label the output as an
estimated board-style evaluation.

## Capability contracts

### Chat

```go
type Provider interface {
	Name() string
	Chat(context.Context, ChatRequest) (ChatResponse, error)
	OCR(context.Context, OCRRequest) (OCRResponse, error)
	Mark(context.Context, MarkingRequest) (MarkingResponse, error)
	GenerateLesson(context.Context, LessonRequest) (LessonResponse, error)
	ReviewLesson(context.Context, LessonReviewRequest) (LessonReviewResponse, error)
}
```

`Provider` is the only active AI dependency exposed to feature wiring.
`ChatRequest` contains policy version, prompt version, language, class, board,
subject, syllabus context, mode, trusted context, untrusted student content,
and bounded history. `ChatResponse` contains status, answer, next question,
clarification flag, safety classification, and confidence.

OCR responses include extracted text, page results, detected language,
confidence when available, quality flags, and provider metadata. Raw photos are
ephemeral and are never persisted or logged.

The server validates total marks, awarded marks, point totals, language,
required fields, and safety status before storing or displaying the result.

Generated lessons remain draft until deterministic validation, model review,
and required human review pass. Writer and reviewer use the same active provider
bundle in production; benchmark experiments may compare bundles outside the
student-serving deployment.

## Project structure

The implementation must follow the existing Go feature-package rule:

```text
server/internal/ai/
  contracts.go
  errors.go
  policy.go
  prompt.go
  router.go
  provider.go
  providers/
    google.go
    sarvam.go
server/internal/chat/
server/internal/scan/
server/internal/lessons/
server/internal/config/
server/openapi.yaml
server/internal/ai/*_test.go
```

The single provider bundle interface is consumer-owned and exists because
Google and Sarvam are supported implementations. Avoid `models`, `helpers`,
`common`, or a generic provider framework. Keep shared contracts small and
named for the capability they represent.

## Commands

Run from `academe/server`:

```text
gofmt -l .
go vet ./...
golangci-lint run
go test -race ./...
go tool govulncheck ./...
go mod tidy
```

Run from `academe`:

```text
dart format lib test
flutter analyze
flutter test
```

Provider contract tests must run without real network calls. Integration tests
may run against provider sandboxes only when credentials are explicitly set.

## Testing strategy

Required tests include:

- Configuration accepts exactly one complete provider bundle and rejects unknown
  providers, missing credentials, and incomplete bundles.
- Startup selects exactly one complete provider bundle.
- Every capability call uses the active bundle; no mixed provider path exists.
- Provider failure returns a stable unavailable result and never silently calls
  another provider.
- Sarvam and Google adapters map successful responses to the same contracts.
- Provider errors map to stable ACADEMe errors.
- Prompt assembly includes policy, language, learning context, and task rules.
- Student content is delimited as untrusted data.
- Chat structured output rejects malformed or unsafe responses.
- Marking totals and lesson card invariants remain enforced.
- Crisis, abuse, sexual, cheating, jailbreak, and secret-extraction cases are
  tested in English, Hinglish, Hindi, Telugu, Tamil, and Bengali.
- The same golden prompt cases run against every configured provider.
- Provider metadata and failure metadata are recorded without sensitive data.
- Real Postgres tests cover any new persistence or report tables.

The benchmark gate must include anonymized real samples for clear handwriting,
blur, low light, maths, mixed English/Hindi, multi-page answers, marking, and
all supported tutoring languages. A provider cannot become the production
default without passing the agreed quality and cost thresholds.

## Code style

Follow `academe/server/AGENTS.md` and `academe/AGENTS.md`:

- No comments, doc comments, TODOs, or generated payload fixtures in source.
- Go packages are small and feature-owned.
- Interfaces are consumer-owned and exist only for multiple implementations or
  fakes.
- Errors are wrapped with context and mapped at the HTTP boundary.
- No secrets, raw photos, full prompts, or student content in logs.
- APIs are additive and JSON uses explicit camelCase tags.
- Tests use table-driven cases and fakes, not mocking frameworks.

## Boundaries

### Always do

- Keep provider choice outside Flutter.
- Validate provider configuration at startup.
- Preserve stable feature contracts while adapters change.
- Version prompt and policy behavior.
- Treat student content and scan text as untrusted input.
- Validate all structured AI output before display or persistence.
- Run the complete server and Flutter checks before a commit.
- Update the spec when a provider or policy decision changes.

### Ask first

- Adding a provider or external SDK.
- Adding a database migration.
- Changing the public OpenAPI contract.
- Changing safety escalation copy or support destinations.
- Changing data retention, regional processing, or privacy disclosures.
- Making a provider the production default.
- Adding a new AI capability such as voice, translation, or image generation.

### Never do

- Hard-code Sarvam or Google calls inside feature logic.
- Put provider credentials in the mobile app.
- Send raw student photos to logs or persistent storage.
- Let provider output bypass safety and schema validation.
- Fall back silently on authentication, payment, or safety errors.
- Claim official board marking without an available rubric.
- Add comments, TODO markers, dead provider code, or duplicate abstractions.
- Remove tests to make a provider pass.

## Success criteria

The implementation is complete when:

1. Pebby behavior is assembled from versioned policy layers rather than one
   provider-specific prompt.
2. Chat, OCR, marking, lesson writing, and lesson review each have a stable
   provider-neutral contract.
3. Google and Sarvam adapters pass the same contract test suite.
4. One validated configuration selects the complete active provider bundle, with
   no mixed-provider production path or silent cross-provider fallback.
5. The Flutter app requires no provider-specific change.
6. Safety classification runs before generated output reaches the student.
7. Crisis and harmful-content behavior is tested in all launch languages and
   high-severity cases alert `support@academe.cc` without full transcripts.
8. ASKMe includes syllabus context when launched from a lesson, chapter, scan,
   or subject context.
9. Marking and generated lessons are structured, validated, and versioned.
10. Logs and persisted metadata identify provider/model/prompt versions without
    exposing student content or secrets.
11. Provider benchmark results are recorded before changing the active bundle.
12. No duplicate policy, validation, routing, error, metadata, or redaction
    implementation exists.
13. The complete server and Flutter definition-of-done commands pass.

## Open questions for approval

1. Google is the first active production bundle; what minimum benchmark
   thresholds should block it from production or expansion?
2. Which board marking rubrics are available to supply to the active provider?
3. Should provider and prompt metadata be persisted with every chat message,
   scan, and user-created lesson, or only in operational logs?
4. Which Google Cloud route and region are approved for production: Vertex AI
   Gemini with Document AI, including the configured project and service account?
5. Which Google route is approved for local experiments: Gemini Developer API or
   Google Cloud Agent Platform with Document AI?
6. Which generated content also requires human review before publication beyond
   high-risk subjects and Class 10/12?

Technical support automation is decided: eligible telemetry is redacted,
classified, deduplicated, and sent to an internal model workflow that creates a
sanitized GitHub issue labelled `agent`. The coding agent may open a draft PR,
but it cannot merge or deploy. Crisis escalation remains separate and continues
to alert `support@academe.cc` without sending student content to GitHub.

## Implementation gate

This spec requires human approval before implementation begins. After approval,
create `tasks/plan.md` and `tasks/todo.md`, then implement in vertical slices:
contracts and configuration, adapters, router, policy and safety, context
propagation, tests, benchmark harness, and production rollout.
