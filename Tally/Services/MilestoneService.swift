import Foundation

enum MilestoneService {
    static let thresholds: [Int] = [3, 7, 14, 30, 100]

    static func reachedMilestone(from previousStreak: Int, to newStreak: Int) -> Int? {
        guard newStreak > previousStreak else { return nil }

        return thresholds.first { threshold in
            previousStreak < threshold && newStreak >= threshold
        }
    }

    static func playHaptic(for milestone: Int) {
        switch milestone {
        case 3:
            HapticManager.success()

        case 7:
            HapticManager.medium()

        case 14:
            HapticManager.heavy()

        case 30:
            HapticManager.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                HapticManager.heavy()
            }

        case 100:
            HapticManager.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                HapticManager.heavy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                HapticManager.doubleTap()
            }

        default:
            HapticManager.success()
        }
    }
}
