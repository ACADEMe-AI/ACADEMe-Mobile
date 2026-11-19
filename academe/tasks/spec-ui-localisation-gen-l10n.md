# Spec: Multilingual product surfaces (UI + emails + legal web + Play listings)

Status: **Approved** (defaults + welcome-after-setup). Implementation started at slice A.

Related: Stage 2 in `tasks/roadmap.md` §8; `tasks/strategy.md`; `docs/play/store-listing.md` (localised listings section).  
Already shipped (keep): profile language steers **Pebby / Scan teaching** replies; Home greeting uses `AppLanguage.hello`; Scan Check/Lesson/chapter prompts follow profile language.

**Only lessons stay later** (catalogue swipe decks). Everything else in this Stage 2 language track that students touch is in scope below.

---

## Assumptions (correct me before we build)

1. **In scope:** Flutter **UI chrome**, **student-facing emails**, **legal/support web pages** on `api.academe.cc`, and **Google Play store listing** translations for `en-IN` + `hi-IN` / `te-IN` / `ta-IN` / `bn-IN`.
2. **Out of scope:** Catalogue / approved **swipe lesson bodies**; voice STT/TTS; Hinglish claims; Localizely/Crowdin/OTA SDKs (optional ops later).
3. **Flutter UI stack = official `gen-l10n` + ARB.** No `easy_localization` / GetX i18n as primary.
4. **One source of truth:** `Profile.language` (`en` | `hi` | `te` | `ta` | `bn`) drives UI locale, Pebby/Scan, student emails (when known), and preferred legal-page language. No second “AI language” toggle.
5. **Default / fallback = English** everywhere a translation is missing.
6. **UI switch timing:** language stays setup step 1; full UI locale applies **when setup completes** (short switch moment). Me → App language applies immediately with the same moment.
7. **Welcome email timing (decided):** Do **not** send at signup. Send **once** when setup completes (`profile.Service` → `CompleteSetup`, when `setup_done_at` flips null→set). At that moment language (and class/board/subjects) are on the profile, so the mail uses the right locale. Signup/Google create stay non-blocking (no mail wait). Remove `s.welcome` from `auth` SignUp / first Google create.
8. **Emails to localise (student-facing):** `welcome`, `reset`, `google` (Google-only login hint), `deletion`, `feedback_received`. **Stay English:** `feedback_ops` (internal ops mail).
9. **Email implementation (server):** keep existing `embed` HTML/text templates under `server/internal/email/templates/`; add per-locale string tables (or `templates/<lang>/…`) selected by language code passed into `Welcome` / `Reset` / deletion / feedback receipt. Pass language from caller (profile lookup by account when available; else `en`).
10. **Legal pages:** `privacy`, `terms`, `support`, `delete-account` (and shared `layout.html`). Serve translated copy via `?lang=` or path prefix; default English. Play privacy/terms URLs may stay the English canonical URLs; pages can offer a language switcher.
11. **Play listings:** documentation + Console copy for localised store listings in `docs/play/store-listing.md` (and paste into Play Console). Ship listing translations **after** UI chrome is largely localised so a Hindi listing is not misleading (per existing note in store-listing.md). Screenshots can remain shared; captions/descriptions are translated.
12. **Size:** Play download stays ~12 MB class for UI ARBs; emails/legal/listings add **0** to the APK.
13. **Sign-off device:** Pixel 10 for app UI. Emails: render tests + one real Resend to a test inbox per locale. Legal: curl/browser. Listings: character counts + Console preview.
14. **Incremental ship OK** within this spec (P0 UI scaffold before every screen; emails/legal/listings can follow UI P1).

→ Correct any of these now, or we treat them as locked for planning.

---

## Current codebase facts (research)

### Flutter UI
- Single `MaterialApp` in `lib/main.dart` — no `locale` / `localizationsDelegates` yet.
- `AppLanguage` already defines en/hi/te/ta/bn + greetings; Me + setup already save `Profile.language`.
- ~189 UI Dart files; roughly 250–400 user-facing chrome keys after cleanup.
- Indic fonts already bundled (~2.9 MB) with theme fallbacks.

