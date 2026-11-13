# ACADEMe

**A patient tutor for every Indian school student — one who knows their exact
board syllabus and speaks their language.**

ACADEMe is a Class **6–12** study app for **CBSE, ICSE, and ISC**, rebuilt from
scratch as a Flutter Android client, a Go API, and PostgreSQL. It ships as an
update to the existing Play listing (`com.academe.flutter`), India-focused,
safe for minors, free at the core, with a simple Pro plan for heavier AI use.

This README is the end-to-end briefing for anyone who wants to contribute —
product, design, or engineering. Deeper rules and plans live in the links at
the bottom; you should not need them to understand *what* ACADEMe is and *why*.

---

## 1. Vision and mission

| | |
|---|---|
| **Vision** | Every Indian school student has a patient tutor who knows their exact syllabus and speaks their language. |
| **Mission** | Turn the board syllabus into short lessons a student can finish on a phone, and give them **Pebby** to explain, solve, quiz, and mark — so they walk into every test prepared. Free at the core, fair when paid, safe for minors. |

---

## 2. The problem

Indian students in Class 6–12 study for high-stakes board exams on budget
Android phones, often in a language other than English.

| Pain | What happens today |
|---|---|
| The syllabus *is* the exam | Most apps teach generic topics, not “Class 10 CBSE, chapter 9, lesson 2” |
| Homework help ends at the answer | Students copy; they do not learn how marks are awarded |
| English-first products | Hindi, Telugu, Tamil, and Bengali speakers get translated menus, not teaching |
| Long videos and notes | Do not fit a 10-minute bus ride or low data |
| No plan | Tests arrive and revision is guesswork |
| Harsh paywalls | Families pay before seeing value |

---

## 3. Who it is for

**One role in the product: the student.** Parents pay and follow progress;
there is no teacher dashboard.

| Persona | Who | Needs | What ACADEMe gives |
|---|---|---|---|
| **Aanya** (primary) | 15, Class 10 CBSE, Hyderabad; Telugu at home; mid-range Android | Pass boards, understand maths, less panic | Syllabus lessons, Pebby in Telugu, Check my answer, board folders |
| **Rohan** | 12, Class 7 ICSE, Kolkata; first phone | Quick wins, homework help | Swipe lessons, XP, Scan Solve (hint first) |
| **Meera** | 17, ISC 12 Science; time-poor | Fast revision, examiner-style answers | Revision queue, board-style marking, Pro Pebby |
| **Parent (payer)** | Pays for Pro; cares about safety | Visible progress, no ads, fair price | ₹100 first month / ₹1,999 year; no ads; weekly report (planned) |

---

## 4. Unique selling points (USPs)

| USP | What that means in the product |
|---|---|
| **Knows your syllabus** | CBSE + ICSE/ISC Class 6–12 (2026–27), ~5,800 planned lessons, chapters sourced to the board or publisher. The app shows *their* class and board. |
| **Learn by swiping** | Short card decks (about 5–8 minutes), a quick check every few cards, “here’s why” on mistakes, Keep on every card, resume exactly where they left off. |
| **Pebby, a tutor with personality** | ASKMe: Explain · Solve (hint first) · Quiz me. Answers in the student’s profile language. Rive mascot with dozens of poses. |
| **Check my answer, board-style** | Photo of a written answer → marks by CBSE/ICSE scheme, point by point, how to get full marks, model answer. |
| **Your language** | Pebby answers in English, Hindi, Telugu, Tamil, Bengali today. Full app/lesson localisation is Stage 2. |
| **Fair** | No paywall in onboarding. Lessons, revision, folders, and reminders stay free. Only costly AI (Pebby + Scan) is metered. |
| **Safe for minors** | No ads, no advertising ID, Scan photos never stored, Report on every AI answer, real account deletion (in-app + web). |

**One-liner:** the syllabus is the product; Pebby is the tutor inside it — not
a generic chat box wrapped as “edtech.”

---

## 5. Product pillars

Everything else (streaks, levels, share cards, mock exams) serves these five:

1. **Pebby tutor (ASKMe)** — explain, solve step by step, quiz; linked from cards and scans.
2. **Swipe lessons (Courses)** — generated from the syllabus, reviewed, text-first; diagrams / listen / video later.
3. **Scan** — Solve, Check my answer, Notes → folder, Ask about a photo.
4. **Folders and planner** — a name and a date become a plan, Today checklist, reminders.
5. **Revision** — kept cards and missed questions in a spaced queue; chapter tests by lesson.

### Also shipping / recent

- **Me → My Progress (Pro)** — weekly board (study days, summary, subjects); stays visible offline with Retry when the network fails.
- **Plan & limits** — Free vs Pro usage meters; soft update banner when the server recommends a newer Play build.
- **Feedback** — Help and feedback from Me.

---

## 6. How we differ (without naming competitors)

