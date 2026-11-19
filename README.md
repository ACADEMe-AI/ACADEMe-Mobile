# ACADEMe Mobile

Workspace for the **ACADEMe** rebuild: Flutter app + Go API for Indian Class
6–12 (CBSE / ICSE / ISC) board exam prep.

**Start here → [`academe/README.md`](academe/README.md)**

That document is the full project briefing for contributors (product, USP,
Free vs Pro, stack, status, how to run, and where deeper docs live). The app
and server code, Play docs, strategy, and roadmap all live under `academe/`.

## Current status

- Android app: **1.1.2 (12)** in Google Play closed testing, track `ACADEMe`.
- Backend: production API at [`api.academe.cc`](https://api.academe.cc), hosted
  on Cloud Run in Mumbai (`asia-south1`) with PostgreSQL.
- Billing: Google Play Billing through RevenueCat; entitlement `academe_pro`.
- AI: Sarvam is the production provider for Pebby, Scan, and lesson generation.
- Updates: the backend currently recommends build **12**, so older installs can
  show the in-app update banner.
- Pull request: [#1](https://github.com/ACADEMe-AI/ACADEMe-Mobile/pull/1) is the
  current rebuild PR into `main`.

## What ACADEMe is

ACADEMe is an India-first study companion for students in Classes 6–12. Its
core differentiator is the combination of board-specific syllabus learning,
short swipeable lessons, Pebby’s step-by-step tutoring, board-style homework
checking, and support for Indian languages—without ads or a paywall during
onboarding.

## Next steps before public launch

1. Reconcile the older hosting and roadmap documents with the current Cloud Run
   deployment so contributors have one reliable operational source of truth.
2. Finish Play production prerequisites: legal placeholders, reviewer access,
   Data Safety, Families/content rating, store listing, and subscription setup.
3. Verify a complete Play-installed journey on a real device, including login,
   lessons, ASKMe, Scan, Pro purchase/restore, update banner, and account
   deletion.
4. Keep Sarvam credits funded and generate/teacher-review Class 10 and 12
   lessons before scaling public traffic.
5. Merge PR #1, then release gradually: 10%, 50%, and finally 100% after
   checking crashes, ANRs, billing events, AI reports, and support mail.

For the full product context, contributor guide, architecture, testing
commands, and roadmap, read [`academe/README.md`](academe/README.md) first.
