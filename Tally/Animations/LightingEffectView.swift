import SwiftUI

/// Lightning milestone animation (14-day streak)
/// Full-screen flash with a glowing lightning bolt that pops in and fades out.
struct LightningEffectView: View {
    let color: Color
    var duration: Double = 0.85
    var onComplete: (() -> Void)? = nil

    @State private var flashOpacity: Double = 0
    @State private var boltScale: Double = 0.15
    @State private var boltOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var didComplete = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .opacity(flashOpacity)
                .ignoresSafeArea()

            Image(systemName: "bolt.fill")
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.white, .yellow, color],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(boltScale)
                .opacity(boltOpacity)
                .shadow(color: color.opacity(0.85), radius: glowRadius)
                .shadow(color: .white.opacity(0.45), radius: glowRadius * 0.5)
        }
        .onAppear {
            playAnimation()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func playAnimation() {
        // First flash
        withAnimation(.easeIn(duration: 0.05)) {
            flashOpacity = 0.85
        }

        withAnimation(.easeOut(duration: 0.12).delay(0.05)) {
            flashOpacity = 0
        }

        // Second flash
        withAnimation(.easeIn(duration: 0.05).delay(0.16)) {
            flashOpacity = 0.45
        }

        withAnimation(.easeOut(duration: 0.10).delay(0.21)) {
            flashOpacity = 0
        }

        // Bolt entrance
        withAnimation(.spring(response: 0.32, dampingFraction: 0.58).delay(0.08)) {
            boltScale = 1.0
            boltOpacity = 1.0
            glowRadius = 28
        }

        // Bolt exit
        withAnimation(.easeOut(duration: 0.22).delay(max(0.5, duration - 0.25))) {
            boltOpacity = 0
            boltScale = 1.28
            glowRadius = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            guard !didComplete else { return }
            didComplete = true
            onComplete?()
        }
    }
}
