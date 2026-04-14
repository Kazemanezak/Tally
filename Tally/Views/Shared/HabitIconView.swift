import SwiftUI
import UIKit

/// Displays a habit icon — either an SF Symbol (by name) or a custom emoji character.
struct HabitIconView: View {
    let icon: String
    var size: CGFloat = 32
    var color: Color = .white

    private var isSFSymbol: Bool {
        UIImage(systemName: icon) != nil
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
