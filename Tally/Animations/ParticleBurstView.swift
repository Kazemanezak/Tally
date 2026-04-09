import SwiftUI

/// Spark milestone animation (3-day streak) — burst of particles expanding outward from center.
struct ParticleBurstView: View {
    let color: Color
    var particleCount: Int = 30
    var onComplete: (() -> Void)? = nil

    @State private var particles: [Particle] = []
    @State private var animate = false

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for particle in particles {
                let progress = animate ? 1.0 : 0.0
                let distance = particle.speed * progress * min(size.width, size.height) / 2
                let x = center.x + cos(particle.angle) * distance
                let y = center.y + sin(particle.angle) * distance
                let opacity = max(0, 1.0 - progress)
                let scale = particle.size * (1.0 + progress * 0.5)

                context.opacity = opacity
                let rect = CGRect(
                    x: x - scale / 2,
                    y: y - scale / 2,
                    width: scale,
                    height: scale
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(particle.color)
                )
            }
        }
        .onAppear {
            particles = (0..<particleCount).map { _ in
                Particle(
                    angle: Double.random(in: 0...(2 * .pi)),
                    speed: Double.random(in: 0.5...1.0),
                    size: CGFloat.random(in: 4...10),
                    color: [color, color.opacity(0.7), .white, .yellow].randomElement()!
                )
            }

            withAnimation(.easeOut(duration: 1.0)) {
                animate = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete?()
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Particle {
    let angle: Double
    let speed: Double
    let size: CGFloat
    let color: Color
}
