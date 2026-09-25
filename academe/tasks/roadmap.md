# ACADEMe — roadmap

The one planning document for the ACADEMe rebuild: what the app is, what is
decided, what is built, the order we build the rest in, every screen as a task,
everything that needs the user, and a log of what has been done. The strategy
(why, for whom, how we win and earn) is in `tasks/strategy.md`. Workstream
detail lives in `tasks/reports/*.md`.

Last updated 2026-09-25, 22:00 IST. Branch `academe-rebuild`, PR #1 (open).

---

## 1. What ACADEMe is

**A study app for Indian school students (Class 6–12, CBSE and ICSE; ISC for
11–12, stored as board "ICSE") that works in their own language.** Pebby, the
AI tutor, explains, solves and quizzes; lessons are short swipeable cards with
a quick check every few cards, written from the real board syllabus; Scan reads
homework and marks answers the way the board does; students keep what they miss
and it comes back in revision; folders hold what they are preparing for and turn
a date into a plan, a checklist and reminders; XP and streaks bring them back.

- **Positioning:** the feature set of the leading study apps, plus real
  Indian-language support, plus the old ACADEMe's swipe learning, rebuilt.
- **One role:** the student. Parents pay; no teacher, admin or school surface.
- **Not:** an LMS, a school ERP, a jobs board, a Q&A forum, a social network.
- **Money:** free core (every lesson, revision, folders, reminders) + ACADEMe
  Pro for unlimited Pebby and Scan (§7 Phase 9).

### USPs

| # | USP | Status |
|---|---|---|
| 1 | Everything the leading study app does: AI tutor, homework scan, notes, flashcards, quizzes, mock exams, exam planner, streaks | Tutor, lessons, quizzes, revision, planner (folders), Scan built; mock exams, streaks to do |
| 2 | The whole app in your language, switchable any time | Pebby answers in the profile language; app text and lessons English (Hindi and Sanskrit lessons in Hindi) until Stage 2. "Understands Hinglish" dropped from the listing: nothing backs it yet |
| 3 | Learn by swiping: lessons as card decks, a quick check every few cards, "here's why" on mistakes | Built (text only) |
| 4 | Knows the syllabus: class and board decide subjects, chapters and lessons | Full CBSE + ICSE/ISC 6–12 catalogue (14 files, 5,777 planned lessons) served; 6 lessons written and live, the rest "Coming soon" until the pipeline runs |
| 5 | Pebby: a tutor with personality, step by step rather than just answers | Built; live on Railway (needs Sarvam credits) |
| 6 | Fair: no paywall in onboarding; every lesson free; no metered "generations" on the syllabus | Holds for lessons. ASKMe (10/day), Scan (3/day) and Check (1/day) are metered on Free, see D10 |
| 7 | Built right for Indian Android phones and for minors: Play Families-ready, itemised permissions, no ads, real account deletion | Built; legal pages and Play documents written, [[FILL]]s and lawyer review left |
| 8 | Check my answer: a photo of a written answer marked by the CBSE / ICSE scheme, point by point | Built (Scan D3) |

---

## 2. Decisions made

