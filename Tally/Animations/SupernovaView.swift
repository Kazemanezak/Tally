import SwiftUI

/// Supernova milestone animation (30-day streak) — expanding ring with confetti particles.
struct SupernovaView: View {
    let color: Color
    var onComplete: (() -> Void)? = nil

    @State private var ringScale: Double = 0.1
    @State private var ringOpacity: Double = 1.0
    @State private var particles: [ConfettiParticle] = []
    @State private var animate = false
    @State private var coreOpacity: Double = 1.0

    private let confettiColors: [Color] = [.yellow, .orange, .pink, .purple, .cyan, .green, .white]

    var body: some View {
        ZStack {
            // Central core flash
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, color, color.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(ringScale)
                .opacity(coreOpacity)

            // Expanding ring
            Circle()
                .stroke(color, lineWidth: 4)
                .frame(width: 200, height: 200)
                .scaleEffect(ringScale * 1.5)
                .opacity(ringOpacity)

            // Confetti particles
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                for particle in particles {
                    let progress = animate ? 1.0 : 0.0
                    let distance = particle.speed * progress * min(size.width, size.height) * 0.45
                    let gravity = progress * progress * 80.0
                    let x = center.x + cos(particle.angle) * distance
                    let y = center.y + sin(particle.angle) * distance + gravity
                    let opacity = max(0, 1.0 - progress * 0.8)
                    let rotation = Angle(degrees: particle.spin * progress * 360)

                    context.opacity = opacity

                    var transform = CGAffineTransform.identity
                    transform = transform.translatedBy(x: x, y: y)
                    transform = transform.rotated(by: rotation.radians)

                    let rect = CGRect(
                        x: -particle.size / 2,
                        y: -particle.size / 2,
                        width: particle.size,
                        height: particle.size * 0.4
                    )

                    context.translateBy(x: x, y: y)
                    context.rotate(by: rotation)
                    context.fill(
                        RoundedRectangle(cornerRadius: 1).path(in: rect),
                        with: .color(particle.color)
                    )
                    context.rotate(by: -rotation)
                    context.translateBy(x: -x, y: -y)
                }
            }
        }
        .onAppear {
            // Generate confetti
            particles = (0..<60).map { _ in
                ConfettiParticle(
                    angle: Double.random(in: 0...(2 * .pi)),
                    speed: Double.random(in: 0.4...1.0),
                    size: CGFloat.random(in: 6...12),
                    spin: Double.random(in: -2...2),
                    color: confettiColors.randomElement()!
                )
            }

            // Core + ring expand
            withAnimation(.easeOut(duration: 0.4)) {
                ringScale = 1.0
            }

            // Ring fades as it expands further
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                ringScale = 2.0
                ringOpacity = 0
            }

            // Core fades
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                coreOpacity = 0
            }

            // Confetti burst
            withAnimation(.easeOut(duration: 2.5)) {
                animate = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete?()
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiParticle {
    let angle: Double
    let speed: Double
    let size: CGFloat
    let spin: Double
    let color: Color
}
