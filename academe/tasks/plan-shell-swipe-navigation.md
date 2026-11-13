# Implementation Plan: Shell edge-swipe + ASKMe mode swipe

**Spec:** `tasks/spec-shell-swipe-navigation.md` (approved)

## Overview

Add edge swipes to move among Home ↔ ASKMe ↔ Study ↔ Me, middle swipes on ASKMe for Explain ↔ Solve ↔ Quiz, card transitions for ASKMe↔Home/Study edge moves, basic transitions elsewhere, hard stops, no haptics. Shared pill-tab order to avoid DRY violations with `AppNavBar`.

## Architecture decisions

- **`ShellTabs` helper** — single `pillOrder`, `step`, `useCardSwipe`; nav + shell both consume it.
- **Keep `IndexedStack` children** — animate an overlay/`AnimatedSwitcher`-style wrapper on tab change for edge-driven card/basic transitions rather than replacing the stack with a full shell `PageView` (Scan + return-tab semantics stay simple).
- **ASKMe** — one body; horizontal transition on `setMode`; `GestureDetector`/`PageView`-like drag in the middle only; edges left to shell.
- **Edge host once** on shell body around the stack.
- **Nav taps** → basic transition (or instant); **edge** ASKMe↔Home/Study → card.

## Task order

1. `ShellTabs` + unit tests (foundation)
2. Wire `AppNavBar` to shared order
3. Edge swipe → `_select` via `ShellTabs.step` (basic transition first)
4. Card vs basic transition wrapper for edge-driven changes
5. ASKMe middle mode swipe + hard stop + horizontal body transition
6. Polish / regression tests / analyze

## Risks

| Risk | Mitigation |
|------|------------|
| Gesture fight with vertical scroll | Edge-only for shell; horizontal dominance for mode; hard stops |
| Android system back gesture | 24px edge + clear horizontal intent |
| IndexedStack + card animation complexity | Animate only on edge-driven select; taps stay basic/instant |
| DRY regression on tab indices | Nav must import `ShellTabs.pillOrder` |

## Checkpoints

- After 1–2: helper + nav DRY green
- After 3–4: edge swipe works on device/tests; card on ASKMe neighbors
- After 5–6: mode swipe + full success criteria
