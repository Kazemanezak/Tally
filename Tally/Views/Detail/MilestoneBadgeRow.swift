import SwiftUI

struct MilestoneBadgeRow: View {
    let earned: [MilestoneDefinition]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Milestones")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(MilestoneDefinition.all) { milestone in
                        let isEarned = earned.contains { $0.threshold == milestone.threshold }

                        VStack(spacing: 4) {
                            Text(milestone.emoji)
                                .font(.system(size: 28))
                                .grayscale(isEarned ? 0 : 1)
                                .opacity(isEarned ? 1 : 0.3)

                            Text(milestone.name)
                                .font(.caption2)
                                .foregroundStyle(isEarned ? .white : .secondary)

                            Text("\(milestone.threshold)d")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isEarned ? Color.white.opacity(0.08) : Color.clear)
                        )
                    }
                }
            }
        }
    }
}
