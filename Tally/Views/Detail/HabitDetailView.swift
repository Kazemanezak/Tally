import SwiftUI

struct HabitDetailView: View {
    let habit: Habit

    @State private var viewModel: HabitDetailViewModel?

    private var accent: Color {
        Color(hex: habit.accentColor)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let viewModel {
                ScrollView {
                    VStack(spacing: 24) {
                        // Emoji + Name header
                        VStack(spacing: 8) {
                            HabitIconView(icon: habit.emoji, size: 56, color: accent)

                            Text(habit.name)
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 8)

                        // Stats card (dashed border like wireframe)
                        statsCard(viewModel: viewModel)

                        // 90-Day Heat Map
                        CalendarHeatMapView(
                            data: viewModel.heatMapData(),
                            accentColor: accent
                        )
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.04))
                        )

                        // Milestone badges
                        MilestoneBadgeRow(earned: viewModel.earnedMilestones())
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = HabitDetailViewModel(habit: habit)
            }
        }
    }

    // MARK: - Stats Card

    private func statsCard(viewModel: HabitDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Streak:")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.currentStreak) 🔥")
                    .bold()
                    .foregroundStyle(.white)
            }

            Divider().background(Color.white.opacity(0.1))

            HStack {
                Text("Best:")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.bestStreak) days")
                    .bold()
                    .foregroundStyle(.white)
            }

            Divider().background(Color.white.opacity(0.1))

            HStack {
                Text("Total:")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.totalCompletions) logs")
                    .bold()
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accent.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
        )
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(accent.opacity(0.08))
        )
    }
}
