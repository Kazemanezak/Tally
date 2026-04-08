# Tally — iOS Habit Tracker

## Table of Contents
1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Schema](#schema)

---

## Overview

### Description

Tally is an iOS habit tracker designed to make logging habits feel entertaining and addictive. Users track **positive habits** they want to build (e.g., gym visits, reading) and **negative habits** they want to break (e.g., alcohol, smoking). The app uses streaks, milestone celebrations, and satisfying animations to keep users engaged and motivated.

### App Evaluation

| Attribute | Assessment |
|-----------|-----------|
| **Category** | Health & Fitness / Productivity |
| **Mobile** | Mobile-first (iOS only). The core interaction — tapping to log a habit — is inherently a quick, one-handed mobile action. A desktop version would lose the immediacy that makes the app compelling. |
| **Story** | Tally tells the story of small daily actions compounding into lasting change. Every tap builds (or breaks) a streak, and every milestone is a moment worth celebrating. The emotional backbone is the streak — losing one feels real, extending one feels earned. |
| **Market** | General public, ages 16+. Anyone who wants a lightweight, visually rewarding accountability tool without the complexity of a full life-management app. Especially well-suited for people who have tried habit trackers before and found them boring or overwhelming. |
| **Habit** | Daily use. The home screen is designed for a fast daily check-in — users open the app, tap their completed habits, and close it. The idle pulse animation on unlogged habits actively draws users back. |
| **Scope** | Narrow and focused. MVP deliberately excludes notifications, social features, cloud sync, and widgets. The scope is: add habits → log daily → see streaks → enjoy feedback. |

---

## Product Spec

### 1. User Stories

#### Required Must-Have Stories

- [x] User can create a new habit with a name, emoji icon, type (Build or Break), and frequency goal
- [x] User can view all active habits on a home screen as a scrollable list of cards
- [x] User can tap a Build habit card to log one completion, with a progress ring showing progress toward the goal
- [x] User can view a Break habit's current streak (days of abstinence) and reset it via a confirmation dialog
- [x] User can see streaks increment automatically and receive a celebration animation when hitting a milestone (3, 7, 14, 30, 100 days)
- [x] User can undo a log within 5 seconds via an inline toast
- [x] User can open a habit's detail view showing current streak, best streak, total completions, and a 90-day heat map
- [x] User's data persists locally across app launches using SwiftData

#### Optional Nice-to-Have Stories

- [ ] User can edit or archive an existing habit
- [ ] User can reorder habits via drag-and-drop on the main screen
- [ ] User can receive push notifications as daily reminders
- [ ] User can share their streak milestones to social media
- [ ] User can view a widget on their home screen showing today's habits
- [ ] User can sync data across devices via iCloud
- [ ] User can switch between dark and light mode

---

### 2. Screen Archetypes

**Home Screen**
- User can view all active habits as a scrollable list of cards
- User can tap a habit card to log a completion (Build) or see streak count (Break)
- User can tap "+" to open the habit creation sheet
- User can tap a habit card to navigate to the detail view

**Add Habit Sheet** (modal)
- User can enter a habit name
- User can pick an emoji icon
- User can toggle between Build and Break habit types
- User can set a frequency goal (daily or X times per week)
- User can pick an accent color

**Habit Detail View**
- User can view current streak, best streak, and total completions
- User can see a 90-day calendar heat map of their activity
- User can see earned milestone badges in a horizontal row

**Milestone Overlay** (full-screen modal)
- User sees a celebration animation when hitting a streak milestone
- User can dismiss the overlay by tapping or waiting 3 seconds

---

### 3. Navigation

#### Tab Navigation
*Tally is a single-screen app for MVP — no tab bar.*

#### Flow Navigation (Screen to Screen)

**Home Screen**
- Tapping "+" → **Add Habit Sheet** (modal slide-up)
- Tapping a habit card → **Habit Detail View** (push navigation)
- Hitting a milestone after logging → **Milestone Overlay** (full-screen overlay)

**Add Habit Sheet**
- Tapping "Create" → dismisses sheet → returns to **Home Screen** with new habit card

**Habit Detail View**
- Tapping back → returns to **Home Screen**

**Milestone Overlay**
- Tapping anywhere or 3-second timeout → dismisses → returns to **Home Screen**

---

## Wireframes

> 📋 *Hand-sketched wireframes will be added here — photograph and attach your team's sketches.*

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│  HOME SCREEN        │     │  ADD HABIT SHEET     │     │  DETAIL VIEW        │
│─────────────────────│     │─────────────────────│     │─────────────────────│
│  Tally          [+] │     │  New Habit           │     │  🏋️ Gym             │
│                     │     │                     │     │                     │
│ ┌─────────────────┐ │     │  Name: [__________] │     │  Streak: 7 🔥       │
│ │ 🏋️ Gym      7🔥 │ │     │                     │     │  Best:   12         │
│ │ [====    ] 2/3  │ │     │  Icon: [😀][🏋️][📚] │     │  Total:  34 logs    │
│ └─────────────────┘ │     │                     │     │                     │
│ ┌─────────────────┐ │     │  Type: [Build][Break]│     │  [  Heat Map Grid  ]│
│ │ 🚭 No Smoking   │ │     │                     │     │  [  90-day view    ]│
│ │  Days clean: 13 │ │     │  Freq: [Daily][Wkly] │     │                     │
│ └─────────────────┘ │     │  Goal: [___] times  │     │  🌟 ⚡ 🔥 ✨        │
│ ┌─────────────────┐ │     │                     │     │  (milestone badges) │
│ │ 📚 Reading  3✨ │ │     │  Color: [■][■][■]   │     │                     │
│ └─────────────────┘ │     │                     │     │                     │
│                     │     │  [      Create      ]│     │                     │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
```

### [BONUS] Digital Wireframes & Mockups

> *To be added — Figma or Sketch mockups.*

### [BONUS] Interactive Prototype

> *To be added — Figma prototype link.*

---

## Schema

### Models

#### Habit

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier for the habit |
| `name` | `String` | Display name (e.g., "Go to the Gym") |
| `emoji` | `String` | Single emoji icon selected by the user |
| `type` | `HabitType` | `.build` or `.break` |
| `frequencyGoal` | `Int` | Target completions per period (e.g., 2) |
| `frequencyPeriod` | `Period` | `.daily` or `.weekly` |
| `accentColor` | `String` | Hex color code for the card's accent |
| `sortOrder` | `Int` | User-defined display order |
| `isArchived` | `Bool` | Hidden from home view when true |
| `createdAt` | `Date` | Timestamp of habit creation |
| `logs` | `[HabitLog]` | Cascade-deleted relationship to log entries |

#### HabitLog

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier for the log entry |
| `date` | `Date` | Calendar day (time stripped to midnight) |
| `completionCount` | `Int` | Number of times logged on this date (Build habits) |
| `didSlip` | `Bool` | `true` if the user reset their streak (Break habits) |
| `habit` | `Habit?` | Parent habit reference |

#### MilestoneDefinition (value type, not persisted)

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Display name (e.g., "Spark", "Fire") |
| `threshold` | `Int` | Streak length required to earn (3, 7, 14, 30, 100) |
| `animationType` | `AnimationType` | Which celebration animation to play |

---

### Networking

Tally is fully **offline** for MVP — no network requests are made. All data is stored locally via SwiftData.

> If cloud sync is added in a future version, the following endpoints would apply:

| Screen | Request | Purpose |
|--------|---------|---------|
| App Launch | `[GET] /users/{id}/habits` | Fetch synced habits |
| Log Completion | `[POST] /habits/{id}/logs` | Sync a new log entry |
| Create Habit | `[POST] /habits` | Create habit in cloud |
| Archive Habit | `[PATCH] /habits/{id}` | Update archive status |

---

## Build Progress

### Sprint 1 — Completed Items

- [x] Xcode project created (iOS 17+, SwiftUI lifecycle)
- [x] Folder structure initialized per TRD spec
- [x] Git repository set up with feature branch strategy
- [x] SwiftData `ModelContainer` added to `TallyApp.swift`
- [x] `Habit` and `HabitLog` SwiftData models implemented
- [x] `HabitType` and `Period` enums defined
- [x] `StreakEngine` — current streak and best streak calculations (Build/daily)
- [x] `HomeViewModel` — fetch habits, handle logging
- [x] `HomeView` — scrollable list with empty state onboarding message
- [x] `HabitCardView` — emoji, name, streak count, tap-to-log
- [x] `AddHabitSheet` — name, emoji picker, Build/Break toggle, frequency goal

### Sprint 1 — Demo GIFs/Videos

> 📹 *Video walkthroughs and GIFs will be added here after recording build progress.*

| Feature | Preview |
|---------|---------|
| Creating a habit | *(GIF to be added)* |
| Logging a Build habit | *(GIF to be added)* |
| Viewing a streak | *(GIF to be added)* |

---

### Sprint 2 — Planned Issues (Next Unit)

| Issue | Assignee | Priority |
|-------|----------|---------|
| `StreakEngine` — Break habit streak logic (days since last slip) | Member A | High |
| `StreakEngine` — multi-day gap handling on app launch | Member A | High |
| Unit tests for `StreakEngine` | Member A | High |
| `ProgressRingView` — animated circular arc for Build habits | Member B | High |
| `StreakCounterView` — day counter + "I slipped" confirmation | Member B | High |
| Undo toast (5-second log undo) | Member B | Medium |
| `HabitDetailView` + `HabitDetailViewModel` — stats layout | Member C | High |
| `CalendarHeatMapView` — 90-day grid with color intensity | Member C | High |
| `MilestoneBadgeRow` — horizontal earned badge display | Member C | Medium |

---

## Milestone Summary

### Unit 8 — Group Milestone 2

| Deliverable | Status |
|-------------|--------|
| GitHub Project Board created | ✅ |
| GitHub Milestones created | ✅ |
| GitHub Issues created from user features | ✅ |
| Issues assigned to specific team members | ✅ |
| Sprint 1 issues updated in project board | ✅ |
| Sprint 2 issues created, assigned & added to board | ✅ |
| Completed user stories checked off in README | ✅ |
| Build progress videos/GIFs added to README | ⏳ *(in progress)* |
