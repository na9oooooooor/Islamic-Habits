import SwiftUI

struct RhythmToast: View {
    let message: MirrorMessage

    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: message.icon)
                .font(.system(size: 16))
                .foregroundColor(gold)

            VStack(alignment: .leading, spacing: 2) {
                Text(message.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(gold)
                Text(message.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(gold.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 12)
        )
        .padding(.horizontal, 24)
    }
}
