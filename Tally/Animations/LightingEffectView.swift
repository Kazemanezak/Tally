import SwiftUI

/// Lightning milestone animation (14-day streak) — screen flash + bolt icon scale-in.
struct LightningEffectView: View {
    let color: Color
    var onComplete: (() -> Void)? = nil

    @State private var flashOpacity: Double = 0
    @State private var boltScale: Double = 0.1
    @State private var boltOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        ZStack {
            // Screen flash
            Rectangle()
                .fill(Color.white)
                .opacity(flashOpacity)
                .ignoresSafeArea()

            // Lightning bolt
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
                .shadow(color: color.opacity(0.8), radius: glowRadius)
                .shadow(color: .white.opacity(0.4), radius: glowRadius * 0.5)
        }
        .onAppear {
            // Flash
            withAnimation(.easeIn(duration: 0.05)) {
                flashOpacity = 0.8
            }
            withAnimation(.easeOut(duration: 0.15).delay(0.05)) {
                flashOpacity = 0
            }

            // Second flash
            withAnimation(.easeIn(duration: 0.05).delay(0.15)) {
                flashOpacity = 0.5
            }
            withAnimation(.easeOut(duration: 0.1).delay(0.2)) {
                flashOpacity = 0
            }

            // Bolt scale-in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                boltScale = 1.0
                boltOpacity = 1.0
                glowRadius = 30
            }

            // Fade out
            withAnimation(.easeOut(duration: 0.2).delay(0.6)) {
                boltOpacity = 0
                boltScale = 1.3
                glowRadius = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onComplete?()
            }
        }
        .allowsHitTesting(false)
    }
}
