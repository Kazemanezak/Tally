import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let viewModel: HomeViewModel

    @State private var isTapped = false
    @State private var isPulsing = false

    private var accent: Color {
        Color(hex: habit.accentColor)
    }

    private var progress: Double {
        let p = viewModel.completionProgress(for: habit)
        guard p.goal > 0 else { return 0 }
        return min(1.0, Double(p.current) / Double(p.goal))
    }

    private var streakLabel: String {
        if habit.type == .build {
            let streak = viewModel.streakCount(for: habit)
            return "\(streak)🔥"
        } else {
            let days = viewModel.streakCount(for: habit)
            return "Days Clean: \(days)"
        }
    }

    private var isLoggedToday: Bool {
        habit.type == .build ? viewModel.isGoalMet(for: habit) : true
    }

    var body: some View {
        Group {
            if habit.type == .build {
                cardContent
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            isTapped = true
                        }
                        viewModel.logCompletion(for: habit)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                isTapped = false
                            }
                        }
                    }
            } else {
                cardContent
            }
        }
        .onAppear {
            if !isLoggedToday {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
        }
        .onChange(of: isLoggedToday) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.3)) {
                    isPulsing = false
                }
            }
        }
    }

    private var cardContent: some View {
        HStack(spacing: 16) {
            HabitIconView(icon: habit.emoji, size: 32, color: accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(streakLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if habit.type == .build {
                let p = viewModel.completionProgress(for: habit)
                ProgressRingView(progress: progress, accentColor: accent, current: p.current, goal: p.goal)
                    .frame(width: 50, height: 50)
            } else {
                StreakCounterView(
                    dayCount: viewModel.streakCount(for: habit),
                    accentColor: accent,
                    onSlip: { viewModel.recordSlip(for: habit) }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(accent.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accent.opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .opacity(isLoggedToday ? 1.0 : (isPulsing ? 0.7 : 1.0))
    }
}
