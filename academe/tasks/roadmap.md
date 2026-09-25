# ACADEMe — roadmap

The one planning document for the ACADEMe rebuild: what the app is, what is
decided, what is built, the order we build the rest in, every screen as a task,
and a log of what has been done.

Last updated 2026-09-25.

---

## 1. What ACADEMe is

**A study app for Indian school students (Class 6–12, CBSE and ICSE) that
works in their own language.** Pebby, the AI tutor, explains, solves and
quizzes; lessons are short swipeable cards with a quick check every 2–3 cards;
students keep what they miss and it comes back in revision; folders hold what
they are preparing for and turn a date into a plan, a checklist and reminders;
XP and streaks bring them back every day.

- **Positioning:** the feature set of the leading study apps, plus real Indian-language support,
  plus the old ACADEMe's swipe learning, rebuilt.
- **One role:** the student. No teacher, admin or school surface.
- **Not:** an LMS, a school ERP, a jobs board, a Q&A forum, a social network.

### USPs

| # | USP | Status |
|---|---|---|
| 1 | Everything the leading study app does: AI tutor, homework scan, notes, flashcards, quizzes, mock exams, exam planner, streaks | Tutor, lessons, quizzes, revision, planner (folders) and scan built; mock exams, streaks to do |
| 2 | The whole app in your language, switchable any time, Hinglish understood | Pebby answers in the profile language; app text and lessons are English until Stage 2 |
| 3 | Learn by swiping: lessons as card decks, a quick check every 2–3 cards, "here's why" on mistakes | Built (text only) |
| 4 | Knows the syllabus: class and board decide subjects, chapters and what Pebby teaches | Built for the chapters that have lessons |
| 5 | Pebby: a tutor with personality, step by step rather than just answers | Built (needs the Sarvam key for real answers) |
| 6 | Fair: no paywall in onboarding; no metered "generations" on the syllabus | Holds; pricing undecided |
| 7 | Built right for Indian Android phones and for minors: Play-compliant, itemised permissions, real account deletion | Throughout |

---

## 2. Decisions made

