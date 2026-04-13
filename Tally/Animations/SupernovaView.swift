import SwiftUI

/// Supernova milestone animation (30-day streak)
/// Expanding energy ring with a glowing core and confetti burst.
struct SupernovaView: View {
    let color: Color
    var duration: Double = 2.5
    var onComplete: (() -> Void)? = nil

    @State private var ringScale: Double = 0.15
    @State private var ringOpacity: Double = 1.0
    @State private var coreScale: Double = 0.4
    @State private var coreOpacity: Double = 1.0
    @State private var particles: [ConfettiParticle] = []
    @State private var progress: Double = 0
    @State private var didComplete = false

    private let confettiColors: [Color] = [
        .yellow, .orange, .pink, .purple, .cyan, .green, .white
    ]

    var body: some View {
        ZStack {
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
                .scaleEffect(coreScale)
                .opacity(coreOpacity)

            Circle()
                .stroke(color, lineWidth: 4)
                .frame(width: 200, height: 200)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            TimelineView(.animation) { _ in
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)

                    for particle in particles {
                        let distance = particle.speed * progress * min(size.width, size.height) * 0.48
                        let gravity = progress * progress * 90
                        let x = center.x + cos(particle.angle) * distance
                        let y = center.y + sin(particle.angle) * distance + gravity
                        let opacity = max(0, 1.0 - progress * 0.9)
                        let rotation = Angle(degrees: particle.spin * progress * 360)

                        context.opacity = opacity
                        context.translateBy(x: x, y: y)
                        context.rotate(by: rotation)

                        let rect = CGRect(
                            x: -particle.size / 2,
                            y: -particle.size / 2,
                            width: particle.size,
                            height: particle.size * 0.42
                        )

                        context.fill(
                            RoundedRectangle(cornerRadius: 1.5).path(in: rect),
                            with: .color(particle.color)
                        )

                        context.rotate(by: .degrees(-rotation.degrees))
                        context.translateBy(x: -x, y: -y)
                    }
                }
            }
        }
        .onAppear {
            generateParticles()
            playAnimation()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func generateParticles() {
        particles = (0..<60).map { _ in
            ConfettiParticle(
                angle: Double.random(in: 0...(2 * .pi)),
                speed: Double.random(in: 0.4...1.0),
                size: CGFloat.random(in: 6...12),
                spin: Double.random(in: -2.0...2.0),
                color: confettiColors.randomElement() ?? color
            )
        }
    }

    private func playAnimation() {
        withAnimation(.easeOut(duration: 0.4)) {
            coreScale = 1.0
            ringScale = 1.0
        }

        withAnimation(.easeOut(duration: 0.9).delay(0.25)) {
            ringScale = 2.2
            ringOpacity = 0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
            coreScale = 1.3
            coreOpacity = 0
        }

        withAnimation(.easeOut(duration: duration)) {
            progress = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            guard !didComplete else { return }
            didComplete = true
            onComplete?()
        }
    }
}

private struct ConfettiParticle {
    let angle: Double
    let speed: Double
    let size: CGFloat
    let spin: Double
    let color: Color
}
