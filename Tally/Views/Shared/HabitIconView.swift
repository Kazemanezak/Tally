import SwiftUI

/// Displays a habit icon — either an SF Symbol (by name) or a custom emoji character.
struct HabitIconView: View {
    let icon: String
    var size: CGFloat = 32
    var color: Color = .white

    /// SF Symbol names are ASCII-only; emoji strings contain non-ASCII Unicode.
    private var isSFSymbol: Bool {
        icon.allSatisfy { $0.isASCII }
    }

    var body: some View {
        if isSFSymbol {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundStyle(color)
        } else {
            Text(icon)
                .font(.system(size: size))
        }
    }
}
