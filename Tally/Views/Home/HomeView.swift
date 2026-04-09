import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    @State private var showAddSheet = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if let viewModel {
                VStack(spacing: 0) {
                    header

                    if viewModel.habits.isEmpty {
                        emptyState
                    } else {
                        habitList(viewModel: viewModel)
                    }
                }

                if viewModel.showUndoToast {
                    UndoToastView(viewModel: viewModel)
                }
            }
        }
        .animation(.spring(response: 0.3), value: viewModel?.showUndoToast)
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            viewModel?.fetchHabits()
        } content: {
            AddHabitSheet()
                .presentationDetents([.large])
        }
        .navigationDestination(for: UUID.self) { habitID in
            if let habit = viewModel?.habits.first(where: { $0.id == habitID }) {
                HabitDetailView(habit: habit)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            Text("Tally")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.primary)

            Spacer()

            Button {
                showAddSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "target")
                .font(.system(size: 64))
                .foregroundStyle(.indigo)

            Text("Start your first streak.")
                .font(.title3)
                .foregroundStyle(.secondary)

            Button {
                showAddSheet = true
            } label: {
                Text("Create a Habit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.indigo)
                    )
            }

            Spacer()
        }
    }

    private func habitList(viewModel: HomeViewModel) -> some View {
        List {
            ForEach(viewModel.habits, id: \.id) { habit in
                NavigationLink(value: habit.id) {
                    HabitCardView(habit: habit, viewModel: viewModel)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onMove { source, destination in
                viewModel.moveHabit(from: source, to: destination)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}