| Date | Decision |
|---|---|
| 2026-09-25 | **Study = Courses + Folders.** Courses teach the syllabus (Subject → Chapter → Lesson → cards, the old ACADEMe structure). Folders are the student's own: one plain folder icon, a name and an optional date; the date makes the plan, the checklist and the reminders; Home's Today card is every folder's tasks for today. Folders **replace the separate exam planner** (Phase 8). |
| 2026-09-25 | **Lessons v1 are text only.** Card types: start, concept (with a "Remember" line), table, worked example (steps revealed one tap at a time), quick check, here's why, summary. Diagrams (drawn in the app from a diagram description, plus a designer-drawn biology library) and video are later upgrades that slot into the same player. |
| 2026-09-25 | **Keep and revise.** Every card has Keep and Ask Pebby; every missed question is kept automatically; one revision queue (Didn't know / Almost / Knew it) spaces them out. XP only for right quiz answers (+5, once per question) — never for ticking boxes. |
| 2026-09-25 | Proper icons only (Material), no emoji in the product. |
| 2026-09-25 | Reminders are local notifications from the phone: one bundled evening nudge per day at the student's time, "in 3 days" and "tomorrow" before a folder's date, a 7 am nudge on the day; permission asked the first time there is something to send. |
| 2026-09-25 | Appearance: Light and Dark (the splash colour #171726); sign-in screens stay light. |
| 2026-09-24 | Home = direction 1 "Today" (`home-designs.html`); nav = F3 floating pill (Home · ASKMe · Study · Me) + a separate Scan key, 24 px radius; ASKMe = A1 (Explain · Solve · Quiz me); Me = L1 (plain rows, no icons). |
| 2026-09-24 | Students: **Class 6–12**. Boards: **CBSE, ICSE**. More only when asked. |
| 2026-09-24 | Launch languages: **English, Hindi, Telugu, Tamil, Bengali**. |
| 2026-09-24 | Language vendor: **Sarvam** (chat, translation, speech, OCR), called only from the Go server. LibreTranslate is out. |
| 2026-09-24 | Build order: **competitor parity → multilingual → swipe learning at scale**. |
| 2026-09-24 | Onboarding: **setup sheet + checklist** on the dashboard (language, age, class, board; +25 XP each, +100 in total). Personalise with Pebby parked. |
| 2026-09-24 | Pricing: later. |
| 2026-09-24 | App is **ACADEMe**, package `com.academe.flutter`, shipped as an update to the existing Play listing (last upload 1.0.5+6; rebuild starts at 2.0.0+7). |
| 2026-09-24 | Firebase: a new project, later. Upload keystore: only when releasing. |
| 2026-09-24 | API routes carry **no version prefix**; the API only changes additively. |
| 2026-09-24 | **No comments** in code or config, app or server. |
| 2026-09-24 | Backend: **Go + PostgreSQL** (`server/`), stdlib HTTP, pgx, argon2id, 15-min access token + 30-day rotating refresh token. |
| 2026-09-22 | ACADEMe runs only on the **Pixel 10 emulator** for sign-off. Previews are local HTML in `design/preview/`, never published. |

---

## 3. How we work

1. **Preview** — mock it in `design/preview/` (local HTML), open it, get approval.
2. **Build** — app (MVVM per `AGENTS.md`) and, if it needs data, the server endpoint (per `server/AGENTS.md`) and `openapi.yaml`.
3. **Check** — `dart format`, `flutter analyze`, `flutter test`; `gofmt`, `go vet`, `golangci-lint`, `go test -race`, `govulncheck`.
4. **Run** — full reinstall on the Pixel 10 against the local server.
5. **Record** — tick the box below and add a line to the change log (§12).

---

## 4. Architecture today

| Layer | What | Where |
|---|---|---|
| App | Flutter 3.41, MVVM (`ChangeNotifier` view models, repositories, services), `Result` + `Command` | `lib/` |
| App packages | rive, lottie, audioplayers, http, shared_preferences, flutter_secure_storage, google_sign_in, flutter_local_notifications, timezone | `pubspec.yaml` |
| Animation | Rive (`pebby.riv` generated by `design/mascot/rive/`, poses 0–52 incl. reading, laptop, sleep, wake-up) | `assets/academe/mascot/` |
| Design system | `AppColors`, `AppPalette` (light / dark), `AppTextStyles`, `AppKeycap`; Baloo 2 / Archivo / Noto Sans | `lib/ui/core/themes/app_theme.dart` |
| Session | refresh token + account in `flutter_secure_storage`, access token in memory, one retry on 401 | `lib/data/` |
| Server | Go, `net/http` mux, pgx pool, embedded migrations 0001–0007, slog JSON; packages auth, profile, chat, study, folder | `server/` |
| Database | `accounts`, `sessions`, `profiles`, `xp_events`, `chat_threads`, `chat_messages`, `deck_completions`, `deck_positions`, `kept_cards`, `chapter_results`, `folders`, `folder_items`, `folder_todos` | `server/internal/postgres/migrations/` |
| Lesson content | JSON files built into the server (`server/internal/study/decks/`), checked by a test (start card first, summary last, a quiz within every 3 cards, a why on every question) | |
| API contract | `server/openapi.yaml` (32 paths) | |
| Android permissions | `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`; `VIBRATE` stripped | `android/app/src/main/AndroidManifest.xml` |
| Config | app: `--dart-define` `API_BASE_URL`, `GOOGLE_SERVER_CLIENT_ID`; server: `ACADEME_*` env incl. `ACADEME_SARVAM_API_KEY` | |
| Not yet | Object storage for uploads, FCM, billing, hosting | |

---

## 5. Built so far

**Entry and onboarding**
- [x] Splash, Welcome (Pebby peeking over the sheet), email sign-up (5 steps, Pebby reacting), email log-in, session restore, log-out
- [x] Google sign-in wired end to end (needs Google Cloud client IDs)
- [x] Setup sheet + dashboard checklist: language, birth year, class dial, board; +25 XP each, +100 flying into the XP chip; sheet sized to its content

**Shell and Home**
- [x] Floating nav pill (Home · ASKMe · Study · Me) + separate Scan key; the pill turns into the ask bar on ASKMe
- [x] Home: greeting + class · board, streak + XP chips, ask field (opens ASKMe), quick actions (Flashcards opens revision), **Today card** (every folder's tasks for today, what's left first), subjects

**ASKMe**
- [x] Chat with Pebby (Explain · Solve · Quiz me), answers in the profile language, 👍 👎 copy retry, history with search, attach sheet; server `/chat/*` with Sarvam (off without the key)

**Study — Courses (swipe lessons)**
- [x] Courses: subject chips, Continue (exact card), All / In progress / Done, chapters with progress
- [x] Chapter page: progress, Resume, numbered lessons with ticks and progress, chapter test, kept cards, Add to a folder
- [x] Lesson player: stacked swipe cards (left/right or keys), segment bar, card types start · concept · table · worked example · quick check · here's why · summary, Keep + Ask Pebby on every card, resume where you left off
- [x] Quick check every 2–3 cards; +5 XP once per question; a miss shows the right answer and why and is kept automatically
- [x] Lesson done (Pebby, score, XP, kept) → next lesson
- [x] Chapter test (every question from the chapter's lessons) and report by lesson → revise what you missed / add to a folder
- [x] Revision queue: kept cards and missed questions, tap to reveal, Didn't know / Almost / Knew it (1 day, ×1.5, ×2.5)
- [x] Content: 5 lessons, Class 10 CBSE, English — Science Ch 10 (Reflection, Spherical mirrors, Mirror formula) and Maths Ch 3 (What a pair is, Substitution)

**Study — Folders**
- [x] Folders list (one folder icon, soonest date first), new folder (name + optional date), edit, reminders on/off, delete
- [x] Add chapters from the syllabus, write notes, to-dos
- [x] Plan from the date: unfinished lessons and chapter tests spread over the days left, then revision days, test day; recomputed every time so missed work rolls forward
- [x] Today checklist: lessons and tests tick themselves when done, to-dos by hand, revision due in the folder's chapters
- [x] Reminders: local notifications for the next 7 days, bundled evening nudge, "in 3 days" / "tomorrow" / 7 am on the day; permission asked once

**Scan (direction B · choose first)**
- [x] Scan key → Scan tab: Solve homework · Check my answer · Notes to a folder · Ask about a photo, recent scans below (tap to reopen the chat, marks or folder, or finish an unsaved scan)
- [x] Camera or gallery (Android photo picker, no extra permissions); Notes take up to 10 pages with add/remove
- [x] Sarvam Document AI reads the page (the profile language), Sarvam labels the chapter; the student can fix the text before using it
- [x] Solve → an ASKMe chat in Solve mode (hint first), linked to the scan; Ask → question + photo text into ASKMe
- [x] Check my answer → marks by the CBSE / ICSE scheme: marks ring, each point with its marks, how to get full marks, model answer on tap, Ask Pebby, Check again
- [x] Notes → choose a folder → a swipe lesson made from the notes (validated like seeded lessons) or just the notes; lessons show in the folder and join its plan
- [x] Other ways in: Home's Solve homework and Check my answer, ASKMe attach Camera / Photos, a folder's Scan notes
- [x] Photos are never stored: only the text, the marks and links are kept

**Me and settings**
- [x] Me (L1): profile, streak / level / XP, plain rows, rose Log out
- [x] Class and board, App language (drawer + laptop-Pebby switch), Appearance (Light / Dark with sleeping and waking Pebby), Reminders and daily goal, Account, Help, Privacy
- [x] Delete account: reason, typed DELETE, 30-day grace, hourly purge

**Server and Play groundwork**
- [x] Auth, profile, catalogue, chat, study (lessons, answers, positions, kept, review, chapter results, lessons made from notes), folders (+ plan and today, lessons), scans (`/scans`, one shared Sarvam client for chat and scan); tests incl. real Postgres
- [x] 16 KB pages, edge-to-edge, no orientation lock, minimal permissions, backups off, no Android focus outline

---

## 6. What's next, in order

1. **Lessons for every chapter** — the AI lesson pipeline (syllabus map → lesson in these card types → teacher spot-check → stored). Needs the model key. Until then only the 5 seeded lessons exist.
2. **Scan, part 2** — set the Sarvam key and tune the prompts on real homework; crop, blur check, offline queue, PDFs, similar question after a solve, revision cards / quiz from notes; storage and scaling plan.
3. **Streaks and levels** (Phase 6) — the streak is still a placeholder 0; streak saver reminder; level-up moment.
4. **Stage 2 — languages** — app text in five languages; lessons translated and checked.
5. **Password reset and Google on a device** (A6–A9), rate limits, hosting, release checklist.

---

## 7. Stage 1 — competitor parity

IDs: **A** entry · **B** onboarding · **C** shell and companion · **D** capture
· **E** study · **F** progress · **G** settings · **H** money. Idea source:
**K** the leading study app · **S** another study app · **O** ours. `[~]` = partly built.

### Phase 1 — Entry and auth

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | A1 | Splash | |
| [x] | A2 | Welcome + sheet | Pebby peek |
| [x] | A3 | Provider options | Google / email |
| [x] | A4 | Sign-up (email) | 5 steps |
| [x] | A5 | Log-in (email) | |
| [ ] | A6 | Forgot password | email entry |
| [ ] | A7 | Check your email | 6-digit code |
| [ ] | A8 | Reset password | new password |
| [ ] | A9 | Google switched on | client IDs; test on a device |

Server for A6–A8: `password_resets`, `POST /auth/password/forgot`, `POST
/auth/password/reset`, an email sender (D5), rate limits. Before launch also:
rate limits on log-in and sign-up, purging expired sessions.

### Phase 2 — Onboarding

| | ID | Task | Notes |
|---|---|---|---|
| [x] | S1–S4 | Language, age, class, board | setup sheet + checklist, +25 XP each |
| [x] | L3–L4 | Ticks and the +100 finish | |
| [x] | D1 | Ask-bar hint | once |
| [ ] | P1–P5 | Personalise with Pebby (parked) | subjects swipe, goal, daily goal, reminder, Day 1 streak |
| [ ] | — | Onboarding taster | a 3-card lesson before streak day one |

### Phase 3 — Shell and AI companion

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | C1 | App shell | floating pill + Scan key; pill becomes the ask bar |
| [~] | C2 | Home | built: greeting, ask field, quick actions, Today card, subjects. Left: Continue card on Home, subjects open their course |
| [~] | C3 | ASKMe | built (see §5). Left: streaming, maths rendering, attachments, voice, Make flashcards from a chat, save an answer to a folder, "Go deeper" |
| [~] | C4 | Chat history | built: list, search, reopen. Left: rename, delete |
| [ ] | C5 | First-steps cards | cold-start suggestions |
| [ ] | C6–C7 | Search | across lessons, folders, chats |
| [ ] | C8 | Tickets | daily free uses (only if pricing needs it) |

### Phase 4 — Capture (Scan)

Designed in `design/preview/scan-designs.html` (27 screens). Scan is the camera
for everything on paper, with four modes. Solve and Ask are ASKMe with a
camera, Notes is Folders with a camera, and Check is the one new result
screen. Chosen layout: **B · choose first** — the Scan key opens the four
jobs with recent scans below, then the camera or gallery. Everything runs on
Sarvam for now (Document AI to read, chat to label, solve, mark and make
lessons); photos are not stored. Storage and scaling come later.

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | D1 | Scan tab | choose first: four jobs + recent scans; camera or gallery; chapter label; failure states. Later: crop, blur check, offline queue, PDF |
| [x] | D2 | Solve | show and fix what was read → ASKMe chat in Solve mode (hint first), linked to the scan. Later: crop, similar question, save to folder |
| [x] | D3 | Check my answer | question + written answer → marks from the CBSE / ICSE marking scheme, what's missing, model answer on tap, rewrite and re-check |
| [x] | D4 | Notes | up to 10 pages → pick a folder → a swipe lesson or just the notes. Later: suggested folder, revision cards, quiz |
| [x] | D5 | Ask | photo text + the question into a new ASKMe chat, suggested questions |

Entry points: the Scan key; Home's Solve homework and Check my answer; ASKMe
attach; a folder's Scan notes. Unlocks journeys 1, 7, 8 and 14 (10 of 15).
Server: `POST /scans` (multipart, up to 10 pages of 8 MB, JPG/PNG/PDF),
`GET /scans`, `GET /scans/{id}`, `PUT /scans/{id}/thread`,
`POST /scans/{id}/check`, `POST /scans/{id}/notes`; migration 0008
(`scans`, `user_decks`, `folder_items.deck_id`). Without
`ACADEME_SARVAM_API_KEY` every scan returns 503 `scan_unavailable`.

### Phase 5 — Study

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | E1 | Courses | subject chips, Continue, filters, chapters |
| [x] | E1b | Chapter page | lessons, chapter test, kept cards, add to folder |
| [x] | E2 | Lesson player | seven text card types, keep, ask, resume |
| [x] | E3 | Chapter test + report | |
| [x] | E4 | Revision queue | kept + missed cards, spaced |
| [x] | E12 | Folders v1 | chapters, notes, to-dos, plan, today, reminders |
| [ ] | E5 | Folders v2 | scans, photos and PDFs in a folder, made into a lesson, flashcards or a quiz |
| [ ] | E6 | Flashcards from anything | from a chat, a scan or a folder, into the revision queue |
| [ ] | E7 | Mock exam | past papers, timed, board marking (Class 10 and 12) |
| [ ] | E8 | Chat with a folder | ASKMe grounded in what's in the folder |
| [ ] | E9 | Share a folder | share link for messaging apps; friends get a copy |

### Phase 6 — Progress and reward

| | ID | Screen | Notes |
|---|---|---|---|
| [ ] | F1 | Streak | real streak days, calendar, freeze, streak saver reminder |
| [ ] | F2 | Level up | full-screen, Pebby |
| [ ] | F3 | Leaderboard | weekly, by class |
| [ ] | F4 | Achievements | badges |
| [ ] | F5 | Weekly report | shareable to a parent through messaging apps |

### Phase 7 — Settings and account

| | ID | Screen | Notes |
|---|---|---|---|
| [x] | G1 | Me | L1 |
| [~] | G2 | Edit profile | name, class + board built. Left: subjects |
| [~] | G3 | Account | name, email, log-out built. Left: change password, link Google, sign out everywhere |
| [x] | G4 | Reminders and daily goal | settings + local notifications |
| [~] | G5 | Language | saved and used by Pebby. Left: app text (Stage 2) |
| [x] | G6b | Appearance | Light / Dark |
| [~] | G6 | Privacy and legal | screen built. Left: documents, download my data |
| [~] | G7 | Delete account | built. Left: public web page for Play |

### Phase 8 — Exam planner

Replaced by folders (decided 2026-09-25): a folder with a date is the plan. Left
for later: the board-exam date filled in for Class 10 and 12, and a
"missed classes" catch-up folder shortcut.

### Phase 9 — Money

| | ID | Screen | Notes |
|---|---|---|---|
| [ ] | H1–H5 | Paywall, plans, purchase, limits, manage | pricing undecided (D6) |

**Stage 1 done when:** the 15 student journeys that don't need languages work
end to end in English on the Pixel 10 (today 6 of 15, checked 25 Sep: 2, 3,
4, 9, 10, 15; see `design/preview/study-end-to-end.html`).

### Competitor features we skip or defer

| Feature | Why |
|---|---|
| Peer notes feed, creators, likes | needs a community and moderation |
| Metered AI "generations", Pro on every tool | against "fair"; pricing later |
| Podcasts, video summaries, study songs | not needed |
| Study groups, topic chats | social surface for minors needs moderation first |
| Timetable import, US colleges, SAT/AP | not our market |

---

## 8. Stage 2 — Multilingual

| | Task | Notes |
|---|---|---|
| [ ] | App text in ARB files | every string out of widgets |
| [ ] | Five languages | drafted with Sarvam, reviewed by native speakers (D3) |
| [ ] | Live switching | from the profile, no restart |
| [ ] | Lessons in five languages | translated per lesson, stored, reviewed; terms kept in English where exams use them |
| [ ] | Layout checks | Telugu and Tamil at 1.3× |
| [ ] | Voice | speech-to-text in the ask field; listen to answers and cards |
| [ ] | Sarvam data terms | retention and training use confirmed before student data is sent |

---

## 9. Stage 3 — Swipe learning at scale

| | Task | Notes |
|---|---|---|
| [~] | Syllabus map | chapter ids exist (`cbse-10-science-10`); full CBSE + ICSE Class 6–12 map to add |
| [ ] | Lesson pipeline | AI writes lessons in the seven card types per chapter, class, board; teacher spot-check; versioned |
| [x] | Swipe player, card types, quick checks, why, keep, resume | text only |
| [x] | Chapter test and report | |
| [x] | Revision (spaced repetition) | |
| [ ] | Diagram cards | in-app templates from a diagram description; designer-drawn biology library |
| [ ] | Video cards | short vertical "Pebby explains"; cost to be priced first |
| [ ] | Listen cards | voice |
| [ ] | Learn feed on Home | short-video-style feed from your chapters |
| [ ] | Offline chapters | download for low data |
| [ ] | First-time swipe hint | |

---

## 10. Release checklist (Play)

- [ ] Upload keystore wired (`android/key.properties`, never committed)
- [ ] Version above 1.0.5+6
- [x] 16 KB pages (re-check after each native plugin; flutter_local_notifications adds none)
- [x] Edge-to-edge, no orientation lock
- [x] Permissions: `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` only
- [ ] Monochrome notification icon (reminders use the launcher icon today)
- [ ] Large screens: width-capped content, landscape welcome layout
- [ ] Keyboard focus rings on custom buttons
- [ ] Parental consent for under-18s (DPDP) — see D1
- [ ] Data safety form, privacy policy URL, account-deletion URL, content rating
- [ ] Release build over HTTPS to the hosted server
- [ ] Remove competitor artwork from `assets/academe/raster/`
- [ ] Internal testing track on a real phone

---

## 11. Open decisions and known issues

### Open decisions

| # | Question |
|---|---|
| D1 | Parental consent method (DPDP, from ~May 2027), with legal advice. |
| D2 | LLM for Pebby and for writing lessons: Sarvam alone, or another model for hard maths? |
| D3 | Who reviews Hindi, Telugu, Tamil and Bengali text and lessons? |
| D4 | Hosting for the Go server and Postgres (India region). |
| D5 | Email provider for password reset. |
| D6 | Pricing, payment path, whether parents pay. |
| D7 | Existing users of the old app: migrate or start fresh? |
| D8 | Rewards: what can XP buy, if anything? Until decided, XP only drives levels. |
| D9 | Video lessons: price one render per topic per language before committing. |

### Known issues

| Issue | Fix |
|---|---|
| Only 5 lessons exist (Class 10 CBSE, English) | lesson pipeline (§6.1) |
| Streak shows 0 everywhere | Phase 6 |
| ASKMe and Scan need `ACADEME_SARVAM_API_KEY` | set the key; verify model name, Document AI output and the marking / lesson prompts on real pages |
| "Done today" uses the phone's date and UTC offset sent with each request | fine for India; revisit for travel |
| Folder notes can't be edited, only deleted | small follow-up |
| Reminders use the launcher icon | add a monochrome notification icon |
| Answer sounds: `assets/academe/audio/*.mp3` came in with outside reference files; origin unconfirmed | confirm we own them, or make our own, before using sound |
| `assets/academe/raster/` contains competitor artwork | remove before any release |
| Landscape and tablet layouts stretch full width | width cap |
| Custom buttons show no keyboard focus ring | focus handling in `Keycap` |
| Rive state-machine inputs deprecated in 0.14 | move Pebby to data binding when regenerated |
| Server: no rate limits, expired sessions never purged | before launch |
| Google sign-in needs console setup | A9 |

---

## 12. Change log

Newest first. One line per change that landed; details live in git.

**2026-09-25**
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
- Researched Sarvam vs LibreTranslate vs IndicTrans2 vs Google; Sarvam chosen.
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
