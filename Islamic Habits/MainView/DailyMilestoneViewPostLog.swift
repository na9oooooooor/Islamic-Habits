import SwiftUI

struct DailyMilestoneView: View {
    let dailyGoal: Int
    let selectedLanguage: String
    let rhythmPercent: Int  // add this
    let onDismiss: () -> Void

    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    var encouragement: String {
        let keys = [
            "milestone.encourage.1",
            "milestone.encourage.2",
            "milestone.encourage.3",
            "milestone.encourage.4",
            "milestone.encourage.5"
        ]
        return localizedString(keys.randomElement()!, language: selectedLanguage)
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            IslamicPattern()
                .ignoresSafeArea()
                .opacity(0.3)

            VStack(spacing: 0) {

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .stroke(gold.opacity(0.2), lineWidth: 1)
                        .frame(width: 100, height: 100)
                    Circle()
                        .stroke(gold.opacity(0.1), lineWidth: 1)
                        .frame(width: 130, height: 130)
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundColor(gold.opacity(0.8))
                }

                Spacer()

                // Level + goal
                VStack(spacing: 8) {
                    // Level badge
                    Text("\(localizedString("general.level", language: selectedLanguage)) \(dailyGoal)  ·  \(dailyGoal) \(dailyGoal > 1 ? localizedString("general.deeds", language: selectedLanguage) : localizedString("general.deed", language: selectedLanguage)) \(localizedString("general.a_day", language: selectedLanguage))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(gold.opacity(0.7))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(gold.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(gold.opacity(0.2), lineWidth: 0.5)
                                )
                        )

                    Text("\(dailyGoal) \(dailyGoal > 1 ? localizedString("general.deeds", language: selectedLanguage) : localizedString("general.deed", language: selectedLanguage)) \(localizedString("habit.logged_today", language: selectedLanguage))")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Encouragement
                Text(encouragement)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)

                Spacer()

                // Habit progress
                VStack(spacing: 10) {
                    HStack {
                        Text(localizedString("Habit progress", language: selectedLanguage))
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.white.opacity(0.35))
                        Spacer()
                        Text("\(rhythmPercent)%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(gold.opacity(0.7))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(gold.opacity(0.7))
                                .frame(width: geo.size.width * min(Double(rhythmPercent) / 100, 1.0), height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text(localizedString("milestone.keep.logging", language: selectedLanguage))
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.25))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Dismiss
                Button {
                    onDismiss()
                } label: {
                    Text("الحمد لله")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(gold.opacity(0.8))
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(gold.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(gold.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 48)
            }
        }
    }
}