### Emails (`server/internal/email`)
- Templates: `welcome`, `reset`, `google`, `deletion`, `feedback_ops`, `feedback_received` (+ shared `layout`).
- Subjects/body copy are **hardcoded English** in `email.go` (`Welcome.message`, `Reset.message`, `deletionMessage`, feedback helpers).
- Call sites: welcome on signup; reset from auth; deletion notice from site delete-account; feedback from `internal/feedback`.
- No `Language` field on `Welcome` / `Reset` today.

### Legal / site (`server/internal/site/pages`)
- English HTML: `privacy.html`, `terms.html`, `support.html`, `delete.html`, `layout.html`.
- Recently filled operator = ACADEMe, Hyderabad, grievance role title.

### Play listing (`docs/play/store-listing.md`)
- Default listing language: **English (India) `en-IN`**.
- Doc already plans `hi-IN`, `te-IN`, `ta-IN`, `bn-IN` once app text is translated.
- App name / short / full description character limits documented there.

---

## Objective

### What we are building

One language preference that makes ACADEMe feel local across:

1. **In-app UI** (tabs, buttons, errors, sheets, settings)  
2. **Pebby / Scan teaching** (already)  
3. **Student emails** (welcome when language known, reset, deletion, feedback receipt)  
4. **Legal/support web pages**  
5. **Play Store listing text** in the five languages  

### Who

Class 6–12 students in India (and parents who read mail / Play / privacy).

### User stories

1. New student picks Hindi in setup → finishes setup → short switch → Home/tabs in Hindi.  
2. Returning student changes Me → App language → UI updates without reinstall; new Pebby answers follow.  
3. Student with `language=hi` requests password reset → email subject/body in Hindi (fallback English if lookup fails).  
4. Student opens privacy/support with Hindi preference → readable Hindi (or switcher); English always available.  
5. Play shopper with Hindi Play language sees Hindi short/full description once listings are published.  
6. Engineer adds a sixth UI language later via new ARB (+ email/legal/listing strings) without redesign.

### Explicitly out of scope

| Out | Why |
|-----|-----|
| Catalogue / swipe **lesson** body translation | Separate content pipeline — **only major deferral** |
| Lesson-from-notes card JSON | Already follows profile language on server |
| `feedback_ops` email | Internal ops; stay English |
| Voice STT/TTS, Hinglish marketing claims | Later Stage 2 items |
| Localizely / Crowdin / OTA translation SDK | Optional ops; not required |
| Changing Play privacy policy **URL** to a non-English-only host | Canonical English URL OK; page may negotiate `lang` |

---

## Success criteria (testable)

### A. Flutter UI (gen-l10n)

1. `flutter gen-l10n` works; `MaterialApp` uses profile-driven `locale` + generated delegates.  
2. Post-setup and Me language change show switch moment and update chrome.  
3. Migrated surfaces (shell, auth, home, ASKMe/Scan/Study chrome, Me/paywall/errors) use `AppLocalizations` — no raw English chrome literals.  
4. `app_en.arb` + hi/te/ta/bn for every key; untranslated report clean or documented.  
5. Pixel 10: en + one Indic locale at 1.0× and 1.3×; Pebby smoke in that language.  
6. Play download remains ~12 MB class (+≤~0.5 MB from strings; no new fonts).  
7. Language sheet does not claim catalogue lessons switch.

### B. Emails

8. `Welcome`, `Reset`, `Google-only`, `Deletion`, `feedback_received` render correct **subject + HTML + text** for each of en/hi/te/ta/bn (table-driven Go tests).  
9. Call sites pass language when account/profile is known; unknown → `en`.  
10. Welcome is sent **once on setup complete**, in `profile.language` (fallback `en`). Not sent at signup. Not resent if setup was already done.  
11. `feedback_ops` remains English.  
12. Existing escaping / bidi / spam-name tests still pass for all locales that include a name.

