import SwiftUI

struct HabitDetailView: View {
    let habit: Habit

    var body: some View {
        VStack(spacing: 16) {
            Text(habit.emoji)
                .font(.system(size: 64))

            Text(habit.name)
                .font(.title)
                .bold()
                .foregroundStyle(.white)

            Text("Detail view coming soon")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
}
