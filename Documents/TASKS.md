# Tally — Team Task Breakdown

> 3 team members. Tasks are grouped into **phases** that should be completed roughly in order. Within each phase, all 3 members can work in parallel on their assigned items. Phases should take roughly equal effort across members.

---

## Phase 0 — Project Setup (do together, ~1 hour) ✅ COMPLETE

Everyone should be present for this so you're all starting from the same foundation.

- [x] Create the Xcode project (Tally, iOS 17+, SwiftUI lifecycle)
- [x] Set up the folder structure from the TRD
- [x] Initialize a shared Git repo and agree on a branching strategy (e.g., feature branches → `main`)
- [x] Add the SwiftData `ModelContainer` to `TallyApp.swift`

---

## Phase 1 — Core Foundation

### Member A — Data Layer & Business Logic ✅ COMPLETE

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| A1 | Implement `Habit` model with all properties | `Models/Habit.swift`, `Models/HabitType.swift` | 1 hr | ✅ Done |
| A2 | Implement `HabitLog` model | `Models/HabitLog.swift` | 30 min | ✅ Done |
| A3 | Build `StreakEngine` — current streak, best streak, completions in period, goal-met check | `Services/StreakEngine.swift` | 3 hr | ✅ Done |
| A4 | Handle break habit streak logic (days since last slip, auto-calculation on app launch) | `Services/StreakEngine.swift` | 2 hr | ✅ Done |
| A5 | Write unit tests for `StreakEngine` (daily build, weekly build, break, gaps, edge cases) | `Tests/StreakEngineTests.swift` | 2 hr | ✅ Done (17 tests) |
| A6 | Build `DateHelpers` utility (start of day, start of week, date ranges) | `Utilities/DateHelpers.swift` | 1 hr | ✅ Done |

**Phase 1 total for A: ~9.5 hours — COMPLETE**

---

### Member B — Home Screen & Daily Logging ✅ COMPLETE

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| B1 | Build `HomeViewModel` — fetch habits, handle logging, reordering | `ViewModels/HomeViewModel.swift` | 2 hr | ✅ Done |
| B2 | Build `HomeView` — scrollable list of habit cards, empty state with onboarding message | `Views/Home/HomeView.swift` | 2 hr | ✅ Done |
| B3 | Build `HabitCardView` — display emoji, name, streak count, tap-to-log | `Views/Home/HabitCardView.swift` | 2 hr | ✅ Done |
| B4 | Build `ProgressRingView` for build habits (animated circular arc) | `Views/Shared/ProgressRingView.swift` | 1.5 hr | ✅ Done |
| B5 | Build `StreakCounterView` for break habits (prominent day count + "I slipped" button with confirmation) | `Views/Shared/StreakCounterView.swift` | 1.5 hr | ✅ Done |
| B6 | Implement the undo toast (5-second window to undo a log) | `Views/Shared/UndoToastView.swift` | 1 hr | ✅ Done |

**Phase 1 total for B: ~10 hours — COMPLETE**

---

### Member C — Habit Creation & Detail View ✅ COMPLETE

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| C1 | Build `AddHabitSheet` — form with name, SF Symbol picker, custom emoji input, type toggle, frequency goal, color picker | `Views/Creation/AddHabitSheet.swift` | 3 hr | ✅ Done |
| C2 | Build `HabitDetailViewModel` — stats calculations, log history | `ViewModels/HabitDetailViewModel.swift` | 1.5 hr | ✅ Done |
| C3 | Build `HabitDetailView` — current streak, best streak, total completions layout | `Views/Detail/HabitDetailView.swift` | 2 hr | ✅ Done |
| C4 | Build `CalendarHeatMapView` — 90-day grid with color intensity per day | `Views/Detail/CalendarHeatMapView.swift` | 2.5 hr | ✅ Done |
| C5 | Build `MilestoneBadgeRow` — horizontal scroll of earned milestone badges | `Views/Detail/MilestoneBadgeRow.swift` | 1 hr | ✅ Done |

