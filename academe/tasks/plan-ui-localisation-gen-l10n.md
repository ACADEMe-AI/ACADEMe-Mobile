# Plan: Multilingual surfaces (gen-l10n + emails + legal + Play)

Spec: `tasks/spec-ui-localisation-gen-l10n.md` — **approved with defaults** (welcome after setup; `?lang=`; commit generated l10n; gate Play listings on UI readiness).

## Approach

1. **Flutter locale** from existing `ProfileRepository` (ChangeNotifier) — no second LocaleController. `AppLanguage.locale` → `MaterialApp.locale`.
2. **gen-l10n** ARBs under `lib/l10n/`; thin `context.l10n` extension.
3. **Welcome email** moves from auth signup → profile `CompleteSetup` (once), with language.
4. Later slices: migrate UI screens; email copy maps; legal `?lang=`; Play listing docs.

## Slice order

| Slice | Deliverable |
|-------|-------------|
| A | gen-l10n scaffold + MaterialApp locale from profile + pilot keys + tests |
| B | Welcome email on setup complete (remove signup welcome) + Go tests |
| C+ | UI extract by feature; then emails locales; legal; Play copy |

## Risks

- Widget tests need l10n delegates when pumping MaterialApp — shared test helper.
- Profile null when logged out → `Locale('en')`.