| Typical study apps | ACADEMe |
|---|---|
| Built for a global audience, adapted to India | Built for CBSE / ICSE / ISC 6–12 from day one |
| Chat box *is* the product | Syllabus is the product; Pebby tutors inside it |
| Video lectures or long notes | Short swipe decks with checks |
| “Here’s the answer” homework help | Hint-first solve + board-scheme marking |
| Peer note feeds / social | Curated lessons; no social surface for minors |
| Paywall in onboarding | Free core; one simple Pro; limits only on AI |
| English UI, languages later | Indic languages planned from the start (via the active provider bundle) |

---

## 7. Free vs ACADEMe Pro

Sold as one Play subscription (`academe_pro`) through **RevenueCat**. Limits
are enforced on the **server** and reset on **IST** calendars.

| | Free | Pro (about **3×** Free AI caps) |
|---|---|---|
| Lessons, revision, folders, reminders | All | All |
| ASKMe (Pebby) | 10 messages / day | 30 / day |
| Scan reads | 3 / day | 9 / day |
| Check my answer | 1 / day | 3 / day |
| Lessons from notes | — | Yes |
| My Progress board | Hold → Go Pro | Full board |
| Price | ₹0 | **₹100** first month, then **₹200**/month, or **₹1,999**/year |

There is also a weekly combined AI pool (safety cap). Daily caps usually bind
first. Exact numbers live in `docs/play/pro-limits-spec.md` and server env
`ACADEME_FREE_LIMITS`.

---

## 8. What’s in this repository

This folder (`academe/`) is the product monorepo:

| Path | What it is |
|---|---|
| `lib/` | Flutter app (MVVM: UI → view models → repositories → services) |
| `server/` | Go API (`cmd/academe-api`), PostgreSQL migrations, public legal/support pages |
| `design/` | Design sources (e.g. Pebby Rive pipeline under `design/mascot/`) |
| `about/` | Durable project context, rules index, workstream roadmaps, USPs, and telemetry direction |
| `docs/` | Play store / Pro / AI content docs; Flutter & Go reference extracts |
| `tasks/` | Strategy, roadmap, workstream reports — **source of truth for “what’s next”** |
| `test/`, `testing/fakes/` | Flutter tests and fakes |
| `AGENTS.md` | Flutter engineering rules (required reading before code changes) |
| `server/AGENTS.md` | Go engineering rules + how to run the API locally |
| `server/openapi.yaml` | HTTP contract the app codes against |
| `about/roadmap/roadmap.md` | Workstream roadmap index and planning checklists |

**Never** call competitor apps’ services or ship their assets.

---

## 9. Tech stack (plain language)

| Layer | Choice | Role |
|---|---|---|
| Mobile | Flutter (Android first; iOS later) | Student app; Pixel 10 is the reference device |
| API | Go 1.25+, standard library HTTP | Auth, study, chat, scan, billing, progress, site pages |
| Database | PostgreSQL | Accounts, study progress, limits, content metadata |
| AI | **Google Cloud** (server-side only) | Vertex AI Gemini for Pebby and lesson work; Document AI for Scan OCR; Sarvam remains an inactive switchable bundle |
| Billing | Google Play + RevenueCat | Pro subscription; webhook + `/billing/sync` |
| Email | Resend | Password reset, welcome, etc. |
| Auth | Email/password + Google Sign-In | Tokens; refresh in secure storage on device |
| Production API | `https://api.academe.cc` | Cloud Run (`academe-api`, `asia-south1` / Mumbai) + Postgres; public pages on the same host |

The Flutter app **never** holds Google, Sarvam, or RevenueCat secret keys. Release
builds talk to production by default; debug builds talk to the Mac via
`http://10.0.2.2:8080` from the emulator.

Google is the first active provider bundle. Provider selection is deployment
wide: production uses Google or Sarvam as one complete bundle and never mixes
providers by capability. Independent review is a separate Google model call,
with human review for high-risk or publication-bound content.

---

## 10. Current status (branch snapshot)

