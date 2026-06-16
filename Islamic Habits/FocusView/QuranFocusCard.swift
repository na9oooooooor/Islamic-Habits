import SwiftUI

struct QuranFocusCard: View {
    let engine: QuranEngine
    let level: DeedLevel
    let streak: Int
    let selectedLanguage: String

    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                heroCard
                statsRow
                trendCard
                progressCard
                if let nudge = engine.nudgeMessage(language: selectedLanguage) {
                    nudgeCard(nudge)
                }
                heatmapPlaceholder

            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Hero
    var heroCard: some View {
        ZStack {
            // glow bloom
            Ellipse()
                .fill(gold.opacity(0.08))
                .frame(width: 140, height: 60)
                .blur(radius: 20)
                .offset(y: -10)

            VStack(spacing: 4) {
                Text("\(engine.quranTodayAyahs)")
                    .font(.system(size: 64, weight: .ultraLight))
                    .foregroundColor(gold)
                    .monospacedDigit()

                Text(localizedString("quran.card.today_ayahs", language: selectedLanguage))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(gold.opacity(0.6))
                    .tracking(1)
                    .textCase(.uppercase)

                if engine.quranTodayAyahs > 0 && engine.quranAveragePerSession > 0 {
                    let diff = engine.quranTodayAyahs - engine.quranAveragePerSession
                    let sign = diff >= 0 ? "+" : ""
                    Text("\(sign)\(diff) \(localizedString("quran.card.vs_avg", language: selectedLanguage))")
                        .font(.system(size: 10))
                        .foregroundColor(diff >= 0 ? gold.opacity(0.55) : .orange.opacity(0.7))
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(gold.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(gold.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Stats Row
    var statsRow: some View {
        HStack(spacing: 10) {
            miniStat(
                value: "\(streak)",
                label: localizedString("quran.card.streak", language: selectedLanguage),
                sub: localizedString("quran.card.days", language: selectedLanguage)
            )
            miniStat(
                value: "\(engine.quranAveragePerSession)",
                label: localizedString("quran.card.avg_session", language: selectedLanguage),
                sub: localizedString("quran.card.ayah_per_session", language: selectedLanguage)
            )
        }
    }

    func miniStat(value: String, label: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(gold.opacity(0.5))
                .tracking(0.4)
            Text(value)
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundColor(gold)
                .monospacedDigit()
            Text(sub)
                .font(.system(size: 10))
                .foregroundColor(gold.opacity(0.4))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(gold.opacity(0.12), lineWidth: 1))
        )
    }

    // MARK: - Trend
    var trendCard: some View {
        let trend = engine.quranVolumeTrend
        let maxVal = max(trend.thisWeek, trend.lastWeek, 1)
        let thisH = CGFloat(trend.thisWeek) / CGFloat(maxVal)
        let lastH = CGFloat(trend.lastWeek) / CGFloat(maxVal)
        let up = trend.thisWeek >= trend.lastWeek

        return VStack(alignment: .leading, spacing: 10) {
            Text(localizedString("quran.card.weekly_volume", language: selectedLanguage))
                .font(.system(size: 10))
                .foregroundColor(gold.opacity(0.5))
                .tracking(0.4)

            HStack(alignment: .bottom, spacing: 10) {
                // Bars
                HStack(alignment: .bottom, spacing: 4) {
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(gold.opacity(0.25))
                            .frame(width: 28, height: max(8, 44 * lastH))
                        Text(localizedString("quran.card.last_week", language: selectedLanguage))
                            .font(.system(size: 9))
                            .foregroundColor(gold.opacity(0.4))
                    }
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(gold)
                            .frame(width: 28, height: max(8, 44 * thisH))
                        Text(localizedString("quran.card.this_week", language: selectedLanguage))
                            .font(.system(size: 9))
                            .foregroundColor(gold.opacity(0.6))
                    }
                }

                Spacer()

                // Numbers
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(up ? "↑" : "↓")
                            .foregroundColor(up ? gold : .orange)
                        Text("\(trend.thisWeek)")
                            .font(.system(size: 20, weight: .ultraLight))
                            .foregroundColor(gold)
                            .monospacedDigit()
                    }
                    Text("\(trend.lastWeek) \(localizedString("quran.card.last_week", language: selectedLanguage))")
                        .font(.system(size: 10))
                        .foregroundColor(gold.opacity(0.4))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(gold.opacity(0.12), lineWidth: 1))
        )
    }

    // MARK: - Progress
    var progressCard: some View {
        let progress = level.progress(streak: streak)
        let nextLevel = DeedLevel(rawValue: level.rawValue + 1)
        let daysLeft = daysToNextLevel()

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localizedString("quran.card.progress", language: selectedLanguage))
                    .font(.system(size: 10))
                    .foregroundColor(gold.opacity(0.5))
                    .tracking(0.4)
                Spacer()
                Text("\(localizedString("quran.card.day", language: selectedLanguage)) \(streak) / \(level.progressRange.upperBound)")
                    .font(.system(size: 10))
                    .foregroundColor(gold.opacity(0.5))
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(gold.opacity(0.12))
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(gold)
                        .frame(width: geo.size.width * progress, height: 3)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 3)

            HStack {
                Text(level.localizedName(language: selectedLanguage))
                    .font(.system(size: 10))
                    .foregroundColor(gold.opacity(0.6))
                Spacer()
                if let next = nextLevel, daysLeft > 0 {
                    Text("\(daysLeft) \(localizedString("quran.card.days_to", language: selectedLanguage)) \(next.localizedName(language: selectedLanguage))")
                        .font(.system(size: 10))
                        .foregroundColor(gold.opacity(0.45))
                } else if level == .tabiah {
                    Text(localizedString("quran.card.mastered", language: selectedLanguage))
                        .font(.system(size: 10))
                        .foregroundColor(gold.opacity(0.6))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(gold.opacity(0.12), lineWidth: 1))
        )
    }
    
    var heatmapPlaceholder: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localizedString("quran.card.activity", language: selectedLanguage))
                .font(.system(size: 10))
                .foregroundColor(gold.opacity(0.5))
                .tracking(0.4)

            // 9 weeks × 7 days grid
            let columns = Array(repeating: GridItem(.fixed(28), spacing: 4), count: 9)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<63, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(gold.opacity(Double.random(in: 0.04...0.25)))
                        .frame(height: 28)
                }
            }

            Text(localizedString("quran.card.activity.coming", language: selectedLanguage))
                .font(.system(size: 10))
                .foregroundColor(gold.opacity(0.3))
                .italic()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(gold.opacity(0.12), lineWidth: 1))
        )
    }

    // MARK: - Nudge
    func nudgeCard(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.stars")
                .font(.system(size: 13))
                .foregroundColor(gold.opacity(0.5))
            Text(message)
                .font(.system(size: 11))
                .foregroundColor(gold.opacity(0.65))
                .italic()
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(gold.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(gold.opacity(0.18), lineWidth: 1))
        )
    }

    // MARK: - Helpers
    func daysToNextLevel() -> Int {
        guard level != .tabiah else { return 0 }
        return level.progressRange.upperBound - streak
    }
}
