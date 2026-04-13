import SwiftUI

/// Fire milestone animation (7-day streak)
/// A layered flame that flickers, sways, and fades out.
struct FlameAnimationView: View {
    let color: Color
    var duration: Double = 1.5
    var onComplete: (() -> Void)? = nil

    @State private var opacity: Double = 1.0
    @State private var didComplete = false

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let centerX = size.width / 2
                let baseY = size.height * 0.72

                for i in 0..<5 {
                    let layerIndex = Double(i)
                    let flicker = sin(time * (3.2 + layerIndex) + layerIndex * 0.9) * 0.14
                    let sway = sin(time * 2.4 + layerIndex) * 8.0

                    let scale = max(0.55, 1.0 - layerIndex * 0.14 + flicker)
                    let flameWidth = size.width * 0.28 * scale
                    let flameHeight = size.height * (0.48 - layerIndex * 0.04) * scale
                    let tipY = baseY - flameHeight

                    let layerOpacity = max(0, (1.0 - layerIndex * 0.18) * opacity)

                    var path = Path()
                    path.move(to: CGPoint(x: centerX + sway, y: tipY))

                    path.addQuadCurve(
                        to: CGPoint(x: centerX - flameWidth / 2, y: baseY),
                        control: CGPoint(
                            x: centerX - flameWidth * 0.65 + sway,
                            y: tipY + flameHeight * 0.42
                        )
                    )

                    path.addQuadCurve(
                        to: CGPoint(x: centerX + flameWidth / 2, y: baseY),
                        control: CGPoint(
                            x: centerX,
                            y: baseY + flameHeight * 0.10
                        )
                    )

                    path.addQuadCurve(
                        to: CGPoint(x: centerX + sway, y: tipY),
                        control: CGPoint(
                            x: centerX + flameWidth * 0.65 + sway,
                            y: tipY + flameHeight * 0.42
                        )
                    )

                    let flameColor: Color
                    switch i {
                    case 0, 1:
                        flameColor = .yellow
                    case 2, 3:
                        flameColor = .orange
                    default:
                        flameColor = color
                    }

                    context.opacity = layerOpacity
                    context.addFilter(.blur(radius: i == 0 ? 1.5 : 0.5))
                    context.fill(path, with: .color(flameColor))
                }
            }
        }
        .onAppear {
            let fadeStart = max(0.8, duration - 0.35)

            DispatchQueue.main.asyncAfter(deadline: .now() + fadeStart) {
                withAnimation(.easeOut(duration: duration - fadeStart)) {
                    opacity = 0
                }
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
}
