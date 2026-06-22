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

            VStack(spacing: 0) {

                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(gold.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                Spacer()

                // Header
                VStack(spacing: 8) {
                    Text(newLevel.localizedName(language: selectedLanguage))
                        .font(.system(size: 32, weight: .light))
                        .italic()
                        .foregroundColor(gold)

                    Text(levelUpMessage)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Level journey map
                VStack(spacing: 0) {
                    ForEach(Array(DeedLevel.allCases.enumerated()), id: \.offset) { index, level in
                        let isReached = level.rawValue <= newLevel.rawValue
                        let isCurrent = level.rawValue == newLevel.rawValue

                        HStack(spacing: 16) {
                            // Timeline
                            VStack(spacing: 0) {
                                if index > 0 {
                                    Rectangle()
                                        .fill(isReached ? gold.opacity(0.5) : gold.opacity(0.1))
                                        .frame(width: 1, height: 20)
                                }
                                ZStack {
                                    Circle()
                                        .fill(isCurrent ? gold : (isReached ? gold.opacity(0.4) : Color.clear))
                                        .frame(width: isCurrent ? 14 : 10, height: isCurrent ? 14 : 10)
                                    Circle()
                                        .stroke(isCurrent ? gold : (isReached ? gold.opacity(0.4) : gold.opacity(0.15)), lineWidth: 1)
                                        .frame(width: isCurrent ? 14 : 10, height: isCurrent ? 14 : 10)
                                }
                                if index < DeedLevel.allCases.count - 1 {
                                    Rectangle()
                                        .fill(level.rawValue < newLevel.rawValue ? gold.opacity(0.5) : gold.opacity(0.1))
                                        .frame(width: 1, height: 20)
                                }
                            }
                            .frame(width: 20)

                            // Level info
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(level.arabicName)
                                        .font(.system(size: isCurrent ? 16 : 13,
                                                      weight: isCurrent ? .semibold : .regular))
                                        .foregroundColor(isCurrent ? gold : (isReached ? gold.opacity(0.5) : gold.opacity(0.2)))

                                    Text(level.localizedName(language: selectedLanguage))
                                        .font(.system(size: isCurrent ? 12 : 10))
                                        .foregroundColor(isCurrent ? gold.opacity(0.7) : (isReached ? gold.opacity(0.3) : gold.opacity(0.12)))
                                }

                                Spacer()

                                if isCurrent {
                                    Text(level.streakRange(language: selectedLanguage))
                                        .font(.system(size: 11))
                                        .foregroundColor(gold.opacity(0.5))
                                }
                            }
                            .padding(.vertical, isCurrent ? 12 : 6)
                            .padding(.horizontal, 16)
                            .background(
                                isCurrent ?
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(gold.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(gold.opacity(0.2), lineWidth: 1)
                                    ) : nil
                            )
                        }
                        .padding(.horizontal, 32)
                    }
                }

                Spacer()

                // Hadith
                Text(localizedString("\"The most beloved deeds to Allah are the most consistent, even if small.\"", language: selectedLanguage))
                    .font(.system(size: 12, weight: .light))
                    .italic()
                    .foregroundColor(gold.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // Dismiss
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
                .padding(.bottom, 32)
            }
        }
    }

    var levelUpMessage: String {
        switch newLevel {
        case .muraqabah:
            return selectedLanguage == "ar"
                ? "١٤ يوماً من الحضور. قلبك بدأ يتعلم."
                : selectedLanguage == "th"
                ? "14 วันที่มาแสดงตัว หัวใจของคุณกำลังเรียนรู้"
                : "14 days of showing up. Your heart is learning."
        case .istiqamah:
            return selectedLanguage == "ar"
                ? "٣٥ يوماً من الثبات. العادة تتشكل."
                : selectedLanguage == "th"
                ? "35 วันแห่งความมั่นคง นิสัยกำลังก่อตัว"
                : "35 days of presence. The habit is forming."
        case .aadah:
            return selectedLanguage == "ar"
                ? "٥٥ يوماً. أنت تبني شيئاً حقيقياً."
                : selectedLanguage == "th"
                ? "55 วัน คุณกำลังสร้างสิ่งที่แท้จริง"
                : "55 days. You are building something real."
        case .tabiah:
            return selectedLanguage == "ar"
                ? "٦٦ يوماً. أصبح هذا طبيعتك."
                : selectedLanguage == "th"
                ? "66 วัน นี่กลายเป็นธรรมชาติของคุณแล้ว"
                : "66 days. This has become your nature."
        default:
            return ""
        }
    }
}

#Preview {
    LevelUpView(newLevel: .muraqabah, selectedLanguage: "en", onDismiss: {})
}
