import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let viewModel: HomeViewModel

    @State private var isTapped = false
    @State private var isPulsing = false
    @State private var firePulse = false

    private var accent: Color { Color(hex: habit.accentColor) }

    private var progress: Double {
        let p = viewModel.completionProgress(for: habit)
        guard p.goal > 0 else { return 0 }
        return min(1.0, Double(p.current) / Double(p.goal))
    }

    private var streakCount: Int {
        viewModel.streakCount(for: habit)
    }

    private var streakLabel: String {
        if habit.type == .build {
            return "\(streakCount)"
        } else {
            return "Days Clean: \(streakCount)"
        }
    }

    private var isLoggedToday: Bool {
        habit.type == .build ? viewModel.isGoalMet(for: habit) : true
    }

    var body: some View {
        cardContent
            .onAppear {
                if !isLoggedToday {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
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
                    .foregroundStyle(.primary)

                if habit.type == .build {
                    HStack(spacing: 4) {
                        Text("🔥")
                            .scaleEffect(firePulse ? 1.18 : 1.0)

                        Text("\(streakCount)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .animation(.spring(response: 0.25, dampingFraction: 0.45), value: firePulse)
                } else {
                    Text(streakLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if habit.type == .build {
                let p = viewModel.completionProgress(for: habit)

                Button {
                    logBuildHabit()
                } label: {
                    ProgressRingView(
                        progress: progress,
                        accentColor: accent,
                        current: p.current,
                        goal: p.goal
                    )
                    .frame(width: 50, height: 50)
                    .scaleEffect(isTapped ? 0.92 : 1.0)
                }
                .buttonStyle(.plain)
            } else {
                StreakCounterView(
                    dayCount: streakCount,
                    accentColor: accent,
                    onSlip: {
                        viewModel.recordSlip(for: habit)
                    }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accent.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        .opacity(isLoggedToday ? 1.0 : (isPulsing ? 0.7 : 1.0))
    }

    private func logBuildHabit() {
        let streakBefore = streakCount

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isTapped = true
        }

        viewModel.logCompletion(for: habit)

        let streakAfter = viewModel.streakCount(for: habit)
        if streakAfter > streakBefore {
            firePulse = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                firePulse = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isTapped = false
            }
        }
    }
}
