import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    @State private var showAddSheet = false
    @State private var showArchivedSection = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if let viewModel {
                VStack(spacing: 0) {
                    header(viewModel: viewModel)

                    if viewModel.habits.isEmpty && viewModel.archivedHabits.isEmpty {
                        emptyState
                    } else {
                        habitList(viewModel: viewModel)
                    }
                }

                if viewModel.showUndoToast {
                    UndoToastView(viewModel: viewModel)
                        .zIndex(10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if viewModel.showMilestoneOverlay {
                    MilestoneOverlay(
                        milestone: viewModel.milestoneToShow,
                        isPresented: Binding(
                            get: { viewModel.showMilestoneOverlay },
                            set: { newValue in
                                if !newValue {
                                    viewModel.dismissMilestoneOverlay()
                                }
                            }
                        )
                    )
                    .zIndex(20)
                    .transition(.opacity)
                }
            }
        }
        .animation(.spring(response: 0.3), value: viewModel?.showUndoToast)
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {
            viewModel?.fetchHabits()
            viewModel?.fetchArchivedHabits()
        }) {
            AddHabitSheet(habitToEdit: nil)
                .presentationDetents([.large])
        }
        .navigationDestination(for: UUID.self) { habitID in
            if let habit = viewModel?.habits.first(where: { $0.id == habitID }) {
                HabitDetailView(habit: habit)
            }
        }
        .navigationBarHidden(true)
    }

    private func header(viewModel: HomeViewModel) -> some View {
        HStack {
            Text("Tally")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.primary)

            Spacer()

            if !viewModel.archivedHabits.isEmpty {
                Button {
                    withAnimation {
                        showArchivedSection.toggle()
                    }
                } label: {
                    Image(systemName: showArchivedSection ? "archivebox.fill" : "archivebox")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            }

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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.archiveHabit(habit)
                    } label: {
                        Label("Archive", systemImage: "archivebox.fill")
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onMove { source, destination in
                viewModel.moveHabit(from: source, to: destination)
            }

            if showArchivedSection && !viewModel.archivedHabits.isEmpty {
                Section("Archived Habits") {
                    ForEach(viewModel.archivedHabits, id: \.id) { habit in
                        HStack(spacing: 12) {
                            Text(habit.emoji)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.name)
                                    .foregroundStyle(.primary)

                                Text("Archived")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                viewModel.unarchiveHabit(habit)
                            } label: {
                                Label("Restore", systemImage: "arrow.uturn.backward.circle.fill")
                            }
                            .tint(.blue)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}
