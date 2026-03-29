# Tally — Team Task Breakdown

> 3 team members. Tasks are grouped into **phases** that should be completed roughly in order. Within each phase, all 3 members can work in parallel on their assigned items. Phases should take roughly equal effort across members.

---

## Phase 0 — Project Setup (do together, ~1 hour)

Everyone should be present for this so you're all starting from the same foundation.

- [ ] Create the Xcode project (Tally, iOS 17+, SwiftUI lifecycle)
- [ ] Set up the folder structure from the TRD
- [ ] Initialize a shared Git repo and agree on a branching strategy (e.g., feature branches → `main`)
- [ ] Add the SwiftData `ModelContainer` to `TallyApp.swift`

---

## Phase 1 — Core Foundation

### Member A — Data Layer & Business Logic

| # | Task | Files | Est. |
|---|------|-------|------|
| A1 | Implement `Habit` model with all properties | `Models/Habit.swift`, `Models/HabitType.swift` | 1 hr |
| A2 | Implement `HabitLog` model | `Models/HabitLog.swift` | 30 min |
| A3 | Build `StreakEngine` — current streak, best streak, completions in period, goal-met check | `Services/StreakEngine.swift` | 3 hr |
| A4 | Handle break habit streak logic (days since last slip, auto-calculation on app launch) | `Services/StreakEngine.swift` | 2 hr |
| A5 | Write unit tests for `StreakEngine` (daily build, weekly build, break, gaps, edge cases) | `Tests/StreakEngineTests.swift` | 2 hr |
| A6 | Build `DateHelpers` utility (start of day, start of week, date ranges) | `Utilities/DateHelpers.swift` | 1 hr |

**Phase 1 total for A: ~9.5 hours**

---

### Member B — Home Screen & Daily Logging

| # | Task | Files | Est. |
|---|------|-------|------|
| B1 | Build `HomeViewModel` — fetch habits, handle logging, reordering | `ViewModels/HomeViewModel.swift` | 2 hr |
| B2 | Build `HomeView` — scrollable list of habit cards, empty state with onboarding message | `Views/Home/HomeView.swift` | 2 hr |
| B3 | Build `HabitCardView` — display emoji, name, streak count, tap-to-log | `Views/Home/HabitCardView.swift` | 2 hr |
| B4 | Build `ProgressRingView` for build habits (animated circular arc) | `Views/Shared/ProgressRingView.swift` | 1.5 hr |
| B5 | Build `StreakCounterView` for break habits (prominent day count + "I slipped" button with confirmation) | `Views/Shared/StreakCounterView.swift` | 1.5 hr |
| B6 | Implement the undo toast (5-second window to undo a log) | `Views/Shared/` (toast component) | 1 hr |

**Phase 1 total for B: ~10 hours**

---

### Member C — Habit Creation & Detail View

| # | Task | Files | Est. |
|---|------|-------|------|
| C1 | Build `AddHabitSheet` — form with name, emoji picker, type toggle, frequency goal, color picker | `Views/Creation/AddHabitSheet.swift` | 3 hr |
| C2 | Build `HabitDetailViewModel` — stats calculations, log history | `ViewModels/HabitDetailViewModel.swift` | 1.5 hr |
| C3 | Build `HabitDetailView` — current streak, best streak, total completions layout | `Views/Detail/HabitDetailView.swift` | 2 hr |
| C4 | Build `CalendarHeatMapView` — 90-day grid with color intensity per day | `Views/Detail/CalendarHeatMapView.swift` | 2.5 hr |
| C5 | Build `MilestoneBadgeRow` — horizontal scroll of earned milestone badges | `Views/Detail/MilestoneBadgeRow.swift` | 1 hr |

**Phase 1 total for C: ~10 hours**

---

## Phase 2 — Animations & Milestones

### Member A — Milestone System

| # | Task | Files | Est. |
|---|------|-------|------|
| A7 | Build `MilestoneService` — detect newly reached milestones, prevent replays | `Services/MilestoneService.swift` | 2 hr |
| A8 | Write unit tests for `MilestoneService` | `Tests/MilestoneServiceTests.swift` | 1 hr |
| A9 | Build `MilestoneOverlay` — full-screen overlay that triggers on milestone, dismissible on tap or after 3s | `Views/Shared/MilestoneOverlay.swift` | 1.5 hr |

**Phase 2 total for A: ~4.5 hours**

---

### Member B — Micro-Animations & Haptics

| # | Task | Files | Est. |
|---|------|-------|------|
| B7 | Card tap bounce animation (`.scaleEffect` + spring) | `Views/Home/HabitCardView.swift` | 1 hr |
| B8 | Progress ring fill animation (`.trim` + easeOut) | `Views/Shared/ProgressRingView.swift` | 1 hr |
| B9 | Idle pulse animation on unlogged habits | `Views/Home/HabitCardView.swift` | 1 hr |
| B10 | Build `HapticManager` — light, medium, heavy, double-tap patterns | `Utilities/HapticManager.swift` | 1 hr |
| B11 | Integrate haptics into card tap, streak increment, and milestones | across views | 30 min |

**Phase 2 total for B: ~4.5 hours**

---

### Member C — Celebration Animations

| # | Task | Files | Est. |
|---|------|-------|------|
| C6 | `ParticleBurstView` — Spark milestone (Canvas + random velocity particles) | `Animations/ParticleBurstView.swift` | 2 hr |
| C7 | `FlameAnimationView` — Fire milestone (gradient layers / TimelineView) | `Animations/FlameAnimationView.swift` | 2 hr |
| C8 | `LightningEffectView` — Lightning milestone (screen flash + bolt icon) | `Animations/LightningEffectView.swift` | 1 hr |
| C9 | `SupernovaView` — Supernova milestone (confetti particle system) | `Animations/SupernovaView.swift` | 2 hr |

**Phase 2 total for C: ~7 hours**

---

## Phase 3 — Integration & Polish

### Member A — Edit, Archive & Edge Cases

| # | Task | Files | Est. |
|---|------|-------|------|
| A10 | Edit habit flow (update name, emoji, goal, color) | `Views/Creation/AddHabitSheet.swift` (reuse in edit mode) | 1.5 hr |
| A11 | Archive/unarchive habit + filter archived from home view | `HomeViewModel`, `Habit` model | 1 hr |
| A12 | Handle timezone and multi-day gap edge cases in StreakEngine | `Services/StreakEngine.swift` | 1.5 hr |

**Phase 3 total for A: ~4 hours**

---

### Member B — Drag-and-Drop & Navigation Polish

| # | Task | Files | Est. |
|---|------|-------|------|
| B12 | Drag-to-reorder habits on home screen (update `sortOrder`) | `Views/Home/HomeView.swift` | 2 hr |
| B13 | Navigation polish — smooth transitions between home and detail views | across views | 1 hr |
| B14 | Dark theme polish — consistent colors, accent colors per habit | across views | 1 hr |

**Phase 3 total for B: ~4 hours**

---

### Member C — Legend Animation & Demo Prep

| # | Task | Files | Est. |
|---|------|-------|------|
| C10 | Legend badge animation (`.symbolEffect(.bounce)` + permanent badge) | `Animations/` | 1.5 hr |
| C11 | Empty state / first-launch onboarding message polish | `Views/Home/HomeView.swift` | 1 hr |
| C12 | Seed demo data (pre-built habits with history for impressive demo) | `Utilities/DemoData.swift` | 1.5 hr |

**Phase 3 total for C: ~4 hours**

---

## Phase 4 — Testing & Demo (do together, ~3 hours)

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