### C. Legal / support web

13. `privacy`, `terms`, `support`, `delete-account` available in en/hi/te/ta/bn (content complete; machine draft OK pending native review).  
14. Default URL without lang = English (Play / DPDP links stay valid).  
15. Layout chrome (nav/footer) follows selected lang.  
16. `./tool/check_legal_placeholders.sh` still passes (no `FILL`).

### D. Play listings

17. `docs/play/store-listing.md` contains approved copy blocks for `en-IN`, `hi-IN`, `te-IN`, `ta-IN`, `bn-IN` (app name, short description, full description) within Play character limits.  
18. Listing translations are honest (no “whole app in Hindi” until UI phase for that locale is done; coordinate publish order).  
19. Operator checklist step: paste into Play Console → Store presence → custom store listings / translated listings.

---

## Tech stack

| Surface | Approach |
|---------|----------|
| App UI | `flutter_localizations` + `intl` + **gen-l10n** ARB |
| Locale driver | `Profile.language` / `AppLanguage` |
| Fonts | Existing theme fallbacks (no new fonts in v1) |
| AI | Existing Go prompts (already) |
| Emails | Go `embed` templates + **locale string maps** (or `templates/<lang>/*`) selected by `language` field on send DTOs |
| Legal pages | Go site templates: per-locale content partials or `lang` query with translated strings; shared layout |
| Play listings | Markdown source of truth in `docs/play/store-listing.md` → manual Console entry (no APK impact) |
| Not used | easy_localization as primary; OTA translation SDK in v1 |

---

## Commands

```bash
# Flutter (from academe/)
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
flutter run -d emulator-5554

# Server email + site (from academe/server/)
go test ./internal/email/ ./internal/site/ ./internal/auth/ -count=1
./tool/check_legal_placeholders.sh   # from academe/ if script path as today

# Listing copy length (example)
python3 -c "print(len('''paste short description'''))"
```

---

## Project structure

```
academe/
  l10n.yaml
  lib/l10n/app_en.arb … app_bn.arb
  lib/ui/core/l10n/          # context.l10n, LocaleController
  lib/main.dart              # MaterialApp locale wiring

  server/internal/email/
    templates/               # layout + per-mail HTML/TXT (structure may gain lang)
    email.go                 # message builders take language
  server/internal/site/pages/
    privacy.html …           # or privacy_<lang> / i18n tables

  docs/play/store-listing.md # en-IN + hi/te/ta/bn listing blocks

  tasks/spec-ui-localisation-gen-l10n.md  # this file
```

---

## Code style

### Flutter UI

Same as prior draft: `context.l10n.key`, `lowerCamelCase` ARB keys, placeholders for names/counts, no comments per `AGENTS.md`.

### Emails (illustrative)

```go
type Welcome struct {
	AccountID string
	To        string
	FirstName string
	Language  string // en|hi|te|ta|bn; empty => en
}

func (w Welcome) message() (message, error) {
	lang := normalizeLang(w.Language)
	copy := welcomeCopy(lang) // subject, preheader, reason, button label, …
	// render existing template with copy fields
}
```

Callers load profile language when `accountID` is known; deletion-by-email looks up account language or uses `en`.

### Legal pages

Prefer `?lang=hi` (or `Accept-Language` as secondary) with English default so existing Play URLs keep working. Nav labels and body from locale tables; operator identity strings stay consistent across languages.

### Play listings

Keep policy rules in `store-listing.md` (no emoji, no ALL CAPS abuse, honest content). Each locale section: App name (≤30), Short (≤80), Full (≤4000) with measured counts.

---

## Testing strategy

| Area | Tests |
|------|--------|
| UI | Unit locale mapping; widget tests with `Locale('hi')`; update expects as screens migrate; Pixel smoke |
| Email | Table-driven: each template × each lang asserts subject substring + critical HTML; retain escape/bidi tests |
| Site | `go test` HTTP handlers for `?lang=`; placeholder script; spot-check in browser |
| Listings | Character-count script/checklist in doc; human Console preview |