| Date | Decision |
|---|---|
| 2026-09-25 | **ACADEMe Pro on RevenueCat.** One Play subscription `academe_pro`: `monthly` ₹200 with intro offer `first-month` ₹100, `annual` ₹1,999 (headline; "about ₹167/month · save 17%" only as small text). Entitlement `academe_pro`, offering `default` (`$rc_monthly`, `$rc_annual`). Closes D6. |
| 2026-09-25 | **Free vs Pro.** Free: every lesson, revision, folders, reminders, ASKMe 10 messages/day, Scan 3 reads/day, Check my answer 1/day, "just keep the notes". Pro: unlimited, lessons from notes, and future Pro features (mock exams, weekly parent report). Day resets at IST midnight. Server is the authority on limits; RevenueCat on who paid. |
| 2026-09-25 | Sandbox purchases grant Pro only to accounts in `ACADEME_BILLING_TESTERS` (`*` on staging). Shipaton judges get a RevenueCat promotional entitlement (no payment). |
| 2026-09-25 | **Hosting: Railway, Singapore** (`asia-southeast1-eqsg3a`), project `academe-cc`, Pro plan before launch; move to Mumbai only if latency or residency demands it. Closes D4. |
| 2026-09-25 | **Email: Resend** from `ACADEMe <no-reply@academe.cc>`, reply-to support@academe.cc; domain `academe.cc` verified. Closes D5. |
| 2026-09-25 | **Password reset = 6-digit code + one-tap link** in the same email (15 min, 5 attempts shared); a web reset page on academe.cc for phones without the app. Reset, password change, Google link and deletion revoke every token at once (`tokens_valid_after`). |
| 2026-09-25 | **Syllabus catalogue is data**: `server/internal/syllabus/data/<board>-<class>.json`, session 2026-27. ICSE/ISC files follow the exam each class sits (Class 10 → 2027, Class 9 → 2028; ISC 12 → 2027, ISC 11 → 2028). Chapter IDs are stable lesson IDs. Formative-only chapters show "Not in board exam". |
| 2026-09-25 | **Lesson pipeline**: Sarvam `sarvam-105b` writes (reasoning off) and reviews (reasoning on); code checks + up to 5 writer replies + 2 review rounds; approved decks are served, drafts never; hand-written seeds are never overwritten; a teacher spot-checks `content-review/index.html`. Git is the version history. |
| 2026-09-25 | Seeds aligned to the syllabus plan: `cbse-10-science-9-1` Spherical mirrors, `9-2` Mirror formula, `cbse-10-maths-3-3` Substitution. The old "Reflection" and "What a pair is" seeds are retired. |
| 2026-09-25 | **Play: target audience 9–12, 13–15, 16–17** (Families policy applies). No ads, no advertising ID (`AD_ID` stripped), nothing "shared" in Data safety. No child-safety page (no user-to-user features). India only for 2.0.0; staged rollout 10% → 50% → 100%. |
| 2026-09-25 | Pebby answers carry a **Report** action (Play generative-AI policy). |
| 2026-09-25 | Notifications: a **primer sheet** before the OS prompt, shown once, only when there is something to send; Me offers "Turn on" or "Turn on in Settings". |
| 2026-09-25 | **No other brand names anywhere** in the repo, docs or data; competitor material removed. Pebby (name, art, rig, motion) is ours; no trademark check needed. |
| 2026-09-25 | All design previews live in one page, `design/preview/index.html`, with Chosen / Explored badges. |
| 2026-09-25 | UI journeys are automated with `integration_test/` + `tool/ui_test.sh` on the Pixel 10; the emulator belongs to the UI test agent. |
| 2026-09-25 | Migrations: 0011–0018 are unused; new migrations take numbers after 0022 (or stay independent of 0019–0022). |
| 2026-09-25 | **Study = Courses + Folders.** Courses teach the syllabus (Subject → Chapter → Lesson → cards). Folders are the student's own: a name and an optional date that makes the plan, the checklist and the reminders; Home's Today card is every folder's tasks for today. Folders **replace the separate exam planner** (Phase 8). |
| 2026-09-25 | **Lessons v1 are text only.** Card types: start, concept (with a "Remember" line), table, worked example (steps revealed one tap at a time), quick check, here's why, summary. Diagrams and video are later upgrades in the same player. |
| 2026-09-25 | **Keep and revise.** Keep and Ask Pebby on every card; every missed question is kept; one revision queue (Didn't know / Almost / Knew it). XP only for right quiz answers (+5, once per question). |
| 2026-09-25 | Scan = direction **B · choose first**: Solve · Check my answer · Notes · Ask; photos never stored. |
| 2026-09-25 | Proper icons only (Material), no emoji in the product. |
| 2026-09-25 | Reminders are local notifications: one bundled evening nudge at the student's time, "in 3 days" and "tomorrow" before a folder's date, a 7 am nudge on the day. |
| 2026-09-25 | Appearance: Light and Dark (the splash colour #171726); sign-in screens stay light. |
| 2026-09-24 | Home = direction 1 "Today"; nav = F3 floating pill (Home · ASKMe · Study · Me) + a separate Scan key; ASKMe = A1 (Explain · Solve · Quiz me); Me = L1. |
| 2026-09-24 | Students: **Class 6–12**. Boards: **CBSE, ICSE** (ISC for 11–12). More only when asked. |
| 2026-09-24 | Launch languages: **English, Hindi, Telugu, Tamil, Bengali**. |
| 2026-09-24 | Language vendor: **Sarvam** (chat, translation, speech, OCR), called only from the Go server. |
| 2026-09-24 | Build order: **competitor parity → multilingual → swipe learning at scale**. |
| 2026-09-24 | Onboarding: **setup sheet + checklist** (language, age, class, board; +25 XP each, +100 in total). Personalise with Pebby parked. |
| 2026-09-24 | App is **ACADEMe**, package `com.academe.flutter`, shipped as an update to the existing Play listing (last upload 1.0.5+6; rebuild is 2.0.0+7). |
| 2026-09-24 | Firebase: a new project, later. Upload keystore: only when releasing. |
| 2026-09-24 | API routes carry **no version prefix**; the API only changes additively. |
| 2026-09-24 | **No comments** in code or config, app or server. |
| 2026-09-24 | Backend: **Go + PostgreSQL** (`server/`), stdlib HTTP, pgx, argon2id, 15-min access token + 30-day rotating refresh token. |
| 2026-09-22 | ACADEMe runs only on the **Pixel 10 emulator** for sign-off. Previews are local HTML in `design/preview/`, never published. |

---

## 3. How we work

1. **Preview** — mock it in `design/preview/index.html` (local HTML, one page), open it, get approval.
2. **Build** — app (MVVM per `AGENTS.md`) and, if it needs data, the server endpoint (per `server/AGENTS.md`) and `openapi.yaml` (additive only).
3. **Check** — `dart format`, `flutter analyze`, `flutter test`; `gofmt`, `go vet`, `golangci-lint`, `go test -race` (with `ACADEME_TEST_DATABASE_URL`), `govulncheck`.
4. **Test** — a second agent reviews and attacks each workstream (`tasks/reports/*-test.md`).
5. **Run** — `tool/ui_test.sh <journey…>` drives `integration_test/` on the Pixel 10 against the local server; screenshots and video in `build/ui-test/<journey>/`.
6. **Brand gate** — the brand grep over the repo prints nothing.
7. **Record** — a report in `tasks/reports/`, a tick below, a line in the change log (§12).
8. **Git** — branch `academe-rebuild`, PR #1 into `main`; commits only when the user asks.

---

## 4. Architecture today

| Layer | What | Where |
|---|---|---|
| App | Flutter 3.41, MVVM (`ChangeNotifier` view models, repositories, services), `Result` + `Command`; features: auth, home, askme, scan, study, me, paywall, notifications, shell, splash | `lib/` |
| App packages | rive, http, shared_preferences, flutter_secure_storage, google_sign_in, flutter_local_notifications, timezone, image_picker, url_launcher, purchases_flutter (RevenueCat, Play Billing 8.3). lottie and audioplayers removed | `pubspec.yaml` |
| Animation | Rive (`pebby.riv` generated by `design/mascot/rive/`, poses 0–52); celebrations are our own `Burst` (`CustomPaint`) | `assets/academe/mascot/`, `lib/ui/core/ui/celebration.dart` |
| Design system | `AppColors`, `AppPalette` (light / dark), `AppTextStyles`, `AppKeycap`; Baloo 2 / Archivo / Noto Sans | `lib/ui/core/themes/app_theme.dart` |
| Session | refresh token + account (`hasPassword`, `googleEmail`) in `flutter_secure_storage`, access token in memory, one retry on 401 | `lib/data/` |
| Deep links | `https://academe.cc/reset-password?c=` (autoVerify), `academe://reset`, `academe://open`; `DeepLinkFilter` | `lib/routing/deep_links.dart`, `AndroidManifest.xml` |
| Server | Go, `net/http` mux, pgx pool, embedded migrations, slog JSON; packages auth, profile, chat, study, folder, scan, sarvam, billing, email, site, syllabus, lessons, httpx, config, postgres | `server/internal/` |
| Commands | `academe-api` (the server), `academe-lessons` (the lesson generator) | `server/cmd/` |
| Migrations | 0001–0010, 0019 reports, 0020 token revocation, 0021 google email, 0022 reset links (0009 reset, 0010 billing). 0011–0018 unused | `server/internal/postgres/migrations/` |
| Database | `accounts` (+ `tokens_valid_after`, `google_email`), `sessions`, `profiles`, `xp_events`, `chat_threads`, `chat_messages`, `chat_reports`, `deck_completions`, `deck_positions`, `kept_cards`, `chapter_results`, `folders`, `folder_items`, `folder_todos`, `scans`, `user_decks`, `password_reset_codes` (+ `link_hash`), `subscriptions`, `billing_events`, `usage_counts`, `deletion_requests` | |
| Syllabus | 14 JSON files (CBSE 6–12, ICSE 6–10, ISC 11–12), validated at start-up; 5,777 planned lessons | `server/internal/syllabus/data/` |
| Lesson content | 3 hand-written seeds + generated decks in `decks/<board>-<class>/`; drafts keep a `.review.json`; only approved decks served; a bad deck file is skipped at runtime, fails CI | `server/internal/study/decks/` |
| Public site | `/`, `/privacy`, `/terms`, `/support`, `/delete-account` (+ POST), `/reset-password` (GET/POST), `/open`, `/email/{name}`, `/.well-known/assetlinks.json` | `server/internal/site/` |
| Email | Resend; themed HTML + text: reset (code + link), Google-only, welcome, deletion notice | `server/internal/email/` |
| API contract | `server/openapi.yaml` (52 paths) | |
| Hosting | Railway project `academe-cc`, services `api` + `Postgres` (PITR on), Singapore; `https://api-production-ac92.up.railway.app` | `server/railway.json`, `docs/hosting.md` |
| Android permissions | `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `ACCESS_NETWORK_STATE` (RevenueCat), `com.android.vending.BILLING`; `VIBRATE` and `AD_ID` stripped | `android/app/src/main/AndroidManifest.xml` |
| iOS | project builds (`flutter build ios --no-codesign --debug`); notification delegate wired; not signed, no App Store products | `ios/` |
| App config | `--dart-define`: `API_BASE_URL` (release default `https://api.academe.cc`, debug `http://10.0.2.2:8080`), `GOOGLE_SERVER_CLIENT_ID`, `REVENUECAT_GOOGLE_API_KEY`, `REVENUECAT_APPLE_API_KEY`, `REVENUECAT_ENTITLEMENT` | `lib/config/environment.dart` |
| Server config | `ACADEME_DATABASE_URL`, `ACADEME_TOKEN_KEY`, `ACADEME_ADDR`/`PORT`, `ACADEME_CLIENT_IP_HEADER`, `ACADEME_SARVAM_API_KEY`, `ACADEME_SARVAM_MODEL`, `ACADEME_GOOGLE_CLIENT_IDS`, `ACADEME_RESEND_API_KEY`, `ACADEME_EMAIL_FROM`, `ACADEME_EMAIL_DEV`, `ACADEME_ANDROID_CERT_SHA256`, `ACADEME_REVENUECAT_SECRET_KEY`, `ACADEME_REVENUECAT_WEBHOOK_AUTH`, `ACADEME_REVENUECAT_ENTITLEMENT`, `ACADEME_BILLING_TESTERS`, `ACADEME_FREE_LIMITS` | `server/internal/config/config.go` |
| UI tests | 21 journeys in `integration_test/` (+ `support/`), runner `tool/ui_test.sh` | |
| Not yet | object storage for uploads, FCM, analytics, crash reporting, streak server, moderation filter | |

---

## 5. Built so far

**Entry and onboarding**
- [x] Splash, Welcome (Pebby peeking over the sheet), email sign-up (5 steps, Pebby reacting), email log-in, session restore, log-out
- [x] Google sign-in wired end to end (needs Google Cloud client IDs)
- [x] Setup sheet + dashboard checklist: language, birth year, class dial, board; +25 XP each, +100 flying into the XP chip
- [x] Forgot password → 6-digit code (autofill, paste, 30 s resend, lockout) → new password → signed in; reset link from the email opens New password in the app (cold or warm)

**Shell and Home**
- [x] Floating nav pill (Home · ASKMe · Study · Me) + separate Scan key; the pill turns into the ask bar on ASKMe
- [x] Home: greeting + class · board, streak + XP chips, ask field, quick actions, **Today card**, subjects

**ASKMe**
- [x] Chat with Pebby (Explain · Solve · Quiz me), answers in the profile language, thumbs, copy, retry, history with search, attach sheet; Sarvam with reasoning off
- [x] Report on every Pebby answer (wrong, harmful, offensive, other) → `chat_reports`
- [x] Free limit 10 messages/day (retry counts); the failed bubble offers Go Pro

**Study — Courses (swipe lessons)**
- [x] Courses: every syllabus chapter for the student's class and board; written lessons playable, unwritten ones greyed "Coming soon"; "Not in board exam" on formative-only chapters
- [x] Chapter page, lesson player (seven text card types, Keep + Ask Pebby, resume), quick checks with +5 XP, lesson done, chapter test + report, revision queue
- [x] Content live: 6 lessons, Class 10 CBSE — Maths 1-1 Prime factorisation, 1-2 Irrational numbers, 3-3 Substitution; Science 1-2 Types of reactions, 9-1 Spherical mirrors, 9-2 Mirror formula. 2 drafts held back (Science 1-1, 1-3)

**Study — Folders**
- [x] Folders list, new/edit/delete, chapters, notes, to-dos, plan from the date, Today checklist, reminders

**Scan (direction B · choose first)**
- [x] Solve · Check my answer · Notes · Ask; camera or gallery (photo picker, no permissions); up to 10 pages; Sarvam Document AI reads, the student fixes the text
- [x] Check my answer marks by the CBSE / ICSE scheme; Notes → a swipe lesson (Pro) or just the notes (free); photos never stored
- [x] Free limits: 3 reads/day, 1 check/day; Pro-only lesson from notes with "Just keep the notes"

**Me, account and settings**
- [x] Me (L1), Class and board, App language, Appearance, Reminders and daily goal, Help (support@academe.cc)
- [x] Account: Change password (or Set a password for Google-only), Link / Unlink Google, all other devices signed out on change
- [x] Notifications: primer sheet once, Allowed / Turn on / Turn on in Settings, reschedule on resume (Android 13+ and iOS)
- [x] Privacy and terms: summary + links to the web documents, "Get a copy of my data" (by email), Grievance Officer
- [x] Delete account: reason, typed DELETE, 30-day grace, hourly purge (also deletes the RevenueCat customer); notice that Play subscriptions must be cancelled in Play, Manage subscription for Pro

**ACADEMe Pro**
- [x] Paywall (Pebby, benefits, Monthly / Annual tiles with store prices and intro phase, Restore), Manage screen, Pro card on Me, limit sheet
- [x] Server: `GET /me/plan`, `POST /billing/sync` (RevenueCat REST v2), `POST /billing/revenuecat/webhook` (all event types, idempotent, ordered, sandbox gated), atomic daily usage counts with refunds

**Web and email (academe.cc)**
- [x] Landing, privacy, terms, support, delete-account form (limits, no account enumeration), web reset page (cookie + HMAC form token), `/open`, assetlinks
- [x] Themed emails (reset with code + button, Google-only, welcome, deletion notice) matching the app's keycap look, light and dark

**Content pipeline**
- [x] Syllabus catalogue: 14 files, 5,777 planned lessons, validated; `GET /study/decks` returns `chapters` (gzipped)
- [x] `academe-lessons` generator: writer + reviewer on Sarvam, resumable, backoff, stops on 401/402/403, teacher review page

**Server, hosting and Play groundwork**
- [x] Auth (+ reset, token revocation, settings), profile, catalogue, chat, study, folders, scans, billing, site, email; tests incl. real Postgres and race tests
- [x] Deployed to Railway (Singapore): API, public pages, sign-up, profile and Scan verified live
- [x] Play documents in `docs/play/`: data safety, content rating, target audience, store listing, subscriptions, AI content, DPDP, App Store privacy, release checklist
- [x] 16 KB pages, edge-to-edge, no orientation lock, minimal permissions, backups off
- [x] Competitor artwork, sounds and animations removed (121 files); no other brand names in the repo

**Testing**
- [x] 193 app tests, full server suite green
- [~] 21 UI journeys automated on the Pixel 10; the full run is in progress (§11)

---

## 6. What's next, in order

1. **Shipaton submission (30 Sep 2026)** — upgrade Railway to Pro, point academe.cc DNS, set the RevenueCat secrets and webhook, redeploy the current build, internal-testing build with the RevenueCat key, promotional Pro for judges. Checklist in §11.
2. **Sarvam credits → lessons** — top up (₹10–13k for one full pass, plus live ASKMe/Scan), smoke run (CBSE 10 science 9: Refraction, Lenses), then generate Class 10 and 12 first, then everything; teacher spot-check drafts first.
3. **Fix what the UI run finds** — F2 (Add chapters opens on an empty subject), the failing journeys once the run finishes, F1 re-check against production.
4. **Launch hardening** — rate limits on log-in and sign-up, limiters in Postgres before a second instance, [[FILL]]s, lawyer review, monochrome notification icon, focus rings, width cap.
5. **Play release 2.0.0** — the `docs/play/release-checklist.md` steps, internal → closed (20+ students) → staged production, India only.
6. **Streaks and levels** (Phase 6) — real streak, streak saver, level-up moment.
7. **Scan, part 2** — crop, blur check, offline queue, PDFs, similar question, revision cards / quiz from notes, Report on marks.
8. **Stage 2 — languages** — app text, emails and policy pages in five languages; lessons translated and checked.
9. **DPDP by 13 May 2027** — consent notice and records, verifiable parental consent, DPAs, breach runbook.

---

## 7. Stage 1 — competitor parity

IDs: **A** entry · **B** onboarding · **C** shell and companion · **D** capture
· **E** study · **F** progress · **G** settings · **H** money. `[~]` = partly built.

### Phase 1 — Entry and auth

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | A1 | Splash | |
| [x] | A2 | Welcome + sheet | Pebby peek |
| [x] | A3 | Provider options | Google / email |
| [x] | A4 | Sign-up (email) | 5 steps; welcome email |
| [x] | A5 | Log-in (email) | |
| [x] | A6 | Forgot password | email pre-filled; 202 whatever the email |
| [x] | A7 | Check your email | 6 digits, autofill, paste, 30 s resend, 5 tries |
| [x] | A8 | Reset password | 8+ check; lands signed in; all old tokens revoked |
| [x] | A8b | Reset link | email button → app (App Link / `academe://`) or the web page |
| [ ] | A9 | Google switched on | client IDs; test on a device |
| [x] | A10 | Rate limits on log-in and sign-up | log-in 10/15 min per email+IP and 50/h per IP; sign-up 10/h and Google 30/h per IP; 429 + `Retry-After` |
| [x] | A11 | Purge expired sessions and old reset rows | hourly from `PurgeEvery`; reset rows kept a day past expiry |
| [ ] | A12 | "Your password was changed" / "Google linked" email | Resend mailer |
| [ ] | A13 | Localised emails | hi, te, ta, bn; Indic web fonts |
| [ ] | A14 | Reset email from the background queue | removes the timing difference |
| [ ] | A15 | SMS Retriever / one-tap code autofill | Android |

### Phase 2 — Onboarding

| | ID | Task | Notes |
|---|---|---|---|
| [x] | S1–S4 | Language, age, class, board | setup sheet + checklist, +25 XP each |
| [x] | L3–L4 | Ticks and the +100 finish | |
| [x] | D1 | Ask-bar hint | once |
| [ ] | P1–P5 | Personalise with Pebby (parked) | subjects swipe, goal, daily goal, reminder, Day 1 streak |
| [ ] | — | Onboarding taster | a 3-card lesson before streak day one |
| [ ] | — | State boards | "coming soon" in the board step; only when asked |

### Phase 3 — Shell and AI companion

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | C1 | App shell | floating pill + Scan key; pill becomes the ask bar |
| [~] | C2 | Home | built: greeting, ask field, quick actions, Today card, subjects. Left: Continue card, subjects open their course, the "coming soon" tiles |
| [~] | C3 | ASKMe | built + Report + free limit. Left: streaming, maths rendering, attachments beyond camera/photos, voice, flashcards from a chat, save to folder, "Go deeper", Pro badge and "3 of 10 left" hint |
| [~] | C4 | Chat history | built: list, search, reopen. Left: rename, delete |
| [ ] | C5 | First-steps cards | cold-start suggestions |
| [ ] | C6–C7 | Search | across lessons, folders, chats |
| [x] | C8 | Daily free uses | replaced tickets: server limits + limit sheet |
| [ ] | C9 | Output moderation | keyword filter in five languages, self-harm helpline answer, red-team before launch |

### Phase 4 — Capture (Scan)

Designed in `design/preview/index.html` (Scan section). Everything runs on
Sarvam (Document AI to read, chat to label, solve, mark and make lessons);
photos are not stored.

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | D1 | Scan tab | four jobs + recent scans; camera or gallery; chapter label; failure states |
| [x] | D2 | Solve | fix what was read → ASKMe Solve (hint first) |
| [x] | D3 | Check my answer | board marking, what's missing, model answer, re-check |
| [x] | D4 | Notes | up to 10 pages → folder → swipe lesson (Pro) or just the notes |
| [x] | D5 | Ask | photo text + question into ASKMe |
| [x] | D6 | Scan limits | 3 reads, 1 check a day on Free; Go Pro in the problem view |
| [ ] | D7 | Scan part 2 | crop, blur check, offline queue, PDF, similar question, save to folder, suggested folder, revision cards and quiz from notes |
| [ ] | D8 | Report on marks and on lessons from notes | extends the Report action |
| [ ] | D9 | Storage and scaling plan | if photos or PDFs are ever kept |

Server: `POST /scans` (multipart, up to 10 pages of 8 MB), `GET /scans`,
`GET /scans/{id}`, `PUT /scans/{id}/thread`, `POST /scans/{id}/check`,
`POST /scans/{id}/notes`; migration 0008. Without the Sarvam key every scan
returns 503 `scan_unavailable`.

### Phase 5 — Study

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | E1 | Courses | full catalogue; coming soon; not in board exam |
| [x] | E1b | Chapter page | planned lessons in order, unwritten greyed |
| [x] | E2 | Lesson player | seven text card types, keep, ask, resume |
| [x] | E3 | Chapter test + report | |
| [x] | E4 | Revision queue | kept + missed cards, spaced |
| [x] | E12 | Folders v1 | chapters, notes, to-dos, plan, today, reminders |
| [ ] | E5 | Folders v2 | scans, photos and PDFs in a folder, made into a lesson, flashcards or a quiz |
| [ ] | E6 | Flashcards from anything | from a chat, a scan or a folder |
| [ ] | E7 | Mock exam (Pro) | past papers, timed, board marking (Class 10 and 12) |
| [ ] | E8 | Chat with a folder | ASKMe grounded in the folder |
| [ ] | E9 | Share a folder | link for messaging apps; friends get a copy |
| [x] | E10 | Add chapters: default to a subject with lessons | UI finding F2; only subjects with lessons are offered |
| [ ] | E11 | "Coming soon" counts on subject pills | |
| [ ] | E13 | Edit folder notes | today only delete |

### Phase 6 — Progress and reward

| | ID | Screen | Notes |
|---|---|---|---|
| [ ] | F1 | Streak | real streak days, calendar, freeze, streak saver reminder (the Me toggle schedules nothing yet) |
| [ ] | F2 | Level up | full-screen, Pebby (the Me toggle schedules nothing yet) |
| [ ] | F3 | Leaderboard | weekly, by class |
| [ ] | F4 | Achievements | badges |
| [ ] | F5 | Weekly report (Pro) | shareable to a parent through messaging apps |
| [ ] | F6 | Answer sounds | our own (the old clips were removed) |

### Phase 7 — Settings and account

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | G1 | Me | L1 + Pro card |
| [~] | G2 | Edit profile | name, class + board. Left: subjects |
| [~] | G3 | Account | change / set password, link / unlink Google built. Left: sign out everywhere, live refresh of a link made on another device |
| [x] | G4 | Reminders, daily goal, notifications | primer, access state, Settings deep link |
| [~] | G5 | Language | saved and used by Pebby. Left: app text (Stage 2) |
| [x] | G6b | Appearance | Light / Dark |
| [~] | G6 | Privacy and legal | documents and links built. Left: `GET /me/export` (today by email) |
| [x] | G7 | Delete account | in-app + web page + Play subscription notice. Left: signed "confirm deletion" link in the web email |
| [ ] | G8 | iOS notifications | provisional authorisation option; device check |

### Phase 8 — Exam planner

Replaced by folders (decided 2026-09-25). Left: the board-exam date filled in
for Class 10 and 12, and a "missed classes" catch-up folder shortcut.

### Phase 9 — Money (ACADEMe Pro)

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | H1 | Paywall | monthly (₹100 then ₹200) + annual (₹1,999), store prices, Restore |
| [x] | H2 | Purchase + sync | RevenueCat SDK with our account id; `/billing/sync` |
| [x] | H3 | Limits | server-side counts, 402 `limit_reached` / `pro_only`, limit sheet |
| [x] | H4 | Manage | plan, renew / end date, billing issue, Manage in Google Play |
| [x] | H5 | Webhooks | every RevenueCat event, sandbox gate, transfers, grace periods |
| [ ] | H6 | iOS purchases | App Store Connect group, `.p8` key, Apple copy and Manage URL, In-App Purchase capability |
| [ ] | H7 | Price test | RevenueCat Experiments |
| [ ] | H8 | Retry queue for failed RevenueCat customer deletions | today logged, done by hand |
| [ ] | H9 | Paywall polish | "save 17%" computed per currency, annual caption on narrow phones, Restore feedback on Manage, limit sheet re-opening on scroll |

**Stage 1 done when:** the 15 student journeys that don't need languages work
end to end in English on the Pixel 10 (6 of 15 checked 25 Sep: 2, 3, 4, 9,
10, 15; see the Journeys section of `design/preview/index.html`).

### Competitor features we skip or defer

| Feature | Why |
|---|---|
| Peer notes feed, creators, likes | needs a community and moderation |
| Metered AI "generations" on lessons | against "fair"; only Pebby and Scan are metered |
| Podcasts, video summaries, study songs | not needed |
| Study groups, topic chats | social surface for minors needs moderation first |
| Timetable import, foreign colleges and exams | not our market |

---

## 8. Stage 2 — Multilingual

| | Task | Notes |
|---|---|---|
| [ ] | App text in ARB files | every string out of widgets |
| [ ] | Five languages | drafted with Sarvam, reviewed by native speakers (D3) |
| [ ] | Live switching | from the profile, no restart |
| [ ] | Lessons in five languages | translated per lesson, stored, reviewed; exam terms kept in English |
| [ ] | Emails and web pages | reset, welcome, deletion, privacy, terms in the student's language |
| [ ] | Store listing | localised listings in Play |
| [ ] | Layout checks | Telugu and Tamil at 1.3× |
| [ ] | Voice | speech-to-text in the ask field; listen to answers and cards |
| [ ] | Hinglish | test and prompt for mixed-language questions before claiming it |
| [ ] | Sarvam data terms | retention and training use confirmed before student data is sent (also Data safety "ephemeral") |

---

## 9. Stage 3 — Swipe learning at scale

| | Task | Notes |
|---|---|---|
| [x] | Syllabus map | 14 files, CBSE + ICSE/ISC 6–12, 5,777 planned lessons, sources on every chapter |
| [x] | Lesson pipeline built | `academe-lessons`, prompt `lessons-v4`, writer + reviewer, drafts, review page |
| [ ] | Full generation run | blocked on Sarvam credits; ~100 h at 6 workers, ~₹10–13k |
| [ ] | Teacher review | `content-review/index.html`, drafts first; the teacher checks listed in §11 |
| [ ] | Second reviewer model | cross-check, or two reviewers |
| [ ] | Originality check | n-gram overlap against textbook text |
| [ ] | `-recheck` mode | rerun code checks on approved decks after rule changes (CI covers it today) |
| [ ] | Yearly syllabus roll | ICSE 10 → 2028 syllabus, ISC 12 → 2028 text in 2027-28; CBSE 9 Part II books when published |
| [x] | Swipe player, card types, quick checks, why, keep, resume | text only |
| [x] | Chapter test and report | |
| [x] | Revision (spaced repetition) | |
| [ ] | Diagram cards | in-app templates from a diagram description; designer-drawn biology library |
| [ ] | Video cards | short vertical "Pebby explains"; price one render first (D9) |
| [ ] | Listen cards | voice |
| [ ] | Learn feed on Home | short-video-style feed from your chapters |
| [ ] | Offline chapters | download for low data |
| [ ] | First-time swipe hint | |

---

## 10. Release checklist (Play)

Full order in `docs/play/release-checklist.md`.

- [x] Version 2.0.0+7 (above 1.0.5+6); targetSdk 36, minSdk 24
- [x] 16 KB pages (release APK checked; re-check after each native plugin)
- [x] Edge-to-edge, no orientation lock
- [x] Permissions: `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `ACCESS_NETWORK_STATE`, `BILLING` only; no `AD_ID`
- [x] Competitor artwork, sounds and animations removed
- [x] Privacy, terms, support and delete-account pages built; Report on AI answers
- [x] Data safety, content rating, target audience, listing, subscription and AI answers written (`docs/play/`)
- [ ] [[FILL]] placeholders filled; lawyer review
- [ ] academe.cc and www serve the pages; api.academe.cc over HTTPS
- [ ] Upload keystore wired (`android/key.properties`, never committed), same upload key as 1.0.5
- [ ] `ACADEME_ANDROID_CERT_SHA256` set (upload + app signing) so reset links open the app
- [ ] Monochrome notification icon
- [ ] Large screens: width-capped content, landscape welcome layout
- [ ] Keyboard focus rings on custom buttons
- [ ] Reviewer account `play-review@academe.cc` with content
- [ ] Play Console forms submitted; subscription products active; RevenueCat live
- [ ] Internal testing on a real phone, pre-launch report clean, closed test with students
- [ ] Parental consent for under-18s (DPDP, 13 May 2027) — D1

---

## 11. Open decisions, needs the user, known issues

### Open decisions

| # | Question |
|---|---|
| D1 | Parental consent method (DPDP Rule 10, from 13 May 2027), with legal advice. |
| D2 | LLM for Pebby and for reviewing lessons: Sarvam alone, or a second model for hard maths and cross-review? |
| D3 | Who reviews Hindi, Telugu, Tamil and Bengali text and lessons (and the Hindi / Sanskrit syllabus topics)? |
| D7 | Existing users of the old app: migrate or start fresh? |
| D8 | Rewards: what can XP buy, if anything? Until decided, XP only drives levels. |
| D9 | Video lessons: price one render per topic per language before committing. |
| D10 | USP 6 wording vs the Free limits on ASKMe / Scan / Check (listing and site say the limits plainly). |
| D11 | Keep RevenueCat's `ACCESS_NETWORK_STATE` (harmless, stripping risks crashes)? Default: keep. |
| D12 | Hindi Course B (CBSE 10) and Maths/Science Advanced (CBSE 9): add when asked? |
| D13 | ISC Class 11 "Commerce (Business Studies)" label; hide PE Section B games unless picked? |
| D14 | Listing mentions the ₹100 first month; drop it if Play review objects. |
| D15 | Mumbai hosting later if latency or data residency is required. |
| Closed | D4 hosting → Railway Singapore · D5 email → Resend · D6 pricing → Pro on RevenueCat (§2) |

### Needs the user (one checklist)

**Money and keys**
- [ ] Top up **Sarvam credits** (out since 21:20 IST; ASKMe and Scan in production fail too until then). Full lesson pass ≈ ₹10–13k.
- [ ] Google OAuth clients (web, Android with debug + Play-signing SHA-1, iOS) → `ACADEME_GOOGLE_CLIENT_IDS` on Railway, `GOOGLE_SERVER_CLIENT_ID` in the app build.
- [ ] RevenueCat on Railway: `ACADEME_REVENUECAT_SECRET_KEY` (v2 secret key) and `ACADEME_REVENUECAT_WEBHOOK_AUTH` (commands in `tasks/reports/deploy.md`).
- [ ] RevenueCat public key `goog_…` into the release build (`REVENUECAT_GOOGLE_API_KEY`); Test Store key only in debug builds.
- [ ] Release keystore: the **existing upload key** in `android/key.properties` (or request an upload key reset in Play).
- [ ] `ACADEME_ANDROID_CERT_SHA256` = upload key + Play app signing SHA-256, comma-separated.

**Railway**
- [ ] Upgrade the workspace from Hobby trial to **Pro** ($20/month); set `railway usage limit set --target workspace --soft 40 --hard 50`.
- [ ] Add domains `academe.cc` and `www.academe.cc` (blocked on Hobby: 1 custom domain per service).
- [ ] Turn on **Daily and Weekly backups** (Pro only; today only PITR), rehearse one restore, keep an encrypted off-platform `pg_dump`.
- [ ] Redeploy the current build (includes the ASKMe reasoning fix and the reset 202 fix) and re-test ASKMe, Scan solve and a reset email.
- [ ] External uptime monitor on `/healthz` (Railway checks only at deploy).
- [ ] Delete the old `ACADEMe` Railway project when no longer needed; connect GitHub auto-deploys (root `/server`) after merge.

**DNS (Namecheap, academe.cc → Advanced DNS)**
- [ ] Delete the two apex A records (parking `162.255.119.53`, the old site host `216.198.79.1`) and the old `www` CNAME; keep MX `eforward*` and the SPF TXT.
- [ ] Add `CNAME api → qk1tncxf.up.railway.app` and `TXT _railway-verify.api` (value in `deploy.md`).
- [ ] After the Pro upgrade: `ALIAS @` and `CNAME www` to the printed Railway targets, plus their `_railway-verify` TXT records.
- [ ] Optional: DMARC `TXT _dmarc` `v=DMARC1; p=none; rua=mailto:support@academe.cc`, tighten later.

**Play Console**
- [ ] Subscription `academe_pro`: base plans `monthly` ₹200 (grace period + account hold) and `annual` ₹1,999; offer `first-month` ₹100 for new customers; activate.
- [ ] License testers; an internal-testing build (versionCode > 6) so Billing finds the product.
- [ ] Service account for RevenueCat (Android Developer API + Reporting API, JSON key, app permissions); up to 36 h to validate.
- [ ] Real-time developer notifications topic via RevenueCat.
- [ ] Payments profile (India payouts).
- [ ] App content: privacy URL, app access (reviewer account), ads No, content rating, target audience 9–17, Data safety, advertising ID No, other declarations.
- [ ] Store listing text (`store-listing.md`), icon, feature graphic, 4–8 screenshots; countries India only.
- [ ] Reviewer account `play-review@academe.cc` (Class 10 CBSE, one folder, one finished lesson).

**RevenueCat dashboard**
- [ ] Play app with the service-account JSON; import `academe_pro:monthly` and `:annual`; entitlement `academe_pro`; offering `default` (`$rc_monthly`, `$rc_annual`).
- [ ] Webhook `https://api.academe.cc/billing/revenuecat/webhook` (the Railway URL until DNS is live) with the same Authorization value; all events, both environments.
- [ ] **Shipaton judges:** promotional entitlement `academe_pro` on their account UUID (or Play promo codes, or license testers).
- [ ] Confirm the v2 parser against one real customer with an entitlement (curl recipe in `pro-plan-test.md`).
- [ ] Check RevenueCat's terms for a child-directed-services clause.

**Legal and support**
- [ ] Fill every `[[FILL]]`: legal name, registered address, Grievance Officer name and postal address, court city, Sarvam's retention answer (`grep -rn "FILL:" server/internal/site/pages` must print nothing).
- [ ] Lawyer review of `docs/play/dpdp.md` (s.9(3) "behavioural monitoring", Rule 8(3) one-year retention vs our 30-day purge), then DPAs with Sarvam, Railway, Resend, RevenueCat.
- [ ] Ask Sarvam: chat and Document AI retention, training use, job-file deletion.
- [ ] Make support@academe.cc a monitored inbox; weekly review of `chat_reports` and `deletion_requests`.

**Content and devices**
- [ ] A teacher spot-checks `server/content-review/index.html` (drafts first) after each generation batch.
- [ ] Teacher checks from the syllabus reports: ICSE Maths 6–7 chapter numbering (new Selina editions), ICSE 6–8 Hindi units, Class 8 Computer "App Development" tool, ICSE 9–10 book chapter splits and added context topics, ISC Accounts 12 (2027 cohort), ISC Commerce label, CBSE 6–8 Hindi / Sanskrit wording with a native reader.
- [ ] iPhone or simulator check of the notification prompt and Settings deep link; Apple team for signing.
- [ ] Not needed: a trademark check for Pebby (ours).

### Known issues and limits

| Area | Issue | Fix / next step |
|---|---|---|
| Content | 6 lessons live, 5,771 to generate | full pipeline run (§6.2) |
| Content | Sarvam 402: no credits | top up; rerun resumes |
| Content | ~50% approved first pass; drafts mostly "too close to textbook wording" or drift into the next lesson | rerun retries; teacher review |
| Content | Reviewer is the same model family; originality is judgement only; literature lessons paraphrase copyrighted texts | second reviewer (D2), n-gram check, human look |
| Content | Concurrency above 6 workers untested; a quota reported as 429 would back off per lesson instead of stopping | watch the log for `sarvam retry` |
| Content | CBSE 9 Maths Part II (ch 9–15) and Social Science Part 2 (ch 10–16) are provisional; renumbering would re-point lesson IDs | CI flags drift; regenerate with `-force` |
| Content | Gaps: Hindi Course B, Maths/Science Advanced, Class 6 R3 books, practicals and projects, ISC English literature | D12; add when asked |
| Content | ICSE 6–8 built from publishers' books (CISCE middle-school document not obtained); ICSE Hindi 6–8 low confidence | re-check when the document is available |
| Content | Syllabus build scripts are not in the repo; edit the JSON directly | |
| Content | Progress on renumbered seed IDs (dev accounts only) attaches to other lessons | harmless before release |
| ASKMe | Empty answers from `sarvam-105b` reasoning (UI F1, deploy) | fixed in code (reasoning off); verify after redeploy |
| ASKMe | No output moderation beyond the prompt; Report only on ASKMe | C9, D8 |
| Study | Streak shows 0 everywhere; streak and level-up toggles schedule nothing | Phase 6 |
| Study | "Done today" uses the phone's date and UTC offset | fine for India |
| Study | Folder notes can't be edited | E13 |
| Auth | Throttles, sync limit and password-check limit live in one process's memory | Postgres/Redis before a second instance |
| Auth | Revocation cache: another instance may accept a revoked access token for up to 30 s | documented; fine at 1 replica |
| Auth | Log-in, sign-up and Google limits are per instance and per IP; a school behind one IP gets 50 log-ins and 10 sign-ups an hour | Postgres/Redis with the other throttles; raise if schools hit it |
| Auth | Log-out ends one session; its access token lives ≤15 min; no "log out everywhere" | G3 |
| Auth | Reset: known accounts answer slower (mail send); verify tells "burned" from "no code"; earlier reset tokens not revoked by a later reset | A14; low risk (sign-up already reveals accounts) |
| Auth | Google sign-in on log-in with a matching email auto-links and clears the password (pre-hijack defence) | student can set one again |
| Auth | Account screen trusts the account cached at launch | G3 |
| Email | English only; Gmail shows fallback fonts; Outlook shows square digit boxes; Baloo 2 font file 421 KB | A13; subset the font |
| Email | A welcome email in flight is lost on a crash | durable outbox if it matters |
| Links | App Links unverified until the cert SHA-256 is set and academe.cc is live (links open the browser page meanwhile) | §11 keys |
| Web | Web deletion finished by hand after the person replies | G7 signed link |
| Web | Data export by email only; policy pages English only | G6; Stage 2 |
| Billing | Failed RevenueCat customer delete on purge must be redone by hand | H8 |
| Billing | Refund across IST midnight lands on the new day; catalogue cache 10 min; subscriptions read without paging (100) | acceptable |
| Billing | Webhook ordering assumes an NTP-synced server clock | Railway default |
| Billing | "save 17%" hard-coded; annual caption can clip; Manage Restore gives no feedback; limit sheet re-opens on scroll | H9 |
| Play | Photos "ephemeral = No" until Sarvam confirms Document AI deletion | Sarvam answer |
| Play | Google Sign-In and RevenueCat flagged for Families SDK review | re-check at submission |
| Hosting | Hobby trial: 1 custom domain per service, no scheduled backups, trial credit runs out | Pro upgrade |
| Hosting | **Backups gap:** PITR only; no scheduled backups, no restore rehearsed, no off-platform copy | Pro + runbook |
| Hosting | academe.cc DNS still on parking / the old site host; only `api` records exist | DNS checklist |
| Hosting | `X-Real-IP` is trusted only while traffic comes through Railway's edge; never add a TCP proxy to `api` | |
| Hosting | No India region (Singapore ≈ 50–90 ms); Postgres major upgrades need dump/restore | D15 |
| Hosting | Profile builds need `--dart-define=API_BASE_URL=https://…` (no cleartext allowance) | |
| App | Router never disposes Home / ASKMe / Study / Me view models (small listener leak per log-out) | router fix |
| App | `courses_view.dart` 306 lines (limit 300); `auth_repository_remote.dart` at 300 | split with the UI test agent |
| App | Reminders use the launcher icon | monochrome icon |
| App | Landscape and tablet stretch full width; no focus ring on custom buttons | width cap; `Keycap` focus |
| App | Rive state-machine inputs deprecated in 0.14 | data binding when Pebby is regenerated |
| App | No sound (competitor clips removed) | F6 |
| iOS | Fresh machines need `dart run rive_native:setup --platform ios`; no signing, products, Universal Links or Apple copy on the paywall | H6 |
| Tests | UI run in progress (12 journeys); so far askme, study, courses, privacy pass; me_settings, revision, folders, scan_solve, scan_check, scan_notes fail (scan likely the Sarvam 402); notifications running | results pending from the UI test agent (`tasks/reports/ui-test-findings.md`) |
| Design | `design/preview/index.html` is 1.4 MB; the onboarding note still recommends 1, 3, 5; Home final layouts undecided; `SHAPE-LANGUAGE.md` links to removed files | tidy |
| Migrations | 0019–0022 are applied before any future 0011–0018 on existing databases | number new ones after 0022 |

---

## 12. Change log

Newest first. One line per change that landed; details live in git and `tasks/reports/`.

**2026-09-25**
- Roadmap rewritten for today's work and `tasks/strategy.md` added (vision, users, USPs with proof, pricing, go-to-market, metrics, risks, 30/60/90).
- UI test automation: 21 `integration_test/` journeys with shared support flows and `tool/ui_test.sh` (screen recording, screenshots, per-journey logs in `build/ui-test/`). Findings so far: F1 ASKMe empty answers (fixed in code), F2 Add chapters empty subject (open). A 12-journey run is in progress.
- Lesson pipeline: `internal/syllabus` loads and validates the 14 files (5,777 lessons); `GET /study/decks` returns every chapter with planned lessons (gzipped); `academe-lessons` writes and reviews lessons on Sarvam (prompt `lessons-v4`, resumable, stops on 402), `-review` renders the teacher page; app shows "Coming soon" and "Not in board exam". Trial on CBSE 10 chapter 1: 23 lessons, 12 approved, 7 drafts, 4 failed, ~62 s per lesson at 6 workers. Sarvam ran out of credits at 21:20 IST. Seeds renumbered to the plan (science 9-1, 9-2; maths 3-3). Tester: GO once credits are topped up.
- Syllabus catalogue for 2026-27: CBSE 6–8 (NCERT books), CBSE 9–10 (new Class 9 books, provisional Part II chapters), CBSE 11–12 (2026-27 curriculum, formative-only chapters), ICSE 6–8 (publishers' books), ICSE 9–10 (2027 / 2028 exam syllabuses), ISC 11–12 (2028 / 2027). Sources are boards and textbook publishers only; confidence and teacher checks in each report.
- Deployed to Railway project `academe-cc` (Singapore, API + Postgres with PITR): health, pages, sign-up, profile and Scan verified live; ASKMe reasoning fix and reset-mail 202 fix landed in code afterwards; domains beyond `api` and scheduled backups blocked by the Hobby plan.
- Hosting prepared: `PORT` fallback, `ACADEME_CLIENT_IP_HEADER` + `TrustClientIP`, pool override, slim distroless image (~27 MB), `.dockerignore` hardened, `railway.json`; release builds default to `https://api.academe.cc`; `docs/hosting.md` runbook.
- Resend domain `academe.cc` verified.
- Themed emails (reset with code + one-tap link, Google-only, welcome, deletion notice), web reset page with cookie + HMAC form token (http-safe cookie fix), `/open`, email assets, `assetlinks.json`; App Links and `academe://` deep links; migration 0022.
- Password reset A6–A8: code by email, 5 attempts, throttles by email and IP (IPv6 by /64), single-use reset token, all sessions revoked; migration 0009; race tests on Postgres.
- Token revocation: `accounts.tokens_valid_after` (migration 0020); reset, password change, Google link and deletion reject older access tokens at once (30 s across instances).
- Account settings: `POST /me/password`, `POST` / `DELETE /me/google`, `hasPassword` and `googleEmail` on `Account` (migration 0021); Change / Set password, Link / Unlink Google; Play subscription notice on Delete account.
- ACADEMe Pro on RevenueCat: `academe_pro` monthly ₹200 (₹100 first month) and annual ₹1,999; free limits (ASKMe 10, Scan 3, Check 1 a day; lessons from notes Pro); migration 0010; REST v2 sync, webhooks with sandbox gating, grace, transfers, promotional grants; paywall, Manage, Pro card, limit sheet; RevenueCat customer deleted on purge.
- Notification primer (Android 13+ and iOS): shown once when there is something to send; Me → Allowed / Turn on / Turn on in Settings; reschedule on resume; existing users keep their state; iOS project builds.
- Legal and Play: public pages on academe.cc (privacy, terms, support with Grievance Officer, delete-account form), Report on Pebby answers (migration 0019), in-app Privacy screen, `AD_ID` stripped, `docs/play/` (Families 9–17, Data safety, DPDP with 13 May 2027 consent date, AI content, subscriptions, listing, release checklist).
- Competitor material removed: 121 asset files (art, badges, animations, sounds), 49 old screenshots, lottie and audioplayers; sign-up confetti is our own `Burst`. Brand scrub: no other app, study website or social platform named anywhere; syllabus sources are boards and publishers; Pebby's docs claim no outside source.
- Design previews merged into one page, `design/preview/index.html`, with a table of contents and Chosen / Explored badges; the 18 old pages retired.
- Git: branch `academe-rebuild` with three commits (rebuild; emails, settings and billing fixes; lesson pipeline and syllabus), PR #1 open into `main`.
- Scan built as direction B (choose first), all on Sarvam: shared `internal/sarvam` client (chat + Document AI digitise), `internal/scan` (read, list, link thread, check with board marking, notes → folder + generated lesson validated by `study.Validate`, one retry), user lessons in study and folders, migration 0008, OpenAPI; app Scan tab, camera/gallery via `image_picker`, read-and-fix screen, marks screen, notes-to-folder, entry points from Home, ASKMe attach and folders. 105 app tests and the server suite pass; on the Pixel 10 the flow runs to the server, which answers 503 until the key is set.
- Scan designed (`design/preview/scan-designs.html`, 27 screens): two competitors' scan flows redrawn (a scan chip → crop → full answer with Pro limits and scan into folders; a document scanner with edges, filters, multi-page and upload for credits); our Scan = camera for everything on paper with Solve · Check · Notes · Ask; three layouts (camera first, choose first, point and shoot; recommended camera first); full Solve, Check, Notes and Ask flows, failure states, entry points and journeys. Rows in Today, folders and course lists are one line with “…” so every row is the same height; task titles drop the “Lesson:” prefix (the type moves into the subtitle).
- Right answers celebrate: the option pops with a burst of dots from its tick, “+5 XP” floats up (only when XP was earned), a varied praise line and “N in a row” for streaks, a medium haptic; wrong answers shake gently. Lesson done: a burst behind Pebby, XP counts up, “Perfect lesson!” with the big celebration when every check is right; the chapter report ring fills with a burst at 80%+; finishing revision bursts. No sound yet (the bundled clips’ origin is unconfirmed). Folder bell is purple when reminders are on, delete is red; Home’s Today card says how many more tasks are in folders. Journeys re-checked on the Pixel 10: 6 of 15 work end to end (2, 3, 4, 9, 10, 15); 13 and 14 had been counted wrongly and are not built.
- Study built end to end: Courses (subject chips, Continue at the exact card, All / In progress / Done, chapter page with Resume, lessons, chapter test, kept cards, add to folder); the lesson player with seven text card types (start, concept + Remember, table, worked example with tap-to-reveal steps, quick check, here's why, summary), Keep and Ask Pebby on every card, resume position; chapter test + report by lesson; revision queue for kept and missed cards (Didn't know / Almost / Knew it); Folders (one folder icon, name + optional date, add chapters, notes, to-dos, plan from the date with revision days, today checklist that ticks lessons and tests itself); Home's Today card; reminders as local notifications (bundled evening nudge, 3 days / tomorrow / 7 am on the day, permission asked once). Server: `internal/study` extended (positions, kept cards with spaced intervals, auto-keep on a miss, chapter results; migration 0007) and new `internal/folder` (folders, items, to-dos, plan and `/today`); 5 lessons with the new card types. Android: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE` stripped, core library desugaring. 94 app tests and the server suite pass; played end to end on the Pixel 10. Roadmap rewritten to match.
- Study end to end previewed (`design/preview/study-end-to-end.html`, 25 screens, Material icons, no emoji): Courses = Subject → Chapter → Lesson → swipe cards (the old ACADEMe structure) with new text card types (start, concept, table, worked example with tap-to-reveal steps, quick check, here’s why, summary), Keep on every card and auto-kept misses feeding one revision queue, chapter test and report; Folders simplified to one folder icon, a name and an optional date, then chapters/notes, plan, checklist, reminders, Home Today card, save-to-folder. Checked against the 15 student journeys (7 end to end after this plan, 8 waiting on Scan, voice, translation, offline, uploads, Me report, ASKMe depth). Build order: lessons + keeping cards → folders → reminders → content.
- Folders previewed (`design/preview/folders-designs.html`, 17 screens): a competitor’s folders redrawn, then ours — a folder holds syllabus chapters, scans, photos, PDFs, ASKMe chats and notes; an optional date makes a plan; one checklist (plan tasks tick themselves, own to-dos by hand, missed tasks roll forward); per-folder reminders (Settings time, 3 days / day before / morning of, bundled, quiet hours); Home’s Today card = every folder’s tasks for today; save-to-folder from Scan, ASKMe and chapters; sharing later. Proposed to replace Phase 8 and finish G4 and C2’s Today card. Decision pending.
- Swipe learning v1 built (text only). Server: `internal/study` with decks as JSON built into the binary (3 starter decks, Class 10 CBSE: Science Ch 10 Reflection and Spherical mirrors, Maths Ch 3), `GET /study/decks`, `GET /study/decks/{id}`, `POST /study/decks/{id}/answers` (graded, 5 XP once per question via `xp_events`), `PUT /study/decks/{id}/completion` (best score kept, migration 0006); a library test checks every deck (quiz every ≤3 cards, answer in range, a why on each). App: Study tab (subject chips, Continue, chapters with decks and done state), deck player (concept, quiz, here's-why, deck done with Pebby, next deck), `ReplyText` moved to core. 86 app tests and the server suite pass; played end to end on the Pixel 10.
- Decision: swipe learning v1 is text only. Diagrams (drawn in the app from a diagram description, plus a designer-drawn biology library) and video are later upgrades.
- Decision: no video in the first version of swipe learning (cost). Decks are text and diagram cards, a quiz every 2–3 cards, and a “here’s why” card on wrong answers. Video moves to a later upgrade; the Study preview marks it that way.
- Setup sheet: sized to its content instead of 86% of the screen (the step body no longer stretches; height animates between steps), and “Later” sits flush in the right corner (the header row used to split spare space between the label and a spacer, leaving a gap). Home test checks the alignment.
- Study previewed (`design/preview/study-designs.html`, 30 screens): the leading study app’s study flow redrawn (AI study space, materials → tools, learn-then-quiz, feedback sheet, plan builder, peer notes); the old ACADEMe course flow redrawn from its code (courses, topic accordions, swipe deck, video card, quiz, report); our deck player (concept, vertical video, quiz, here’s why, listen, deck done), gestures and the video pipeline (script → our Pebby/diagram template → Sarvam voice → captions → 9:16 HLS + audio-only, offline); six Study directions (Chapters, Swipe feed, Stories + decks, Path, Today + library, Exam mode) with a comparison table. Pick pending; recommended S3 on top of S1.
- New Pebby pose 52 `wake_up` (one-shot, 2.3 s) for switching to Light: slumped asleep, a big stretch with a yawn, eyes pop open, a crouch and a hop with arms up, landing in a grin with a little wave. Checked frame by frame in the Rive web runtime.
- Home: the line under “Hi, name!” stays empty until class and board are set (no more “Setting up…”). Pebby's `sleep` pose (4) redone: a 2.5 s breath the whole body follows (chest swells, head nods, arms, tufts and shadow rise and fall, mouth puffs), a slow sway, and three “Z” props (`zzzA`–`zzzC`, new rig parts) floating up in turn. The dark-mode switching screen now lasts 3 s so the sleep reads.
- Log out fixed: the home route built new view models on every rebuild (every frame of a theme fade), so the shell listened to a stale Me view model and never left home. `_HomePage` now creates Home, ASKMe and Me view models once per visit; `test/routing/router_test.dart` covers log out after a theme change. Pebby's peek avatar keeps a white face in dark mode.
- Appearance (Me → Learning → Appearance) opens its own screen (room for more display settings) with Light and Dark keycaps; tapping the other one plays a switching screen where Pebby falls asleep (pose 4 `sleep`) for Dark or smiles (9 `happy`) for Light while the whole app fades across. Dark uses the splash colour `#171726`. New `AppPalette` theme extension (light and dark) read with `context.palette`; every screen after sign-in, the bar, sheets and shared widgets use it, and sign-in stays light. Saved on the phone (`AppearanceRepository`, `SharedPreferencesAppearanceStore`). 79 app tests; checked on the Pixel 10.
- Me: Log out is now a soft-rose keycap with dark red text (`tintRose`, `errorInk` added to the theme), so it stands apart from the white settings rows.
- Me: 🔥 streak, level (`Level.of(xp)`: 100 XP for level 2, then each level needs 50 XP more) with “N XP to Lv M”, and ⚡ XP. Delete account now matches the preview: optional reason, 30-day scheduled deletion that logging in cancels, hourly purge on the server, the date shown after signing out. Rewards question logged as D8.
- Reminders and daily goal: time and goal are now rows showing their value ("Remind me at 9:00 pm", "Study each day 25 min"); tapping opens a bottom sheet with the wheels and OK (`PickerSheet`, `ReminderTimeSheet`, `DailyGoalSheet`). Day keys stay inline.
- Me tab and settings built (Phase 7 first pass, layout L1): plain rows with no icons; Class and board (shared `ClassDial` + `BoardPicker`), App language (drawer + OK + switching screen with a new Pebby pose 51 `act_laptop`, a laptop prop added to the rig), Reminders and daily goal (shared `NumberWheel`, stored locally), Account (name, delete account), Help, Privacy, Log out with a confirm sheet. Server: `DELETE /me`. `ProfileRepository` now notifies, so Home's subjects follow a class change. 76 app tests, server suite green; checked on the Pixel 10.
- Me and settings previewed (`design/preview/settings-designs.html`): three Me layouts (one grouped list, quick tiles + list, profile with settings behind ⚙); settings screens for app language (pick, OK, switching, app in Telugu; sheet option), class and board (dial + board keys with what-changes note), reminder and daily goal, account (edit, log out, delete with DPDP note), help and privacy; references redrawn from two competitors and the old ACADEMe, with a comparison table. Choice pending.
- ASKMe mode bar built as the amber keycap slider (`ModeBar`): the amber key slides smoothly under the chosen mode (320 ms ease-in-out, no overshoot past the bar), the chosen icon tilts and grows a little. Changing mode swaps the line under the title and the three suggestions with a slide-up fade. The empty state lifts away when the first question is sent, and every new message pops up into place (`Appear`); with reduce motion on, all of it is instant. Home's ask field lost its camera icon (Solve homework covers it).
- ASKMe mode bar: six designs with mode-change motion and the asking animation previewed (`design/preview/mode-bar-designs.html`); choice pending.
- Nav bar → ask bar switch is now a horizontal slide: the tabs slide out to the left and the ask field slides in from the right (and back), clipped inside the pill, no fade; tab taps no longer show an ink splash.
- ASKMe empty state now uses the real Pebby Rive mascot: the `act_reading` pose (21) got a book prop in the rig (cover, pages, lines, spine, holding paws) and reads line by line with blinks; the hand-drawn stand-in is gone. The empty state is vertically centred. The Send key keeps its dark keycap edge when there's nothing to send (only the arrow dims).
- ASKMe built (C3/C4 first pass). Server: migration 0004 (`chat_threads`, `chat_messages` with ratings), `GET /chat/threads`, `GET /chat/threads/{id}/messages`, `POST /chat/messages`, `POST /chat/threads/{id}/retry`, `PUT /chat/messages/{id}/rating`, a Sarvam tutor with a class/board/language/mode system prompt, off until `ACADEME_SARVAM_API_KEY` is set. App: `ChatRepository`, `AskMeViewModel`, ASKMe screen, History, attach sheet, `PebbyPeek`, `ReadingPebby`; the nav bar animates into the ask bar and the Scan key becomes Send; Home's ask field opens ASKMe. 67 app tests and the server suite pass; checked on the Pixel 10 (answers need the Sarvam key).
- ASKMe design: Pebby's peeking avatar is smaller (22 px); no XP on answers, only on right answers in Quiz me and on "Knew it" flashcards; flashcard buttons are Didn't know · Almost · Knew it; "Back to chat" posts the review into the conversation with "Quiz me on these"; ＋ New is a plain icon, not 3D.
- ASKMe design updated: Pebby as a small circle with only his blinking eyes peeking up, beside every reply; the empty state shows a new scene of Pebby reading a book (eyes scanning, page turning), not the wave; ＋ New is a 3D keycap, follow-up chips are flat; the ask bar has no mic, just a plain ＋ (attach) at the right; the flashcards flow is drawn (deck message → front → back with Forgot/Hard/Got it → summary).
- ASKMe design (`design/preview/askme-design.html`): A1 chat with Pebby above the greeting and beside every reply; replies in the app language (no language chips); header with back, History and ＋ New as icons; Explain · Solve · Quiz me bar; 👍 👎 copy and retry on replies; the floating nav turns into the ask bar (attach ＋ opens a sheet, the Scan key becomes Send); History as the A3a chat list.
- Tab designs previewed (`design/preview/tabs-designs.html`): three directions each for ASKMe (clean chat, modes, chats by chapter), Scan (camera first, choose first, smart sheet), Study (syllabus, review first, chapter path) and Me (profile + progress, level and badges, report first). Choices pending.
- Home final layouts previewed (`design/preview/home-final.html`). Five ways to place Today, Continue, alerts, subject progress and Recently made around the built top, each at day one, an active day, the whole page and an evening/exam-eve moment. Choice pending.
- Bottom nav switched to F3 (`nav-designs.html`): a floating keycap pill with four labelled tabs (Home · ASKMe · Study · Me) and Scan as a separate purple camera keycap on the right; both have 24 px corners. The key stays pressed while Scan is open. The body extends under the bar, and Home pads its list to clear it. The tab label is ASKMe (A, S, K, M capital).
- Second tab renamed **AskMe** with a chat-bubble-and-sparkle icon (`AskMeIcon`); the Pebby icon is kept in `ui/core/ui/pebby_icon.dart` but not used. The ask field and the placeholder now say "AskMe is coming soon."
- Bottom nav: design 2 from `design/preview/nav-designs.html`, a custom `AppNavBar` with labels on every tab; the active tab turns purple, with no dot. Scan is a raised purple keycap that presses and sits above the bar. New flat `PebbyIcon` (tuft, face window, eyes, paws, feet) for the Pebby tab. Checked on the Pixel 10.
- Home built as direction 1 (Stage 1 part of C2): greeting + syllabus row with streak and XP, no wordmark; "Ask anything…" field with mic and camera; three equal tiles (Solve homework · Check my answer · Flashcards) that say what's coming; subject tiles without the repeated syllabus line; tabs Home · Pebby · Scan (primary ＋ icon) · Study · Me. Checked on the Pixel 10 at 1.0× and 1.3× text.

**2026-09-24**
- Student journeys (`design/preview/student-journeys.html`): 15 real moments across Class 6–12 scored against the leading study app (14/30), another study app (2), old ACADEMe (8) and ACADEMe as planned (6). Proposed: hint-first Solve with chapter auto-tagging, Check my answer (board marking), chapter page Learn · Practise · Revise · Test, one review queue, Test-tomorrow and catch-up plans, share into ACADEMe, offline chapters, mixed-language answers, weekly share card, 2-minute streak saver. Not yet added as tasks.
- Home chosen: direction 1 · Today. No logo or app name: the greeting and syllabus share the top row with streak and XP; one ask field with tool chips; Today plan and Continue cards once they have data; subjects. No Pebby on the home screen. Tabs Home · Pebby · ＋Scan · Study · Me.
- Home preview: direction 9 added, the old ACADEMe app (home, courses, topics, topic details, swipe deck, quiz, feedback, report, progress), redrawn from `ACADEMe-frontend`. Keep its course → topic → subtopic → deck → quiz → report structure; drop its look and Perfect/Oops-only feedback.
- The leading study app's September redesign reviewed (a competitor then-and-now preview, since removed). Chat is now their home screen, with 6 unlabelled tabs, XP for asking, the plan built in chat, and ~12 onboarding screens before the account. Home directions updated: 1 is now Today + Pebby modes; 2 is chat-first; Tool hub replaced by Exam plan; 7 redrawn as that app today. Recommendation: 1, five labelled tabs.
- Home screen: eight directions previewed (`design/preview/home-designs.html`) — six of ours plus two competitors; choice pending.
- Phase 2 built: `profiles` + `xp_events` (migration 0003), `GET/PATCH /me/profile` with a one-time 100 XP setup reward, `GET /catalog/subjects` (CBSE/ICSE 6–12), shared `RequireAccount` middleware; app shell with five tabs, first dashboard, setup sheet (language cards, year wheel, class dial, board cards), checklist with tick bursts, green ✓ → +100 → XP counter finish, one-time ask hint. Checked end to end on the Pixel 10.
- Setup completion: the card turns green with a ✓, shrinks into "+100", and the +100 flies into the XP counter.
- Setup completion simplified: tick + burst + XP into the header, card collapses, no "ready" pop-up; Personalise with Pebby parked as Phase 2b.
- Parent-consent step removed from onboarding; verifiable parental consent moved to the release checklist (DPDP, ~May 2027).
- Onboarding flow set to A + checklist: closable setup sheet, dashboard checklist, 25 XP per task, 100 XP total; preview updated.
- Six ways into the dashboard after "Let's go" previewed (`design/preview/after-signup-flows.html`); choice pending.
- Onboarding flow changed to dashboard first: setup sheet + Personalise card; preview updated.
- Onboarding direction 6 previewed in full detail, B1–B11 plus parent-consent proposal (`design/preview/onboarding-game.html`).
- Roadmap rewritten as this single document; product scope and build order decided.
- Onboarding: eight directions previewed (`design/preview/onboarding.html`); direction 6 chosen.
- Researched Sarvam against open-source and other cloud translation options; Sarvam chosen.
- Welcome: Pebby peeks over the Sign up / Log in sheet, centred, paws over the edge.
- Android: default focus highlight disabled (green outline on any key press).
- API: `/v1` prefix removed; additive-only API rule added to `server/AGENTS.md`.
- Auth end to end: app talks to the Go server; secure session storage, restore on launch, refresh-and-retry, log-out; log-in and sign-up show server errors; Google sign-in wired in app and server (ID-token check with the standard library); `PATCH /me`; migration `0002_google`; minimal home.
- Play compliance: Rive 0.13 → 0.14 (16 KB pages), edge-to-edge via `AppSystemBars`, unused biometric permissions removed, backups off.
- All comments removed from app and server; both `AGENTS.md` now say no comments.
- Renamed openme → ACADEMe: folder, Dart package, `com.academe.flutter`, namespace `com.academe.flutter_app`, version 2.0.0+7, Go module `academe/server`, `ACADEME_*` env.
- Go backend: 36 Go reference docs saved, `server/AGENTS.md` rules, golangci-lint config, auth service (sign-up, log-in, refresh, log-out, me) with Postgres, tests and OpenAPI.

**2026-09-23**
- Sign-up flow with Pebby (email and Google variants), `SignUpViewModel`, focus follows each step.
- "New here? Sign up" on log-in returns to the welcome sheet in sign-up mode.
- Code moved to MVVM layout; cleanup pass against `AGENTS.md` (names, widgets not helper methods, no animated `Opacity`, font check test).

**2026-09-21 – 2026-09-22**
- Splash on #171726 with native Android 12 splash hand-off.
- Welcome screen, keycap button system, amber `OptionTile`.
- Log-in screen with Pebby reacting (focused, cover eyes, celebrate).
- Pebby Rive: pose 50 `cover_eyes` added.
- Fonts: Baloo 2, Archivo, Noto Sans with Hindi, Telugu, Tamil, Bengali fallbacks.
- Competitor screen inventories (a 58-screen onboarding and a 15-step sign-up).