**Phase 1 total for C: ~10 hours — COMPLETE**

---

## Phase 2 — Animations & Milestones

### Member A — Milestone System ❌ NOT STARTED

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| A7 | Build `MilestoneService` — detect newly reached milestones, prevent replays | `Services/MilestoneService.swift` | 2 hr | ❌ Empty stub |
| A8 | Write unit tests for `MilestoneService` | `Tests/MilestoneServiceTests.swift` | 1 hr | ❌ Empty stub |
| A9 | Build `MilestoneOverlay` — full-screen overlay that triggers on milestone, dismissible on tap or after 3s | `Views/Shared/MilestoneOverlay.swift` | 1.5 hr | ❌ Empty stub |

**Phase 2 total for A: ~4.5 hours — NOT STARTED**

---

### Member B — Micro-Animations & Haptics ✅ COMPLETE

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| B7 | Card tap bounce animation (`.scaleEffect` + spring) | `Views/Home/HabitCardView.swift` | 1 hr | ✅ Done |
| B8 | Progress ring fill animation (`.trim` + easeOut) | `Views/Shared/ProgressRingView.swift` | 1 hr | ✅ Done |
| B9 | Idle pulse animation on unlogged habits | `Views/Home/HabitCardView.swift` | 1 hr | ✅ Done |
| B10 | Build `HapticManager` — light, medium, heavy, double-tap patterns | `Utilities/HapticManager.swift` | 1 hr | ✅ Done |
| B11 | Integrate haptics into card tap, streak increment, and milestones | across views | 30 min | ⚠️ Partial (card tap done, milestone integration pending) |

**Phase 2 total for B: ~4.5 hours — MOSTLY COMPLETE** (haptic integration into milestones blocked on A7–A9)

---

### Member C — Celebration Animations ✅ COMPLETE

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| C6 | `ParticleBurstView` — Spark milestone (Canvas + random velocity particles) | `Animations/ParticleBurstView.swift` | 2 hr | ✅ Done |
| C7 | `FlameAnimationView` — Fire milestone (gradient layers / TimelineView) | `Animations/FlameAnimationView.swift` | 2 hr | ✅ Done |
| C8 | `LightningEffectView` — Lightning milestone (screen flash + bolt icon) | `Animations/LightningEffectView.swift` | 1 hr | ✅ Done |
| C9 | `SupernovaView` — Supernova milestone (confetti particle system) | `Animations/SupernovaView.swift` | 2 hr | ✅ Done |

**Phase 2 total for C: ~7 hours — COMPLETE**

---

## Phase 3 — Integration & Polish ❌ NOT STARTED

### Member A — Edit, Archive & Edge Cases

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| A10 | Edit habit flow (update name, emoji, goal, color) | `Views/Creation/AddHabitSheet.swift` (reuse in edit mode) | 1.5 hr | ❌ Not started |
| A11 | Archive/unarchive habit + filter archived from home view | `HomeViewModel`, `Habit` model | 1 hr | ❌ Not started |
| A12 | Handle timezone and multi-day gap edge cases in StreakEngine | `Services/StreakEngine.swift` | 1.5 hr | ❌ Not started |

**Phase 3 total for A: ~4 hours**

---

