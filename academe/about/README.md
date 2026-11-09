# ACADEMe project context

This directory is the durable orientation layer for people and AI agents
working on ACADEMe. It explains what the product is, how the repository is
organised, what has been decided, and where future work is planned.

## Start here

1. Read this file for product context.
2. Read `rules/README.md` before changing code.
3. Read `roadmap/roadmap.md` before planning work.
4. Read `usp/README.md` before changing product positioning.
5. Read `roadmap/telemetry.md` before adding logs, events, traces, or reports.

The detailed execution roadmap remains in `../tasks/roadmap.md`. This directory
indexes durable context and workstream roadmaps; it does not replace the
execution checklist.

## Product

ACADEMe is an Android-first Flutter study app for Indian school students in
Classes 6–12. It combines syllabus-based swipe lessons, Pebby tutoring,
homework scanning, answer marking, revision, folders, reminders, and progress.
The Go API owns authentication, data, limits, provider calls, and safety
boundaries. PostgreSQL is the source of truth for server state.

The app is for students. Parents pay for Pro. ACADEMe is not an LMS, school
ERP, social network, or public Q&A forum.

## Architecture

```text
Flutter app -> Go API -> PostgreSQL
                  -> external services through server-owned adapters
```

The Flutter app never owns provider credentials or provider selection. The Go
API exposes stable product contracts and keeps external integrations behind
feature-owned boundaries.

## Current decisions

- Flutter uses MVVM with repositories and services.
- The server uses Go, standard-library HTTP, pgx, and PostgreSQL.
- APIs change additively because installed app versions remain supported.
- Code and configuration contain no explanatory comments or TODO markers.
- AI provider choice is a deployment-level decision; production uses one
  complete provider bundle at a time.
- Google is the first active AI provider bundle; provider quality, cost, and
  safety must be measured before production expansion.
- Raw student photos and sensitive student content do not enter ordinary logs.

## Context ownership

| Context | Source |
|---|---|
| Product and execution status | `../tasks/roadmap.md` |
| Flutter rules | `../AGENTS.md` |
| Server rules | `../server/AGENTS.md` |
| AI provider and Pebby spec | `../tasks/spec-pebby-ai-provider-architecture.md` |
| Play, privacy, and legal material | `../docs/play/` |
| Design system and UI previews | `../design/` |
