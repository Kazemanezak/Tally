# Product Requirements Document — Tally

## Overview

Tally is an iOS habit tracker designed to make logging habits feel entertaining and addictive. Users track both positive habits they want to build (e.g., gym visits, reading) and negative habits they want to break (e.g., alcohol, smoking). The app uses streaks, milestone celebrations, and satisfying animations to keep users engaged and motivated.

This is an MVP intended for a class demo. The scope prioritizes a polished core loop — add habits, log daily, see streaks, enjoy feedback — over breadth of features.

---

## Target Audience

General public, ages 16+. Anyone who wants a lightweight, visually rewarding way to stay accountable to their habits without the complexity of a full life-management app.

---

## Core Concepts

### Habit Types

| Type | Description | Example | Tracking Model |
|------|-------------|---------|----------------|
| **Build** | A positive habit the user wants to do regularly | "Go to the gym 2x/week" | Count completions toward a frequency goal |
| **Break** | A negative habit the user wants to avoid | "Days without alcohol" | Count consecutive days of abstinence |

### Streaks

A streak is a consecutive run of meeting a habit's goal. Streaks are the emotional backbone of the app — breaking a streak should feel like a real loss, and extending one should feel like a win.

- **Build habits**: Streak increments each period (day/week) where the user meets their frequency goal.
- **Break habits**: Streak increments each day the user does *not* log the habit.

### Milestones

Pre-defined streak thresholds that trigger special celebration animations:

| Milestone | Streak Length | Animation |
|-----------|--------------|-----------|
| Spark | 3 days/periods | Small particle burst |
| Fire | 7 | Flame animation with haptic feedback |
| Lightning | 14 | Lightning bolt with screen flash |
| Supernova | 30 | Full-screen explosion with confetti |
| Legend | 100 | Custom animated badge permanently displayed |

---

## Feature Requirements

### F1 — Habit Management

- **F1.1** Users can create a new habit with: name, emoji icon, type (Build or Break), and frequency goal (daily, X times per week).
- **F1.2** Users can edit or archive a habit. Archived habits preserve their history but stop appearing in the daily view.
- **F1.3** Users can reorder habits via drag-and-drop on the main screen.
- **F1.4** A maximum of 10 active habits keeps the interface focused.

### F2 — Daily Logging

- **F2.1** The home screen shows today's habits as a scrollable list of cards.
- **F2.2** Tapping a Build habit card logs one completion for today. A circular progress ring fills to show progress toward the period goal.
- **F2.3** Break habit cards show the current streak counter prominently. A "Reset" button (with confirmation) resets the streak to zero.
- **F2.4** Logging a completion triggers a short, satisfying animation on the card (scale bounce + color shift).
- **F2.5** Users can undo a log within 5 seconds via an inline toast.

### F3 — Streaks & Milestones

- **F3.1** Each habit card displays the current streak count.
- **F3.2** When a user's action causes a streak to hit a milestone threshold, a celebration animation plays immediately (see Milestones table above).
- **F3.3** Milestone animations are skippable by tapping.
- **F3.4** A "best streak" record is stored per habit and displayed in the detail view.

### F4 — Habit Detail View

- **F4.1** Tapping a habit card opens a detail screen with: current streak, best streak, total completions, and a calendar heat map showing activity over the past 90 days.
- **F4.2** The heat map uses color intensity to show completion density per day.
- **F4.3** Earned milestone badges are displayed in a row beneath the stats.

### F5 — Visual Design & Animation

- **F5.1** The app uses a dark theme by default with vibrant accent colors per habit (user-selected or auto-assigned).
- **F5.2** All animations use SwiftUI's built-in animation system for smooth 60fps performance.
- **F5.3** Haptic feedback accompanies logging and milestone events (using UIImpactFeedbackGenerator).
- **F5.4** A subtle idle animation (gentle glow or pulse) on habits that haven't been logged today draws attention without being annoying.

### F6 — Persistence

- **F6.1** All data is stored locally on-device using SwiftData.
- **F6.2** No user accounts or cloud sync for MVP.

---

## Out of Scope (MVP)

These are intentionally deferred to keep the demo focused:

- Push notifications / reminders
- Social features (sharing, leaderboards)
- Widgets
- Cloud sync / accounts
- Apple Watch support
- Detailed analytics beyond the heat map
- Theming / light mode toggle

---

## User Flows

### Flow 1 — First Launch
1. App opens to an empty home screen with a friendly onboarding message: "Start your first streak."
2. User taps the "+" button → habit creation sheet slides up.
3. User fills in name, picks an emoji, selects Build or Break, sets frequency → taps "Create."
4. Habit card appears on the home screen with streak at 0.

### Flow 2 — Daily Check-In (Build Habit)
1. User opens app → sees today's habit cards.
2. User taps the "Gym" card → completion count increments (1/2 this week), progress ring animates.
3. User taps again later → count reaches 2/2, streak increments, card plays a celebration micro-animation.
4. If streak hits a milestone → full celebration animation plays.

### Flow 3 — Daily Check-In (Break Habit)
1. User opens app → "Days without alcohol" card shows streak at 13.
2. User does nothing → at midnight the streak auto-increments to 14 (Lightning milestone!).
3. If the user slips, they tap "I slipped" → confirmation dialog → streak resets to 0 with a brief "shake" animation.

---

## Success Metrics (for Demo)

- A user can create, log, and view streaks for at least 3 habits in under 2 minutes.
- Milestone animations are visually impressive and run without frame drops.
- The app feels "one more tap" addictive — logging should be faster than opening the app took.
