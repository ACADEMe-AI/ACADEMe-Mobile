# Telemetry roadmap

Status: planned. This roadmap is the single source for telemetry work. It
defines how ACADEMe becomes diagnosable without exposing student content; it
does not approve SDK installation or data collection by itself.

## Checklist

### Foundation

- [ ] Choose OpenTelemetry as the application instrumentation contract.
- [ ] Choose the first error tracker: self-hosted GlitchTip.
- [ ] Keep product analytics separate from error diagnostics.
- [ ] Keep vendor SDKs behind one application-owned telemetry boundary.

### Logs

- [ ] Define structured fields: request ID, trace ID, account ID hash,
      capability, outcome, error class, provider, model, and deployment version.
- [ ] Add redaction before export.
- [ ] Prohibit prompts, responses, photos, credentials, names, email addresses,
      and crisis transcripts in ordinary logs.

### Traces

- [ ] Trace API boundaries, database calls, provider calls, background work, and
      support-case creation.
- [ ] Propagate one trace ID across Flutter, the Go API, and external calls.
- [ ] Link sanitized GitHub issues to trace IDs.

### Metrics

- [ ] Track availability, latency, error rate, retries, provider usage, model,
      token counts, estimated cost, OCR quality flags, safety outcomes, and
      support-case volume.
- [ ] Define owners, alert thresholds, and escalation paths for each metric.

### Product events

- [ ] Define a small allowlisted event vocabulary for feature usage and
      outcomes.
- [ ] Exclude student text, answers, photos, and raw prompts.
- [ ] Keep session replay disabled until privacy and child-safety review approve
      it.

### Retention and access

- [ ] Assign a retention period to every signal.
- [ ] Keep raw operational events short-lived and access-controlled.
- [ ] Keep aggregate metrics longer for trend and capacity planning.
- [ ] Keep support cases minimal and separately permissioned.
- [ ] Keep evaluation samples anonymized and separate from analytics.

### Support and coding-agent automation

- [ ] Create a sanitized internal support case from eligible telemetry.
- [ ] Deduplicate cases by error fingerprint.
- [ ] Create an idempotent GitHub issue with the `agent` label.
- [ ] Give the coding agent read-only access to approved traces and repository
      context.
- [ ] Permit draft PR creation only after tests and policy checks.
- [ ] Require human approval before merge or deployment.
- [ ] Prohibit student content, secrets, unrestricted logs, merge rights, and
      deployment rights in the agent workflow.

## Definition of done

- [ ] Every signal has an owner, schema, retention period, and redaction test.
- [ ] Flutter and Go use the same correlation identifiers.
- [ ] Support can move from a GitHub issue to a trace without seeing student
      content.
- [ ] A coding agent can reproduce a sanitized technical failure and open a
      draft PR without merge or deploy authority.
