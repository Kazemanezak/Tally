import SwiftUI

/// Fire milestone animation (7-day streak) — rising flame with gradient layers.
struct FlameAnimationView: View {
    let color: Color
    var onComplete: (() -> Void)? = nil

    @State private var phase: Double = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate + phase
                let centerX = size.width / 2
                let baseY = size.height * 0.7

                // Draw multiple flame layers
                for i in 0..<5 {
                    let layerIndex = Double(i)
                    let flicker = sin(time * (3.0 + layerIndex) + layerIndex * 0.8) * 0.15
                    let scale = 1.0 - layerIndex * 0.15 + flicker

                    let flameWidth = size.width * 0.3 * scale
                    let flameHeight = size.height * 0.5 * scale

                    let layerOpacity = (1.0 - layerIndex * 0.18) * opacity

                    // Flame shape using an ellipse narrowing to a point
                    var path = Path()
                    let tipY = baseY - flameHeight
                    let sway = sin(time * 2.5 + layerIndex) * 8.0

                    path.move(to: CGPoint(x: centerX + sway, y: tipY))
                    path.addQuadCurve(
                        to: CGPoint(x: centerX - flameWidth / 2, y: baseY),
                        control: CGPoint(x: centerX - flameWidth * 0.6 + sway, y: tipY + flameHeight * 0.4)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: centerX + flameWidth / 2, y: baseY),
                        control: CGPoint(x: centerX, y: baseY + flameHeight * 0.1)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: centerX + sway, y: tipY),
                        control: CGPoint(x: centerX + flameWidth * 0.6 + sway, y: tipY + flameHeight * 0.4)
                    )

                    let flameColor: Color = i < 2 ? .yellow : (i < 4 ? .orange : color)
                    context.opacity = layerOpacity
                    context.fill(path, with: .color(flameColor))
                }
            }
        }
        .onAppear {
            // Fade out after 1.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete?()
            }
        }
        .allowsHitTesting(false)
    }
}
