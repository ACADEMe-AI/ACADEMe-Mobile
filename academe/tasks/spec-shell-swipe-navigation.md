# Spec: Shell edge-swipe tabs + ASKMe mode swipe

Status: **Implemented** (Phases 1–4). Spec + plan + todo locked 2026-11-12; shell/askme tests green.

## Assumptions (locked unless you correct)

1. **Platform:** Flutter Android-first app shell (`AppShell` + `AppNavBar` + `AskMeScreen`). No server/API changes.
2. **Bottom-nav swipe order skips Scan.** Pill order: Home (0) ↔ ASKMe (1) ↔ Study (3) ↔ Me (4). Scan (2) stays the center action; edge-swipe never lands on Scan.
3. **Zone split:**
   - **Left/right edge strips** (~24 logical px) → change bottom-nav pill tab.
   - **Middle of ASKMe** → change `ChatMode` Explain ↔ Solve ↔ Quiz me.
   - At first/last mode, middle swipe does **not** leave ASKMe; leaving ASKMe is **edge-only**.
4. **Direction:** Swipe right → previous in order; swipe left → next. Same for modes.
5. **Taps stay.** ModeBar and nav pill taps unchanged; swipe is additive.
6. **Pushed routes out of scope for v1.** History, Me settings, decks, scan flow, sheets: no new edge-swipe above the shell.
7. **Vertical scroll wins** when `|dy|` dominates.
8. **No haptics** for shell or mode swipe (v1). Auth/setup haptics elsewhere stay untouched.
9. **Hard stop at ends** (chosen UX): at Home / Me / Explain / Quiz, further swipe in that direction is a no-op — no rubber-band. Discrete tabs feel clearer; rubber-band implies a scrollable canvas and invites accidental “is it broken?” at the ends.
10. **Transitions (chosen UX):**
    - **Card swipe** when the shell move is **ASKMe ↔ Home** or **ASKMe ↔ Study** (either direction: leaving or entering ASKMe along those edges). Content slides like stacked cards following the finger / completing after a fling.
    - **Basic tab transition** for **Study ↔ Me** and any other non–ASKMe-adjacent change (including nav **taps** that are not ASKMe↔Home/Study): keep simple — short fade / cross-fade or current instant `IndexedStack` switch. Do not invent a second card system for Me↔Study.
11. **ASKMe mode visual:** one conversation surface + horizontal transition when mode changes (VM is single-mode / one thread). Not three live chat pages.
12. **Scan + edge:** from Scan screen, edge swipe goes ASKMe (prev) or Study (next) via the pill order helper.
13. **Accessibility:** existing semantics remain; swipe is extra.

---

## Objective

Students switch main tabs and ASKMe modes with thumbs, without always reaching ModeBar or the bottom pill.

**User stories**

- Middle-swipe ASKMe cycles Explain → Solve → Quiz me (and back); first/last reachable; ends hard-stop.
- Edge-swipe on Home / ASKMe / Study / Me moves along Home ↔ ASKMe ↔ Study ↔ Me.
- ASKMe ↔ Home and ASKMe ↔ Study feel like **card swipes**; other tab changes stay **basic**.
- Long chat vertical scroll does not flip mode or shell tab.

---

## Current state (verified in repo)

| Piece | Today |
|-------|--------|
| Shell tabs | `AppShell` `IndexedStack` + `_tab` / `_select` |
| Nav pill | `AppNavBar._Tabs` lists only `0, 1, 3, 4` (Scan omitted) — **order already duplicated in UI** |
| ASKMe modes | `ModeBar` + `setMode`; body `AnimatedSwitcher` (not horizontal pager) |
| Gestures | None for shell edge or mode swipe |
| Haptics | Used in auth/setup/keycap — **not** required for this feature |

---

## DRY / structure (must not violate)

Today the pill order `0, 1, 3, 4` lives only inside `AppNavBar._Tabs`. Swipe needs the same order. **Do not copy the list into `AppShell` as a second literal.**

