import SwiftUI

struct MilestoneBadgeRow: View {
    let earned: [MilestoneDefinition]

    private func isEarned(_ milestone: MilestoneDefinition) -> Bool {
        earned.contains { $0.threshold == milestone.threshold }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Milestones")
                .font(.headline)
                .foregroundStyle(.white)

            if MilestoneService.all.isEmpty {
                Text("No milestones available.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.04))
                    )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(MilestoneService.all) { milestone in
                            let earnedState = isEarned(milestone)

                            VStack(spacing: 6) {
                                let isLegend = milestone.animationType == .legendBadge && earnedState

                                Text(milestone.emoji.isEmpty ? "🏆" : milestone.emoji)
                                    .font(.system(size: 28))
                                    .grayscale(earnedState ? 0 : 1)
                                    .opacity(earnedState ? 1 : 0.35)
                                    .symbolEffect(.pulse, isActive: isLegend)

                                Text(milestone.name)
                                    .font(.caption)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(
                                        isLegend
                                        ? AnyShapeStyle(LinearGradient(
                                            colors: [.yellow, .orange, .yellow],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        : AnyShapeStyle(earnedState ? .white : .secondary)
                                    )

                                Text("\(milestone.threshold)d")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 90, height: 95)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        earnedState
                                        ? Color.white.opacity(0.08)
                                        : Color.white.opacity(0.03)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        earnedState && milestone.animationType == .legendBadge
                                        ? Color.yellow.opacity(0.3)
                                        : earnedState
                                        ? Color.white.opacity(0.12)
                                        : Color.clear,
                                        lineWidth: earnedState && milestone.animationType == .legendBadge ? 1.5 : 1
                                    )
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(
                                "\(milestone.name), \(milestone.threshold) day milestone, \(earnedState ? "earned" : "not earned")"
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }
}