---

## Boundaries

### Always

- Profile language drives UI + AI + student emails + preferred web lang.  
- English fallback.  
- `dart format` / `flutter analyze` / `flutter test` / relevant `go test` before merge.  
- Honest copy about lessons.  
- Keep `feedback_ops` in English.

### Ask first

- Delaying welcome email until after setup.  
- Changing canonical Play privacy/terms URLs.  
- Publishing Hindi (etc.) Play listings before UI for that language is mostly done.  
- New script fonts or a sixth language.  
- TMS / OTA translation SDK.  
- Translating **lesson** decks under this workstream.

### Never

- Put catalogue lesson bodies into Flutter ARB.  
- Second Pebby-only language setting.  
- Localise ops-only email to student languages.  
- Commit Resend/Play secrets.  
- Claim store listing “full Hindi app” while chrome is still English.

---

## Phased delivery (spec-level)

| Phase | Outcome |
|-------|---------|
| **P0** | Flutter gen-l10n scaffold + LocaleController + switch moment + pilot strings |
| **P1** | UI: shell + auth + home |
| **P2** | UI: ASKMe + Scan + Study chrome |
| **P3** | UI: Me + paywall + errors |
| **P4** | Emails: locale-aware student templates + caller wiring + Go tests |
| **P5** | Legal/support pages in five languages + lang selector/default en |
| **P6** | Play listing copy in `store-listing.md` for five locales; Console paste when UI ready |
| **P7** | Fill/review hi/te/ta/bn quality; 1.3× layout QA |

P4–P6 may start once P0 exists (shared language codes); publishing Play translations waits until P1–P3 are largely done for that language.

---

## Risks and mitigations

| Risk | Mitigation |
|------|------------|
| User never finishes setup → no welcome | Acceptable for v1; optional later: delayed English nudge after N days — ask first |
| Double welcome after deploy | Idempotent: only on first `CompleteSetup`; no signup send |
| Reset without session | Look up account by email → profile.language; else en |
| Hindi Play listing vs English UI | Gate Console publish on UI readiness (existing store-listing note) |
| Legal translation quality / liability | Machine draft + native review before calling it final; English canonical |
| Large Flutter extract | Phased PRs by feature |
| Email template explosion | Prefer one HTML structure + copy maps over five full HTML forks unless layout must diverge |

---

## Size expectation

| Artifact | Effect of this spec |
|----------|---------------------|
| Play download (~12 MB) | +~0.1–0.5 MB from UI ARBs only |
| Emails / legal / listings | **0** APK bytes |

---

## Open questions

1. **Generated Flutter l10n files:** commit to git or CI-only?  
2. **Legal URL shape:** `?lang=hi` vs `/hi/privacy`?  
3. **Play listing publish:** require full UI P1–P3 for a locale before Console translation goes live? (Recommended: **yes**.)  
4. **Coming soon languages** on the in-app sheet: unchanged until we add ARBs?  
5. **Abandoned setup:** if someone never finishes setup, they get no welcome — OK for v1, or add a delayed English fallback later?

**Defaults if you approve without answering:**  
(1) commit generated l10n, (2) `?lang=`, (3) yes gate listing publish on UI readiness, (4) coming-soon list unchanged, (5) no welcome until setup complete (no delayed fallback in v1).

**Already decided:** welcome email fires after **all setup tasks complete**, in the chosen language.

---

## Approval gate

- [ ] Human accepts or corrects **Assumptions**  
- [ ] Human answers **Open questions** (or “defaults OK”)  
- [ ] Then: `tasks/plan-ui-localisation-gen-l10n.md` + `tasks/todo-ui-localisation-gen-l10n.md`  
- [ ] Then: implement by phase  

**Lessons remain out of scope** until a separate content spec.
