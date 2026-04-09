import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let accentColor: Color
    var lineWidth: CGFloat = 6
    var current: Int = 0
    var goal: Int = 0

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    accentColor.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: accentColor.opacity(animatedProgress >= 1.0 ? 0.6 : 0), radius: 8)

            if animatedProgress >= 1.0 {
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(accentColor)
            } else if goal > 0 {
                Text("\(current)/\(goal)")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(accentColor)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}
