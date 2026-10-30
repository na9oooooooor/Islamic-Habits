import SwiftUI

struct MirrorBoxView: View {
    let message: MirrorMessage

    private let gold = Color("#D9B883")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 6) {
                Image(systemName: message.icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(gold.opacity(0.7))

                Text(message.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }

            Text(message.subtitle)
                .font(.system(size: 11, weight: .light))
                .foregroundColor(.white.opacity(0.65))
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(gold.opacity(0.25), lineWidth: 1)
                )
        )
    }
}
