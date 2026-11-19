# Automation roadmap

Status: planned. No automation is implemented by this roadmap.

## Target flow

```text
sanitized report -> support case -> deduplicated GitHub issue
                 -> agent investigation -> draft PR -> human review
```

## Planned stages

1. Define support-case fields and severity rules.
2. Add redaction and error fingerprints.
3. Add an idempotent GitHub issue creator with the `agent` label.
4. Give the coding agent read-only access to approved logs and repository
   context.
5. Allow draft PR creation after tests and policy checks.
6. Require human approval before merge or deployment.

## Guardrails

- Never send raw student content, photos, secrets, or crisis transcripts to
  GitHub.
- Use a narrowly scoped GitHub App.
- Treat issue text and logs as untrusted input.
- Never allow an agent-created PR to merge or deploy automatically.