| | |
|---|---|
| Branch context | `academe-rebuild` (rebuild of the old Play app) |
| App version | See `pubspec.yaml` (`version: x.y.z+N` → Play versionName + versionCode) |
| Distribution | Google Play **closed testing** track **`ACADEMe`** (India); not the same as Internal testing |
| Soft update banner | Server `ACADEME_RECOMMENDED_BUILD` vs app `APP_BUILD` (`X-App-Build`); Me shows `ACADEMe {version} ({build})` |
| Demo | [YouTube walkthrough](https://www.youtube.com/watch?v=Q-lFkc7tIN0) |

Numbers move often; trust `pubspec.yaml`, Play Console, and
`GET https://api.academe.cc/app/config` over this paragraph.

---

## 11. How a student journey feels

1. **Welcome / auth** — sign up or log in (email or Google).
2. **Onboarding** — class, board, language; no Pro paywall.
3. **Home** — ask Pebby, Scan, continue learning; soft update banner if the server recommends a newer build.
4. **Study** — courses → chapter → swipe lesson → checks → XP.
5. **Scan** — photo homework → OCR → Solve / Check / Notes / Ask (limits apply).
6. **Folders** — named goals with dates, Today tasks, reminders.
7. **Me** — profile, class/board/language, appearance, notifications, Help, Privacy, **My Progress** (Pro), Plan & limits, Log out, version line.

---

## 12. Contributing — for everyone

### Before you change anything

1. Read **this README** (you are here).
2. Skim **`tasks/strategy.md`** (why we build) and the top of **`tasks/roadmap.md`** (what’s built vs next).
3. For UI/copy, match existing screens and `docs/play/` tone: calm, clear, India school English, no hype spam.
4. For code, follow **`AGENTS.md`** (app) or **`server/AGENTS.md`** (API). No code comments; names carry meaning.

### Principles that never bend

- **Minors first** — no ads, no dark patterns, photos from Scan are not stored.
- **Syllabus fidelity** — lessons and marking must match the student’s board.
- **Fair monetisation** — free core stays free; Pro is for AI volume and Progress.
- **Server enforces truth** — limits, Pro, and progress aggregates are not trust-the-client.
- **Additive APIs** — don’t break old installed apps; add fields/routes instead of renaming.

### Good first contributions

- Fix copy, empty states, or accessibility on existing screens.
- Add or harden widget/unit tests with fakes (no real network in Flutter tests).
- Improve docs that drifted (hosting, Play checklist) against current production.
- Teacher-style spot-checks of lesson drafts when content batches land.

### What “done” means (engineering)

**App** (from `AGENTS.md`):

```bash
dart format lib test
flutter analyze          # zero issues, infos included
flutter test
flutter run -d emulator-5554   # Pixel 10 reference — not macOS/Chrome/iOS for sign-off
```

**Server** (from `server/AGENTS.md`):

```bash
gofmt -l .
go vet ./...
golangci-lint run
ACADEME_TEST_DATABASE_URL=$ACADEME_DATABASE_URL go test -race ./...
go tool govulncheck ./...
```

Tick the task in `tasks/roadmap.md` and add a changelog line when you finish.

---

## 13. Running locally (short path)

### API

Full env list: `server/AGENTS.md` → **Running locally**.

```bash
cd server
docker compose up -d --wait
export ACADEME_DATABASE_URL='postgres://academe:academe@localhost:5432/academe?sslmode=disable'
export ACADEME_TOKEN_KEY="$(openssl rand -base64 32)"
# Optional: ACADEME_SARVAM_API_KEY, Google client IDs, RevenueCat, Resend…
go run ./cmd/academe-api
```

Health: `GET http://localhost:8080/healthz`.

### App

```bash
cd academe   # this directory
flutter pub get
flutter run -d emulator-5554
```

Useful `--dart-define`s (see `AGENTS.md` §11): `API_BASE_URL`,
`GOOGLE_SERVER_CLIENT_ID`, `REVENUECAT_GOOGLE_API_KEY`, `APP_BUILD`,
`APP_VERSION`. Release AABs: `tool/build_release_aab.sh`.

---

## 14. Trust, safety, and compliance

- **No ads, ever.** Pro pays for the product.
- **Play Families** posture: ages 9–17 bands; Data safety answers in `docs/play/`.
- **Generative AI:** Report on every Pebby answer; content policy in `docs/play/ai-content.md`.
- **DPDP (India):** every user is a child in law; parental consent / notice work is planned toward **May 2027** — see strategy §11.
- **Deletion:** in-app and `https://api.academe.cc/delete-account`.
- **Privacy / Terms / Support:** served from the API host (`/privacy`, `/terms`, `/support`).

---

## 15. Roadmap stages (orientation)

| Stage | Focus |
|---|---|
| **1 — Parity** | Entry, onboarding, ASKMe, Scan, Study, folders, Me, Pro (mostly built) |
| **2 — Multilingual** | App text, lessons, emails in five languages; voice ask / listen |
| **3 — Scale learning** | Full chapter coverage, richer card types, offline chapters, Home learn feed |
| **Always** | Play + DPDP compliance, cost per learner, content quality |

Detail and checkboxes: **`tasks/roadmap.md`**. Strategy and GTM:
**`tasks/strategy.md`**.

---

## 16. Where to dig deeper

| Topic | Document |
|---|---|
| Why / USP / pricing / GTM | `tasks/strategy.md` |
| Built vs next / open decisions | `tasks/roadmap.md` |
| Project context and workstream roadmaps | `about/` |
| Telemetry checklist | `about/roadmap/telemetry.md` |
| Flutter rules | `AGENTS.md` |
| Go rules + local server | `server/AGENTS.md` |
| API contract | `server/openapi.yaml` |
| Pro limits | `docs/play/pro-limits-spec.md` |
| Play listing / release | `docs/play/` |
| Deployment runbook | `docs/deployment.md` (Cloud Run is the current deployment target) |

---

## 17. Contact and demos

- Product demo: https://www.youtube.com/watch?v=Q-lFkc7tIN0  
- Production API health: https://api.academe.cc/healthz  
- Marketing site: https://academe.cc (separate from this API)

If you are unsure whether a change fits the product, ask against the USPs in
§4 and the pillars in §5: if it doesn’t make syllabus learning, Pebby help,
Scan marking, planning, or revision better for an Indian Class 6–12 student —
it probably doesn’t belong yet.
