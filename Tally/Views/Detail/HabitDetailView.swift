import SwiftUI

struct HabitDetailView: View {
    let habit: Habit

    @State private var viewModel: HabitDetailViewModel?
    @State private var isShowingEditSheet = false

    private var accent: Color {
        Color(hex: habit.accentColor)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let viewModel {
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        statsCard(viewModel: viewModel)

                        heatMapSection(viewModel: viewModel)

                        MilestoneBadgeRow(earned: viewModel.earnedMilestones())

                        recentActivitySection(viewModel: viewModel)
                    }
                    .padding()
                }
            } else {
                ProgressView("Loading habit details...")
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            AddHabitSheet(habitToEdit: habit)
        }
        .task {
            if viewModel == nil {
                viewModel = HabitDetailViewModel(habit: habit)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HabitIconView(icon: habit.emoji, size: 56, color: accent)

            Text(habit.name)
                .font(.title)
                .bold()
                .foregroundStyle(.white)

            Text(habit.type == .build ? "Build Habit" : "Break Habit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private func statsCard(viewModel: HabitDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.headline)
                .foregroundStyle(.white)

            HStack {
                Text("Current Streak")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.currentStreak) days")
                    .bold()
                    .foregroundStyle(.white)
            }

            Divider().background(Color.white.opacity(0.1))

            HStack {
                Text("Best Streak")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.bestStreak) days")
                    .bold()
                    .foregroundStyle(.white)
            }

            Divider().background(Color.white.opacity(0.1))

            HStack {
                Text(habit.type == .build ? "Total Completions" : "Total Clean Days")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.totalCompletions)")
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

    private func heatMapSection(viewModel: HabitDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 90 Days")
                .font(.headline)
                .foregroundStyle(.white)

            CalendarHeatMapView(
                data: viewModel.heatMapData(),
                accentColor: accent
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func recentActivitySection(viewModel: HabitDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundStyle(.white)

            if viewModel.recentLogs.isEmpty {
                Text("No activity recorded yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentLogs, id: \.id) { log in
                    HStack {
                        Text(log.date, style: .date)
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Spacer()

                        if habit.type == .build {
                            Text("\(log.completionCount)x")
                                .bold()
                                .foregroundStyle(.white)
                        } else {
                            Text(log.didSlip ? "Slip" : "Clean")
                                .bold()
                                .foregroundStyle(log.didSlip ? .red : .green)
                        }
                    }

                    if log.id != viewModel.recentLogs.last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
        )
    }
}
