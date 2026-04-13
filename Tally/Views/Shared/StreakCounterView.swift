import SwiftUI

struct StreakCounterView: View {
    let dayCount: Int
    let accentColor: Color
    let onSlip: () -> Void

    @State private var showSlipConfirmation = false

    var body: some View {
        VStack(spacing: 4) {
            Text("\(dayCount)")
                .font(.title2)
                .bold()
                .foregroundStyle(accentColor)

            Text(dayCount == 1 ? "day" : "days")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button {
                showSlipConfirmation = true
            } label: {
                Text("I slipped")
                    .font(.caption2)
                    .foregroundStyle(.red.opacity(0.85))
                    .padding(.top, 2)
            }
            .buttonStyle(.plain)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(dayCount) day streak")
        .confirmationDialog(
            "Reset your streak?",
            isPresented: $showSlipConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Streak", role: .destructive) {
                onSlip()
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will record a slip and reset your streak to 0.")
        }
    }
}
