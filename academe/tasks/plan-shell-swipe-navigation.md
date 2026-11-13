# Implementation Plan: Interactive shell card swipe + ASKMe mode swipe

**Spec:** `tasks/spec-shell-swipe-navigation.md` (updated 2026-11-13)

## Overview

`ShellPager` owns finger-follow card motion over `ShellTabs.pageOrder` (Home → ASKMe → Study → Me → Scan). ASKMe middle swipe cycles modes and leaves to Home/Study at the ends; ASKMe edges still drive the shell. Nav taps use the same settle animation. Nested horizontal scrollables (pill rows, PageViews) win the pointer so shell drag does not steal them.

## Architecture decisions

- **`ShellTabs.pageOrder`** — swipe/transition order including Scan after Me. **`pillOrder`** — nav labels only.
- **`ShellPager`** — always-mounted pages; `ListenableBuilder` + cached `child` so drag ticks do not rebuild tab bodies.
- **Nested horizontal deferral** — on pointer-down, hit-test for `RenderViewportBase` with horizontal axis; if present, shell does not claim that gesture.
- **ASKMe** — one body; middle Listener with axis lock; edges via `ShellEdge` (36px).
- **Motion** — unbounded `AnimationController` settle (~280ms); respects `disableAnimations`.

## Done

1. Shared `ShellTabs` + unit tests
2. Interactive `ShellPager` replacing `ShellTabHost` / edge-only host
3. ASKMe middle modes + end→shell; edge shell swipe
4. Nav/programmatic card settle; Me↔Scan direction
5. Gesture races (settle interrupt, nav-during-drag, multi-touch)
6. Nested horizontal scrollable deferral + localized drag rebuilds
7. Spec/plan updated; pager widget tests

## Risks

| Risk | Mitigation |
|------|------------|
| Gesture fight with vertical scroll | 12px axis lock |
| Gesture fight with horizontal child | Hit-test deferral on pointer-down |
| Android system back gesture | Edge on ASKMe only; clear horizontal intent elsewhere |
| Drag jank | Cached page children via `ListenableBuilder` |
