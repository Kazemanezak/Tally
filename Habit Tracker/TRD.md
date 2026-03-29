# Technical Requirements Document — Tally

## Platform & Tools

| Attribute | Value |
|-----------|-------|
| Platform | iOS 17+ |
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Persistence | SwiftData |
| Architecture | MVVM |
| Min Xcode | 15.0 |
| Target Devices | iPhone (portrait only for MVP) |

---

## Architecture Overview

```
┌─────────────────────────────────────┐
│              Views (SwiftUI)        │
│  HomeView · HabitDetailView · ...   │
├─────────────────────────────────────┤
│           ViewModels                │
│  HomeViewModel · HabitDetailVM      │
├─────────────────────────────────────┤
│           Services                  │
│  StreakEngine · MilestoneService    │
├─────────────────────────────────────┤
│           Models (SwiftData)        │
│  Habit · HabitLog · Milestone       │
└─────────────────────────────────────┘
```

The app follows MVVM. Views observe ViewModels via `@Observable`. ViewModels call into service classes for business logic (streak calculation, milestone detection). Models are SwiftData `@Model` classes stored in a local `ModelContainer`.

---

## Data Models

### Habit

```swift
@Model
class Habit {
    var id: UUID
    var name: String
    var emoji: String
    var type: HabitType          // .build or .break
    var frequencyGoal: Int       // e.g., 2 (times per period)
    var frequencyPeriod: Period  // .daily or .weekly
    var accentColor: String      // hex color code
    var sortOrder: Int
    var isArchived: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var logs: [HabitLog]
}

enum HabitType: String, Codable {
    case build
    case `break`
}

enum Period: String, Codable {
    case daily
    case weekly
}
```

### HabitLog

```swift
@Model
class HabitLog {
    var id: UUID
    var date: Date              // calendar day (time stripped)
    var completionCount: Int    // for build habits, how many times logged that day
    var didSlip: Bool           // for break habits, true if user reset streak
    var habit: Habit?
}
```

### Milestone (value type, not persisted separately)

```swift
struct MilestoneDefinition {
    let name: String           // "Spark", "Fire", etc.
    let threshold: Int         // streak length to trigger
    let animationType: AnimationType
}

enum AnimationType {
    case particleBurst
    case flame
    case lightning
    case supernova
    case legendBadge
}
```

---

## Key Services

### StreakEngine

Responsible for all streak calculations. Pure logic, no UI dependencies — easy to unit test.

```
StreakEngine
├── currentStreak(for habit: Habit) -> Int
├── bestStreak(for habit: Habit) -> Int
├── completionsInCurrentPeriod(for habit: Habit) -> Int
├── isGoalMetToday(for habit: Habit) -> Bool
└── processEndOfDay()   // auto-increments break streaks
```

**Streak calculation rules:**

- **Build / daily**: Streak = consecutive days where `completionCount >= frequencyGoal`.
- **Build / weekly**: Streak = consecutive calendar weeks where total `completionCount >= frequencyGoal`. Current (incomplete) week counts if goal is already met.
- **Break**: Streak = number of days since the most recent `didSlip == true` log (or since `createdAt` if no slips).

Edge cases to handle:
- App not opened for several days → streak engine must evaluate all missed days on next launch.
- Timezone changes → use `Calendar.current` with the user's local timezone; store dates as calendar dates, not absolute timestamps.

### MilestoneService

```
MilestoneService
├── checkMilestone(streak: Int) -> MilestoneDefinition?
└── earnedMilestones(for habit: Habit) -> [MilestoneDefinition]
```

Returns the highest newly-reached milestone (if any) after a streak changes. The service compares the new streak against the milestone thresholds and the habit's previously achieved milestones to avoid replaying old celebrations.

---

## View Hierarchy

```
App
└── HomeView
    ├── HabitCardView (repeated in ScrollView)
    │   ├── ProgressRingView (build habits)
    │   ├── StreakCounterView (break habits)
    │   └── MicroAnimationLayer
    ├── AddHabitSheet
    ├── HabitDetailView
    │   ├── StatsSection
    │   ├── CalendarHeatMapView
    │   └── MilestoneBadgeRow
    └── MilestoneOverlay (full-screen celebration)
```

### Key View Details

**HabitCardView** — A card in the home list. Shows emoji, name, streak count, and either a progress ring (build) or "days clean" counter (break). Tappable to log; long-press or swipe for detail.

**ProgressRingView** — A circular arc that animates from 0 to the current completion ratio. Uses `trim(from:to:)` with a spring animation.

