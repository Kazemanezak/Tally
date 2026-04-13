import SwiftUI

/// Spark milestone animation (3-day streak)
/// A burst of particles that expands outward from the center.
struct ParticleBurstView: View {
    let color: Color
    var particleCount: Int = 30
    var duration: Double = 1.0
    var onComplete: (() -> Void)? = nil

    @State private var particles: [Particle] = []
    @State private var progress: Double = 0
    @State private var didComplete = false

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                for particle in particles {
                    let distance = particle.speed * progress * min(size.width, size.height) * 0.45
                    let x = center.x + cos(particle.angle) * distance
                    let y = center.y + sin(particle.angle) * distance

                    let opacity = max(0, 1.0 - (progress * 1.15))
                    let scale = particle.size * (1.0 + progress * 0.8)

                    context.opacity = opacity

                    let rect = CGRect(
                        x: x - scale / 2,
                        y: y - scale / 2,
                        width: scale,
                        height: scale
                    )

                    if particle.isSquare {
                        context.fill(
                            Path(roundedRect: rect, cornerRadius: scale * 0.25),
                            with: .color(particle.color)
                        )
                    } else {
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(particle.color)
                        )
                    }
                }
            }
        }
        .onAppear {
            generateParticles()

            withAnimation(.easeOut(duration: duration)) {
                progress = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                guard !didComplete else { return }
                didComplete = true
                onComplete?()
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            Particle(
                angle: Double.random(in: 0...(2 * .pi)),
                speed: Double.random(in: 0.45...1.0),
                size: CGFloat.random(in: 4...10),
                color: [color, color.opacity(0.75), .white, .yellow].randomElement() ?? color,
                isSquare: Bool.random()
            )
        }
    }
}

private struct Particle {
    let angle: Double
    let speed: Double
    let size: CGFloat
    let color: Color
    let isSquare: Bool
}