| Rule | Detail |
|------|--------|
| **Single pill-tab order** | One shared constant or small helper (e.g. `ShellTabs.pillOrder` / `nextPillTab(current, delta)`) used by nav display **and** edge swipe. Scan stays out. |
| **Single shell select path** | Edge swipe and nav taps both call existing `_select` (or a thin wrapper that then calls `_select`). No parallel `_tab =` writes. |
| **Single mode path** | Mode swipe and ModeBar both call `AskMeViewModel.setMode`. No second mode field in the widget. |
| **One transition chooser** | One function: `(from, to) → card vs basic`. Card only for pairs involving ASKMe with Home or Study. Do not fork “swipe transition” vs “tap transition” into two animation stacks if they share the same from/to rule — taps on ASKMe↔Home/Study may use **basic** to avoid heavy animation on every pill tap; **card is required for edge-swipe** on those pairs. (Locked: card for edge-driven ASKMe↔Home/Study; taps may stay basic.) |
| **No duplicate ModeBar** | Keep one `ModeBar`; swipe only updates mode; indicator stays driven by `viewModel.mode`. |
| **No third chat tree** | Do not mount three `AskMeScreen` bodies in a `PageView` that each own messages — one body, animate transition. |
| **Edge detector once** | One shell-level edge overlay/wrapper around the `IndexedStack` (or body), not per-tab copy-pasted detectors on Home/Study/Me/ASKMe. |

If a helper file is needed, prefer something small under `lib/ui/shell/` (e.g. `shell_tabs.dart`) rather than logic split across askme + shell with two orders.

---

## Behavior spec

### A. Shell edge swipe

| Gesture | Result |
|---------|--------|
| Drag from **left edge**, move right | Previous pill tab if any |
| Drag from **right edge**, move left | Next pill tab if any |
| At Home / Me, further that way | **Hard stop** (no-op) |
| Start outside edge | Shell does not claim |

**Edge width:** 24 logical px.  
**ASKMe composer visible:** still edge-swipes via `_select` (unfocus as today).  
**Card vs basic:** see Transitions below.

### B. ASKMe mode swipe (middle)

| Gesture | Result |
|---------|--------|
| Horizontal swipe on body (not edge) | Previous/next `ChatMode` |
| Explain + previous / Quiz + next | **Hard stop** |
| ModeBar tap | Unchanged |

### C. Transitions

| Change | Motion |
|--------|--------|
| Edge swipe **ASKMe ↔ Home** | Card swipe (horizontal slide; outgoing/incoming like cards) |
| Edge swipe **ASKMe ↔ Study** | Card swipe |
| Edge swipe **Study ↔ Me** | Basic (fade / short cross-fade / instant — pick one basic style and reuse) |
| Nav **tap** any tab | Basic (avoid surprising full card on every tap) |
| ASKMe **mode** change (swipe or tap) | Horizontal slide of the ASKMe body content; ModeBar pill slides as today |

### D. Gesture priority

1. Routes/sheets above shell → feature inactive.  
2. Edge horizontal → shell.  
3. ASKMe middle horizontal → mode.  
4. Vertical → scroll.

---

## Tech stack

- Flutter, existing MVVM. Stock gesture + animation APIs. **No new packages. No haptics for this feature.**

---

## Commands

From `academe/`:

```bash
flutter test test/ui/shell/ test/ui/askme/
flutter analyze lib/ui/shell lib/ui/askme
```

Manual: edge swipes on all pill tabs; card feel ASKMe↔Home/Study; basic Study↔Me; middle mode swipes; hard stops; vertical chat scroll.

---

## Project structure

