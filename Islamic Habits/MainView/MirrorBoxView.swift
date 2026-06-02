import SwiftUI

struct MirrorBoxView: View {
    let message: MirrorMessage

    private let gold = Color("#D9B883")

    var borderColor: Color {
        switch message.priority {
        case .alert:    return .red.opacity(0.6)
        case .nudge:    return .orange.opacity(0.5)
        case .progress: return gold.opacity(0.6)
        case .levelUp:  return gold.opacity(0.4)
        case .quote:    return Color.white.opacity(0.08)
        }
    }

    var iconColor: Color {
        switch message.priority {
        case .alert:    return .red.opacity(0.8)
        case .nudge:    return .orange.opacity(0.8)
        case .progress: return gold
        case .levelUp:  return gold
        case .quote:    return gold.opacity(0.6)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Icon + deed name
            HStack(spacing: 6) {
                Image(systemName: message.icon)
                    .font(.system(size: 11))
                    .foregroundColor(iconColor)

                Text(message.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }

            // Subtitle
            Text(message.subtitle)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
    }
}