**CalendarHeatMapView** — A 90-day grid (similar to GitHub's contribution graph). Each cell's opacity maps to the number of completions that day. Built with a `LazyVGrid` of small rounded rectangles.

**MilestoneOverlay** — A `ZStack` overlay on the root view. Triggered by `MilestoneService`. Uses a `TimelineView` or `Canvas` for particle effects. Dismissed on tap or after 3 seconds.

---

## Animation Specifications

All animations use SwiftUI primitives unless noted. Target: 60fps on iPhone 12 and later.

| Animation | Technique | Duration |
|-----------|-----------|----------|
| Card tap bounce | `.scaleEffect` with `.spring(response: 0.3, dampingFraction: 0.5)` | ~0.4s |
| Progress ring fill | `.trim` + `.animation(.easeOut(duration: 0.6))` | 0.6s |
| Idle pulse (unlogged) | `.opacity` oscillation via `withAnimation(.easeInOut.repeatForever())` | 2s cycle |
| Particle burst (Spark) | `Canvas` with random velocity particles | 1s |
| Flame (Fire) | Lottie animation or `TimelineView` with gradient layers | 1.5s |
| Lightning | `Rectangle` overlay flash + SF Symbol `bolt.fill` scale-in | 0.8s |
| Supernova | `Canvas` particle system + confetti using `CAEmitterLayer` (UIKit bridge) | 2.5s |
| Legend badge | Animated SF Symbol with `.symbolEffect(.bounce)` | 1s |

Haptic feedback via `UIImpactFeedbackGenerator`:
- Card tap → `.light`
- Streak increment → `.medium`
- Milestone → `.heavy` (double tap pattern)

---

## Project Structure

```
Tally/
├── App/
│   ├── TallyApp.swift           // @main, ModelContainer setup
│   └── ContentView.swift
├── Models/
│   ├── Habit.swift
│   ├── HabitLog.swift
│   └── HabitType.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   └── HabitDetailViewModel.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HabitCardView.swift
│   ├── Detail/
│   │   ├── HabitDetailView.swift
│   │   ├── CalendarHeatMapView.swift
│   │   └── MilestoneBadgeRow.swift
│   ├── Creation/
│   │   └── AddHabitSheet.swift
│   └── Shared/
│       ├── ProgressRingView.swift
│       ├── StreakCounterView.swift
│       └── MilestoneOverlay.swift
├── Services/
│   ├── StreakEngine.swift
│   └── MilestoneService.swift
├── Animations/
│   ├── ParticleBurstView.swift
│   ├── FlameAnimationView.swift
│   ├── LightningEffectView.swift
│   └── SupernovaView.swift
├── Utilities/
│   ├── DateHelpers.swift
│   └── HapticManager.swift
├── Resources/
│   └── Assets.xcassets
└── Tests/
    ├── StreakEngineTests.swift
    └── MilestoneServiceTests.swift
```

---

## Persistence Setup

```swift
@main
struct TallyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, HabitLog.self])
    }
}
```

SwiftData handles migrations automatically for the MVP. No manual schema versioning needed unless the model changes significantly between demo iterations.

---

## Testing Strategy

| Layer | What to Test | Framework |
|-------|-------------|-----------|
| StreakEngine | Streak calculation for all habit types, edge cases (gaps, timezone) | XCTest |
| MilestoneService | Correct milestone detection, no duplicate triggers | XCTest |
| ViewModels | State changes after logging, creating, archiving habits | XCTest with `@MainActor` |
| UI | Happy-path flows (create habit, log, see streak) | XCUITest (stretch goal) |

Priority: StreakEngine tests are the most important. Streak math is the core logic and the hardest to get right. Aim for 90%+ coverage on StreakEngine.

---

## Known Technical Risks

| Risk | Mitigation |
|------|------------|
| Complex particle animations may lag on older devices | Profile with Instruments; fall back to simpler opacity animations if needed |
| Break habit auto-increment requires background or next-launch processing | Calculate on launch by comparing dates rather than relying on background execution |
| SwiftData is relatively new and may have quirks | Keep model simple; avoid complex predicates; test early on device |
| Calendar/timezone edge cases in streak calculation | Use `Calendar.current.startOfDay(for:)` consistently; write targeted unit tests |

---

## MVP Build Order (Suggested)

1. **Models + SwiftData container** — Get persistence working first.
2. **HomeView + HabitCardView** — Basic list of habits with tap-to-log.
3. **StreakEngine** — Core streak math + unit tests.
4. **AddHabitSheet** — Habit creation flow.
5. **Micro-animations** — Card bounce, progress ring, haptics.
6. **MilestoneService + MilestoneOverlay** — Celebration animations.
7. **HabitDetailView + Heat Map** — Stats and history.
8. **Polish** — Idle animations, drag-to-reorder, undo toast.
