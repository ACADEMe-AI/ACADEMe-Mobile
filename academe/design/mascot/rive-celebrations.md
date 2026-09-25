# Motion & Celebrations — Rive + Flutter

**Stack choice:** **Rive** for mascot & celebration state machines · Flutter implicit/explicit animation for UI chrome.  
**Why Rive:** Interactive state machines, smaller iteration loop for mascot.

---

## 1. Flutter libraries (install when app repo is set up)

| Package | Purpose | Phase |
|---------|---------|-------|
| `rive` | Mascot + celebrations | 0.8 / 1.0 |
| `flutter_animate` or built-in | Micro UI motion | 1.0 |
| `lottie` | **Optional only** if a one-off non-mascot anim; prefer not mixing | avoid if possible |
| `confetti` | Lightweight particle bursts under Rive | optional |
| `google_fonts` | Only if custom font not bundled | optional |
| Haptics | `HapticFeedback` (SDK) | 1.0 |

**pubspec sketch (do not invent versions blindly — pin latest stable at install time):**

```yaml
dependencies:
  rive: # pin current stable
  # flutter_animate: # optional
```

**Checklist**
- [ ] Add `rive` to Flutter app  
- [ ] Bundle `.riv` in `assets/rive/`  
- [ ] Declare assets in `pubspec.yaml`  
- [ ] Preload celebration file after login  
- [ ] Fallback: static PNG if Rive fails to load  

---

## 2. Rive state machine — suggested inputs

**File:** `ace_mascot.riv` (rename to chosen mascot)  
**State machine name:** `MascotSM`

| Input | Type | Meaning |
|-------|------|---------|
| `Idle_Calm` | loop | Default home |
| `Idle_Study` | loop | In session |
| `wave` / `Empty_Invite` | trigger/loop | Welcome / empty CTA |
| `encourage` / `Incorrect_Soft` | trigger | Wrong answer (never mock) |
| `Correct_Micro` | trigger | Right answer micro |
| `SessionComplete` / `celebrate_small` | trigger | Session complete |
| `Celebrate_Big` | trigger | Perfect score |
| `Streak_Extend` | trigger | Daily streak +1 |
| `Streak_Milestone` | trigger | 7/14/30… hero |
| `think` / `Loading` | loop | AI generating |
| `Welcome_Back` | trigger | Return after absence |
| `Concern` | short | Streak at risk (soft) |
| `hide` / `reduce_motion` | boolean | User / system prefs |

**Artboard sizes:** 200×200 logical for overlay; 96×96 for inline.

---

## 3. Celebration map

| Event | Animation | UI chrome | Haptic | Cooldown |
|-------|-----------|-----------|--------|----------|
| First upload success | celebrate_small | check toast | success | once ever special |
| Flashcard session done | celebrate_small | “Done · N cards” | medium | per session |
| Quiz ≥ 80% | celebrate_small | score ring | success | per quiz |
| Quiz 100% | celebrate_big | full overlay 1.2s | success | per quiz |
| Practice test complete | celebrate_small / big if A | results sheet | success | per test |
| Streak 3/7/14/30 | celebrate_big | streak numeral | success | per milestone |
| Daily plan complete | celebrate_small | day check | light | daily |
| Wrong answer | encourage (subtle) | red flash border | light | no overlay spam |
| AI streaming start | think | skeleton | none | — |

**Anti-spam rules**
- No big celebration if user disabled mascot  
- Reduce-motion → skip Rive, show static success icon  
- Never block “Continue” behind animation end (> allow skip tap)  

---

## 4. UI motion (non-Rive)

| Pattern | Spec |
|---------|------|
| Button press | scale 0.97, 120ms expo-out |
| Tab switch | fade + slight slide 200ms |
| Sheet present | slide from bottom 320ms |
| List item enter | fade up stagger 40ms |
| Correct answer | border success 200ms |
| Incorrect | horizontal shake 200ms max 4px |

---

## 5. Mascot feedback rules

| Take | Our version |
|------|-------------|
| Mascot reacts to outcomes | Yes — limited events only |
| Guilt / nag | **Soft only**; no dark-pattern spam in P1 |
| XP / levels | Optional later; streak + mastery first |
| Sound | Off by default or follow system silent |

---

## 6. Asset pipeline checklist

- [ ] Commission or generate style frames  
- [ ] Build Rive state machine with all triggers  
- [ ] Export `.riv`  
- [ ] Engineer wraps `MascotView` widget  
- [ ] `CelebrationController` maps app events → triggers  
- [ ] QA on low-end Android (frame time)  
- [ ] QA reduce-motion  
- [ ] Dark background contrast (mascot not lost on `bg`)  

---

## 7. Widget API (contract for agents)

```dart
// Conceptual — implement in Flutter app repo
MascotView(state: MascotState.idle | wave | ...)
CelebrationOverlay.show(context, CelebrationType.sessionComplete)
```

Agents must not invent parallel mascot systems.
