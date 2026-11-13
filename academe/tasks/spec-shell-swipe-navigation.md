# Spec: Interactive shell card swipe + ASKMe mode swipe

Status: **Implemented** (interactive pager). Updated 2026-11-13 after finger-follow UX review.

## Assumptions (locked unless you correct)

1. **Platform:** Flutter Android-first app shell (`AppShell` + `AppNavBar` + `AskMeScreen`). No server/API changes.
2. **Swipe / transition order:** Home → ASKMe → Study → Me → Scan (Camera). Nav pill labels stay Home / ASKMe / Study / Me; camera stays the center keycap visually, but `pageOrder` places Scan after Me.
3. **Zone split on ASKMe:**
   - **Left/right edge strips** (~36 logical px) → shell tab change.
   - **Middle** → `ChatMode` Explain ↔ Solve ↔ Quiz me.
   - At Explain, middle swipe previous → **Home**. At Quiz, middle swipe next → **Study**.
4. **Direction:** Swipe right → previous in `pageOrder`; swipe left → next. Same for modes.
5. **Taps stay.** ModeBar and nav taps unchanged in meaning; both use the same card slide as swipe settle (~280ms).
6. **Pushed routes out of scope.** History, Me settings, decks, scan capture flow, sheets: no new shell swipe above the shell.
7. **Vertical scroll wins** when `|dy|` dominates (12px axis lock).
8. **No haptics** for shell or mode swipe.
9. **Hard stop at ends** with light rubber-band: Home and Scan (last). No wrap-around.
10. **Transitions:** one interactive card pager for all `pageOrder` moves (finger-follow + settle). Nav / Back / programmatic `_select` animate with the same settle (continuous distance for non-adjacent jumps).
11. **ASKMe mode visual:** one conversation surface + horizontal transition when mode changes.
12. **Accessibility:** existing semantics remain; swipe is extra. Respect `MediaQuery.disableAnimationsOf`.

---

## Objective

Students switch main tabs and ASKMe modes with thumbs; tab changes feel continuous, not instant.

**User stories**

- Full-width swipe on Home / Study / Me / Scan moves along `pageOrder`.
- ASKMe middle swipe cycles modes; ends leave to Home / Study; edges still move the shell.
- Me ↔ Camera slides with Camera entering from the right after Profile.
- Nav taps use the same card slide as finger settle.
- Mid-swipe cancel springs back; vertical scroll does not flip tabs.

---

## DRY / structure

| Rule | Detail |
|------|--------|
| **Single page order** | `ShellTabs.pageOrder` drives the pager; `pillOrder` drives nav labels only. |
| **Single shell select path** | Swipe commit and nav taps both call `_select`. |
| **Single mode path** | Mode swipe and ModeBar both call `AskMeViewModel.setMode`; ends call `onShellStep` → `_select`. |
| **One pager** | `ShellPager` owns finger-follow, settle, and nav-driven animate. |
| **No third chat tree** | One ASKMe body; animate mode change. |

---

## Behavior spec

### A. Shell swipe

| Gesture | Result |
|---------|--------|
| Horizontal drag (full width, except ASKMe middle) | Finger-follow; release commits or cancels |
| At Home / Scan, further that way | Rubber-band hard stop |
| Nav / Back / `_select` | Same card settle to target page |

### B. ASKMe mode swipe (middle)

| Gesture | Result |
|---------|--------|
| Horizontal swipe on body (not edge) | Previous/next `ChatMode` |
| Explain + previous | Leave to Home |
| Quiz + next | Leave to Study |
| ModeBar tap | Unchanged |

### C. Edge width

36 logical px (`ShellEdge.width`), layout-local X + same layout width.
