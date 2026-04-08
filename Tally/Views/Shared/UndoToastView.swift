import SwiftUI

struct UndoToastView: View {
    let viewModel: HomeViewModel

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)

                Text("Logged!")
                    .foregroundStyle(.white)

                Spacer()

                Button("Undo") {
                    viewModel.undoLastLog()
                }
                .bold()
                .foregroundStyle(.yellow)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
