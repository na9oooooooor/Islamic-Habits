import SwiftUI

struct LevelUpView: View {
    let newLevel: DeedLevel
    let selectedLanguage: String
    let onDismiss: () -> Void

    private let gold = Color(red: 0.85, green: 0.72, blue: 0.52)
    private let bg = Color(red: 0.12, green: 0.09, blue: 0.07)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            IslamicPattern().ignoresSafeArea().opacity(0.4)

            VStack(spacing: 32) {
                Spacer()

                // Orb
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.92, blue: 0.75),
                                    Color(red: 0.82, green: 0.68, blue: 0.42),
                                    Color(red: 0.50, green: 0.38, blue: 0.20),
                                    Color(red: 0.28, green: 0.20, blue: 0.10)
                                ],
                                center: UnitPoint(x: 0.30, y: 0.20),
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    // Level name on the orb
                    Text(newLevel.arabicName)
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(bg.opacity(0.8))
                }

                // Message
                VStack(spacing: 12) {
                    Text(newLevel.localizedName(language: selectedLanguage))
                        .font(.system(size: 28, weight: .light))
                        .italic()
                        .foregroundColor(gold)

                    Text(levelUpMessage)
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)

                    // Hadith
                    Text(localizedString("\"The most beloved deeds to Allah are the most consistent, even if small.\"", language: selectedLanguage))
                        .font(.system(size: 13, weight: .light))
                        .italic()
                        .foregroundColor(gold.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Text(localizedString("postlog.dismiss", language: selectedLanguage))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(gold)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    var levelUpMessage: String {
        switch newLevel {
        case .muraqabah:
            return selectedLanguage == "ar"
                ? "أتممت ١٤ يوماً. قلبك بدأ يتعلم."
                : "14 days of showing up. Your heart is learning."
        case .istiqamah:
            return selectedLanguage == "ar"
                ? "٣٥ يوماً من الحضور. العادة تتشكل."
                : "35 days of presence. The habit is forming."
        case .aadah:
            return selectedLanguage == "ar"
                ? "٥٥ يوماً. أنت تبني شيئاً حقيقياً."
                : "55 days. You are building something real."
        case .tabiah:
            return selectedLanguage == "ar"
                ? "٦٦ يوماً. أصبح هذا طبيعتك."
                : "66 days. This has become your nature."
        default:
            return ""
        }
    }
}

#Preview {
    LevelUpView(newLevel: .muraqabah, selectedLanguage: "en", onDismiss: {})
}
