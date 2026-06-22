import SwiftUI

struct RhythmAlertSheet: View {
    let state: GlobalRhythmState
    let isLevelDrop: Bool
    let selectedLanguage: String
    let onDismiss: () -> Void

    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    var currentLevel: DeedLevel {
        DeedLevel(rawValue: state.currentLevel) ?? .niyyah
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            IslamicPattern().ignoresSafeArea().opacity(0.4)

            VStack(spacing: 0) {

                RoundedRectangle(cornerRadius: 2)
                    .fill(gold.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                Spacer()

                // Header
                VStack(spacing: 8) {
                    Image(systemName: isLevelDrop ? "exclamationmark.circle" : "exclamationmark.triangle")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(isLevelDrop ? .red.opacity(0.7) : .orange.opacity(0.7))

                    Text(isLevelDrop
                        ? localizedString("mirror.streak.broken", language: selectedLanguage)
                        : localizedString("mirror.grace.last", language: selectedLanguage))
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Level journey map — same pattern as LevelUpView
                VStack(spacing: 0) {
                    ForEach(Array(DeedLevel.allCases.enumerated()), id: \.offset) { index, level in
                        let isReached = level.rawValue <= currentLevel.rawValue
                        let isCurrent = level.rawValue == currentLevel.rawValue

                        HStack(spacing: 16) {
                            VStack(spacing: 0) {
                                if index > 0 {
                                    Rectangle()
                                        .fill(isReached ? gold.opacity(0.5) : gold.opacity(0.1))
                                        .frame(width: 1, height: 20)
                                }
                                ZStack {
                                    Circle()
                                        .fill(isCurrent ? (isLevelDrop ? Color.red.opacity(0.6) : Color.orange.opacity(0.6)) : (isReached ? gold.opacity(0.4) : Color.clear))
                                        .frame(width: isCurrent ? 14 : 10, height: isCurrent ? 14 : 10)
                                    Circle()
                                        .stroke(isCurrent ? (isLevelDrop ? Color.red.opacity(0.8) : Color.orange.opacity(0.8)) : (isReached ? gold.opacity(0.4) : gold.opacity(0.15)), lineWidth: 1)
                                        .frame(width: isCurrent ? 14 : 10, height: isCurrent ? 14 : 10)
                                }
                                if index < DeedLevel.allCases.count - 1 {
                                    Rectangle()
                                        .fill(level.rawValue < currentLevel.rawValue ? gold.opacity(0.5) : gold.opacity(0.1))
                                        .frame(width: 1, height: 20)
                                }
                            }
                            .frame(width: 20)

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(level.arabicName)
                                        .font(.system(size: isCurrent ? 16 : 13,
                                                      weight: isCurrent ? .semibold : .regular))
                                        .foregroundColor(isCurrent ? (isLevelDrop ? .red.opacity(0.8) : .orange.opacity(0.8)) : (isReached ? gold.opacity(0.5) : gold.opacity(0.2)))

                                    Text(level.localizedName(language: selectedLanguage))
                                        .font(.system(size: isCurrent ? 12 : 10))
                                        .foregroundColor(isCurrent ? (isLevelDrop ? .red.opacity(0.5) : .orange.opacity(0.5)) : (isReached ? gold.opacity(0.3) : gold.opacity(0.12)))
                                }

                                Spacer()

                                if isCurrent {
                                    Text(level.streakRange(language: selectedLanguage))
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                            .padding(.vertical, isCurrent ? 12 : 6)
                            .padding(.horizontal, 16)
                            .background(
                                isCurrent ?
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isLevelDrop ? Color.red.opacity(0.06) : Color.orange.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isLevelDrop ? Color.red.opacity(0.2) : Color.orange.opacity(0.2), lineWidth: 1)
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
}