```
academe/lib/ui/shell/shell_tabs.dart            → pill order + next/prev (DRY) [new if needed]
academe/lib/ui/shell/widgets/app_shell.dart     → edge swipe, transition wrapper, _select
academe/lib/ui/shell/widgets/app_nav_bar.dart   → consume shared pill order
academe/lib/ui/askme/widgets/askme_screen.dart  → mode swipe + horizontal body transition
academe/lib/ui/askme/widgets/mode_bar.dart      → taps only; stays in sync via mode
academe/test/ui/shell/                          → order helper + edge/transition tests
academe/test/ui/askme/                          → mode swipe tests
academe/tasks/spec-shell-swipe-navigation.md
```

---

## Code style

```dart
/// Shared by nav pill and edge swipe — single source of truth.
abstract final class ShellTabs {
  static const pillOrder = [0, 1, 3, 4]; // Home, ASKMe, Study, Me
  static const askMe = 1;
  static const edgeWidth = 24.0;

  static int? step(int current, int delta) {
    final i = pillOrder.indexOf(current);
    final at = i < 0
        ? (delta < 0 ? 0 : pillOrder.length - 1) // Scan → nearest side
        : i;
    final j = (i < 0 ? at : i) + delta;
    if (i < 0) {
      // From Scan: prev → ASKMe, next → Study
      return delta < 0 ? 1 : 3;
    }
    if (j < 0 || j >= pillOrder.length) return null; // hard stop
    return pillOrder[j];
  }

  static bool useCardSwipe(int from, int to) {
    const ask = askMe;
    bool pair(int a, int b) =>
        (from == a && to == b) || (from == b && to == a);
    return pair(ask, 0) || pair(ask, 3);
  }
}
```

(Exact Scan branching can be refined in Plan; behavior is fixed.)

---

## Testing strategy

| Level | What |
|-------|------|
| Unit/widget | `ShellTabs.step` / `useCardSwipe`: order, hard stops, never returns `2`, card pairs only ASKMe↔Home/Study |
| Widget | Mode swipe updates mode; ModeBar aligned; ends hard-stop; no shell change |
| Widget | Edge path calls select with stepped index |
| Manual | Card vs basic feel; keyboard open on ASKMe; vertical scroll |

---

## Boundaries

- **Always:** Shared pill order; `_select` + `setMode`; hard stops; no haptics here; tests for helper + gestures; update this spec if behavior changes.
- **Ask first:** Edge width change; card on nav taps; middle-swipe leaving ASKMe; Scan in swipe chain; swipe on pushed routes.
- **Never:** Duplicate tab-order literals; three live ASKMe chat trees; swipe onto Scan; new dependencies for this feature; remove tap paths.

---

## Success criteria

1. Middle swipe cycles Explain ↔ Solve ↔ Quiz; hard stop at ends; ModeBar + taps work.  
2. Middle swipe never changes bottom-nav tab.  
3. Edge swipe moves only along Home ↔ ASKMe ↔ Study ↔ Me; never selects Scan.  
4. Edge ASKMe↔Home and ASKMe↔Study use **card** transition; Study↔Me (and taps) use **basic**.  
5. No haptics added for these gestures.  
6. Pill order defined once and shared by nav + swipe (no DRY regression).  
7. Vertical chat/list scroll remains usable.  
8. Targeted flutter tests pass.

---

## Decisions log (this round)

| Topic | Decision |
|-------|----------|
| Haptics | **None** for this feature |
| End behavior | **Hard stop** |
| ASKMe ↔ Home / Study (edge) | **Card swipe** |
| Other tab changes | **Basic** transition |
| Mode at ends | Hard stop; shell only via edge |
| DRY | Shared `ShellTabs` (or equivalent); one `_select` / `setMode`; one edge host; one body for ASKMe |

## Open questions

None blocking. Say **approve spec** (or corrections) to move to Phase 2 Plan (`tasks/plan.md` + `tasks/todo.md`).

---

## Out of scope (v1)

- Swipe on pushed screens  
- Reordering bottom nav / including Scan in the chain  
- Coach marks  
- Rubber-band overscroll  
- Haptics for tab/mode swipe  
- Card animation on every nav tap  
