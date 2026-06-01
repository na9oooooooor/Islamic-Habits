//
//  FocusDeedProgressCard.swift
//  Islamic Habits
//
//  Created by NASER ALALI on 01/06/2026.
//


import SwiftUI

struct FocusDeedProgressCard: View {
    let worship: WorshipType
    let streak: Int
    let level: DeedLevel
    let status: StreakStatus
    let progress: Double
    let selectedLanguage: String

    private let gold = Color("#D9B883")
    private let background = Color("#1F1712")

    var displayName: String {
        selectedLanguage == "ar"
            ? worship.arabicName
            : localizedString(worship.nameKey, language: selectedLanguage)
    }

    var levelName: String {
        switch selectedLanguage {
        case "ar": return level.arabicName
        case "th": return level.thaiName
        default: return level.englishName
        }
    }

    var statusColor: Color {
        switch status {
        case .healthy: return gold
        case .warning: return .orange
        case .broken: return .red
        }
    }

    var statusText: String {
        switch status {
        case .healthy:
            return "\(streak) day streak"
        case .warning(let remaining):
            return "\(remaining) grace day\(remaining == 1 ? "" : "s") left"
        case .broken:
            return "Streak broken — keep going"
        }
    }

    var body: some View {
        VStack(spacing: 16) {

            // Top row — icon, name, level
            HStack(spacing: 14) {
                Image(systemName: worship.icon)
                    .font(.system(size: 28))
                    .foregroundColor(gold)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(gold.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(levelName)
                        .font(.system(size: 12))
                        .foregroundColor(gold.opacity(0.7))
                }

                Spacer()

                // Level badge
                Text("Lvl \(level.rawValue)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(background)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(gold)
                    )
            }

            // Progress bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(statusColor)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.easeInOut(duration: 0.4), value: progress)
                    }
                }
                .frame(height: 6)

                // Status text
                HStack {
                    Text(statusText)
                        .font(.system(size: 11))
                        .foregroundColor(statusColor)

                    Spacer()

                    Text(level.streakRange)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(statusColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}