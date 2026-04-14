import SwiftUI

struct LegendBadgeView: View {
    var color: Color = .yellow
    var onComplete: (() -> Void)?

    @State private var crownScale: CGFloat = 0.0
    @State private var crownOpacity: Double = 0.0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0.0
    @State private var shimmerAngle: Double = -45
    @State private var glowRadius: CGFloat = 0
    @State private var particles: [LegendParticle] = []

    private let particleCount = 20

    var body: some View {
        ZStack {
            // Expanding glow ring
            Circle()
                .stroke(color.opacity(ringOpacity * 0.4), lineWidth: 3)
                .scaleEffect(ringScale)

            // Soft glow behind crown
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.5), color.opacity(0.0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .scaleEffect(crownScale)
                .blur(radius: glowRadius)

            // Shimmer particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }

            // Crown badge
            Image(systemName: "crown.fill")
                .font(.system(size: 84, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: color.opacity(0.8), radius: glowRadius)
                .scaleEffect(crownScale)
                .opacity(crownOpacity)
                .rotation3DEffect(.degrees(shimmerAngle), axis: (x: 0, y: 1, z: 0))
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Crown entrance: spring scale + fade in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55, blendDuration: 0)) {
            crownScale = 1.0
            crownOpacity = 1.0
        }

        // Glow pulse
        withAnimation(.easeOut(duration: 0.8)) {
            glowRadius = 20
            ringScale = 2.5
            ringOpacity = 1.0
        }

        // Ring fade out
        withAnimation(.easeOut(duration: 1.2).delay(0.6)) {
            ringOpacity = 0.0
        }

        // Shimmer rotation
        withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
            shimmerAngle = 45
        }

        // Settle glow
        withAnimation(.easeInOut(duration: 1.0).delay(1.0)) {
            glowRadius = 8
        }

        // Spawn shimmer particles
        spawnParticles()

        // Completion callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onComplete?()
        }
    }

    private func spawnParticles() {
        particles = (0..<particleCount).map { _ in
            LegendParticle(
                x: 0, y: 0,
                size: CGFloat.random(in: 3...7),
                color: [Color.yellow, .orange, .white].randomElement()!,
                opacity: 0.0
            )
        }

        for i in particles.indices {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 50...120)
            let delay = Double.random(in: 0.2...0.8)

            withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                particles[i].x = cos(angle) * distance
                particles[i].y = sin(angle) * distance
                particles[i].opacity = 1.0
            }

            withAnimation(.easeIn(duration: 0.6).delay(delay + 1.0)) {
                particles[i].opacity = 0.0
            }
        }
    }
}

private struct LegendParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}
