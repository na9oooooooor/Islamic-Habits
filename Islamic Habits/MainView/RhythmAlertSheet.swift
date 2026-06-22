import SwiftUI

struct RhythmAlertSheet: View {
    let message: MirrorMessage
    let selectedLanguage: String
    let onDismiss: () -> Void

    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    var isLevelDrop: Bool {
        message.priority == .alert && message.icon == "exclamationmark.circle.fill"
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            IslamicPattern().ignoresSafeArea()

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(gold.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                // Icon
                ZStack {
                    Circle()
                        .fill(isLevelDrop ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                        .frame(width: 72, height: 72)
                    Image(systemName: message.icon)
                        .font(.system(size: 32))
                        .foregroundColor(isLevelDrop ? .red.opacity(0.8) : .orange.opacity(0.8))
                }
                .padding(.top, 32)

                // Title
                Text(message.title)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(gold)
                    .padding(.top, 16)

                // Subtitle
                Text(message.subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                // Encouraging hadith
                Text(localizedString("\"The most beloved deeds to Allah are the most consistent, even if small.\"", language: selectedLanguage))
                    .font(.system(size: 13, weight: .light))
                    .italic()
                    .foregroundColor(gold.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 24)

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Text(localizedString("postlog.dismiss", language: selectedLanguage))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(gold))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}
