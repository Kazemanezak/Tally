import SwiftUI
import SwiftData

struct AddHabitSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "dumbbell.fill"
    @State private var habitType: HabitType = .build
    @State private var frequencyPeriod: Period = .daily
    @State private var frequencyGoal = 1
    @State private var accentColor = "#4F46E5"
    @State private var customEmoji = ""
    @State private var showEmojiInput = false
    @FocusState private var emojiFieldFocused: Bool

    private let iconOptions = [
        "dumbbell.fill", "book.fill", "nosign", "figure.mind.and.body",
        "drop.fill", "figure.run", "guitars.fill", "moon.zzz.fill",
        "leaf.fill", "pencil.and.outline", "heart.fill", "pill.fill",
    ]

    private let colorOptions: [(name: String, hex: String)] = [
        ("Indigo", "#4F46E5"),
        ("Blue", "#3B82F6"),
        ("Green", "#22C55E"),
        ("Orange", "#F97316"),
        ("Pink", "#EC4899"),
        ("Red", "#EF4444"),
    ]

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        nameSection
                        iconSection
                        typeSection
                        frequencySection
                        goalSection
                        colorSection
                    }
                    .padding()
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createHabit() }
                        .bold()
                        .disabled(!canCreate)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("e.g. Go to the Gym", text: $name)
                .textFieldStyle(.plain)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                )
                .foregroundStyle(.white)
        }
    }

    private var isCustomEmojiSelected: Bool {
        !customEmoji.isEmpty && selectedIcon == customEmoji
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Icon")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // SF Symbol options
                    ForEach(iconOptions, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundStyle(selectedIcon == icon ? Color(hex: accentColor) : .secondary)
                            .frame(width: 48, height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedIcon == icon ? Color.white.opacity(0.15) : Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedIcon == icon ? Color(hex: accentColor) : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedIcon = icon
                                showEmojiInput = false
                            }
                    }

                    // Custom emoji button
                    ZStack {
                        if isCustomEmojiSelected {
                            Text(customEmoji)
                                .font(.system(size: 28))
                        } else {
                            Image(systemName: "face.smiling.inverse")
                                .font(.system(size: 22))
                                .foregroundStyle(.secondary)
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color(hex: accentColor))
                                        .offset(x: 4, y: 4)
                                }
                        }
                    }
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isCustomEmojiSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isCustomEmojiSelected ? Color(hex: accentColor) : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        showEmojiInput = true
                        emojiFieldFocused = true
                    }
                }
            }

            // Emoji text input field
            if showEmojiInput {
                HStack(spacing: 12) {
                    TextField("Type an emoji", text: $customEmoji)
                        .textFieldStyle(.plain)
                        .focused($emojiFieldFocused)
                        .padding()
                        .frame(width: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .foregroundStyle(.white)
                        .onChange(of: customEmoji) { _, newValue in
                            // Keep only the first emoji character
                            if let first = newValue.first {
                                customEmoji = String(first)
                                selectedIcon = customEmoji
                            }
                        }

                    Text("Switch to emoji keyboard")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showEmojiInput)
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Type", selection: $habitType) {
                Text("Build").tag(HabitType.build)
                Text("Break").tag(HabitType.break)
            }
            .pickerStyle(.segmented)
        }
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Frequency")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Frequency", selection: $frequencyPeriod) {
                Text("Daily").tag(Period.daily)
                Text("Weekly").tag(Period.weekly)
            }
            .pickerStyle(.segmented)
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if habitType == .build {
                Text("Goal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    TextField("1", value: $frequencyGoal, format: .number)
                        .textFieldStyle(.plain)
                        .keyboardType(.numberPad)
                        .padding()
                        .frame(width: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .foregroundStyle(.white)

                    Text("times per \(frequencyPeriod == .daily ? "day" : "week")")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(colorOptions, id: \.hex) { option in
                    Circle()
                        .fill(Color(hex: option.hex))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: accentColor == option.hex ? 3 : 0)
                        )
                        .onTapGesture {
                            accentColor = option.hex
                        }
                }
            }
        }
    }

    // MARK: - Actions

    private func createHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // Determine next sort order
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder, order: .reverse)])
        let existingHabits = (try? modelContext.fetch(descriptor)) ?? []
        let nextOrder = (existingHabits.first?.sortOrder ?? -1) + 1

        let goal = habitType == .build ? max(1, frequencyGoal) : 1

        let habit = Habit(
            name: trimmedName,
            emoji: selectedIcon,
            type: habitType,
            frequencyGoal: goal,
            frequencyPeriod: habitType == .build ? frequencyPeriod : .daily,
            accentColor: accentColor,
            sortOrder: nextOrder
        )

        modelContext.insert(habit)
        try? modelContext.save()

        HapticManager.medium()
        dismiss()
    }
}