### Member B — Drag-and-Drop & Navigation Polish

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| B12 | Drag-to-reorder habits on home screen (update `sortOrder`) | `Views/Home/HomeView.swift` | 2 hr | ✅ Done (implemented in HomeViewModel + HomeView) |
| B13 | Navigation polish — smooth transitions between home and detail views | across views | 1 hr | ⚠️ Partial (navigation exists but only for break habits; build habits don't navigate to detail) |
| B14 | Dark theme polish — consistent colors, accent colors per habit | across views | 1 hr | ❌ Not started |

**Phase 3 total for B: ~4 hours**

---

### Member C — Legend Animation & Demo Prep

| # | Task | Files | Est. | Status |
|---|------|-------|------|--------|
| C10 | Legend badge animation (`.symbolEffect(.bounce)` + permanent badge) | `Animations/` | 1.5 hr | ❌ Not started |
| C11 | Empty state / first-launch onboarding message polish | `Views/Home/HomeView.swift` | 1 hr | ✅ Done (empty state with icon + message implemented) |
| C12 | Seed demo data (pre-built habits with history for impressive demo) | `Utilities/DemoData.swift` | 1.5 hr | ❌ Not started |

**Phase 3 total for C: ~4 hours**

---

## Phase 4 — Testing & Demo (do together, ~3 hours) ❌ NOT STARTED

- [ ] Full walkthrough of all 3 user flows from the PRD
- [ ] Test on a physical device — check animations at 60fps, haptics, and SwiftData persistence
- [ ] Fix any integration bugs from merging branches
- [ ] Rehearse the demo as a group

---

## Hour Summary

| Member | Phase 1 | Phase 2 | Phase 3 | Total (solo) |
|--------|---------|---------|---------|--------------|
| **A** — Data & Logic | 9.5 hr | 4.5 hr | 4 hr | **18 hr** |
| **B** — Home UI & Animations | 10 hr | 4.5 hr | 4 hr | **18.5 hr** |
| **C** — Creation, Detail & Celebrations | 10 hr | 7 hr | 4 hr | **21 hr** |

> Member C has slightly more hours due to the 4 celebration animations. If time is tight, Supernova (C9) can be simplified to reuse the particle burst with more particles and confetti colors, saving ~1 hour.

---

## Dependencies to Watch

These are the moments where one person's work depends on another's being done first:

- B1 (HomeViewModel) needs A1/A2 (models) — **Member A should finish models first day**
- B3 (HabitCardView) needs A3 (StreakEngine) for displaying streak counts
- A7 (MilestoneService) needs A3 (StreakEngine) done
- C6–C9 (celebration animations) need A9 (MilestoneOverlay) to have somewhere to render
- Phase 3 assumes all Phase 1–2 work is merged and working

---

## Progress Summary (as of 2026-04-08)

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 0 — Project Setup | ✅ Complete | 4/4 tasks |
| Phase 1 — Member A (Data & Logic) | ✅ Complete | 6/6 tasks |
| Phase 1 — Member B (Home Screen) | ✅ Complete | 6/6 tasks |
| Phase 1 — Member C (Creation & Detail) | ✅ Complete | 5/5 tasks |
| Phase 2 — Member A (Milestones) | ❌ Not Started | 0/3 tasks |
| Phase 2 — Member B (Micro-Animations) | ✅ Mostly Complete | 4.5/5 tasks |
| Phase 2 — Member C (Celebrations) | ✅ Complete | 4/4 tasks |
| Phase 3 — Member A (Edit/Archive) | ❌ Not Started | 0/3 tasks |
| Phase 3 — Member B (Polish) | ⚠️ Partial | 1.5/3 tasks |
| Phase 3 — Member C (Legend/Demo) | ⚠️ Partial | 1/3 tasks |
| Phase 4 — Testing & Demo | ❌ Not Started | 0/4 tasks |

**Overall: ~28 of 42 tasks complete (~67%)**

### Recommended Priority Order for Remaining Work

1. **A7 — `MilestoneService`** + **A8 — Tests** (milestone detection logic)
2. **A9 — `MilestoneOverlay`** (celebration overlay shell — connects to C6–C9 animations)
3. **B11 — Haptic integration into milestones** (blocked on A7–A9)
4. **A10 — Edit habit flow** + **A11 — Archive/unarchive**
5. **A12 — Timezone & multi-day gap edge cases**
6. **B13 — Navigation polish** + **B14 — Dark theme polish**
7. **C10 — Legend badge animation** + **C12 — Seed demo data** (waiting on full integration)
8. **Phase 4 — Testing & Demo** (full walkthrough, device testing, bug fixes, rehearsal)
