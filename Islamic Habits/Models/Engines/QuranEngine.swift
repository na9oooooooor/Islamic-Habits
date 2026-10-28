import Foundation

struct QuranEngine {
    let logs: [QuranLog]

    var quranStreak: Int {
        let calendar = Calendar.current

        var day = startOfTrackingDay
        var streak = 0

        while true {
            let end = calendar.date(
                byAdding: .day,
                value: 1,
                to: day
            )!

            let hasLog = logs.contains {
                $0.loggedAt >= day &&
                $0.loggedAt < end
            }

            guard hasLog else {
                break
            }

            streak += 1

            day = calendar.date(
                byAdding: .day,
                value: -1,
                to: day
            )!
        }

        return streak
    }

    var quranVolumeTrend: (
        thisWeek: Int,
        lastWeek: Int
    ) {
        let calendar = Calendar.current

        let startThisWeek = calendar.date(
            byAdding: .day,
            value: -6,
            to: startOfTrackingDay
        )!

        let startLastWeek = calendar.date(
            byAdding: .day,
            value: -7,
            to: startThisWeek
        )!

        let thisWeek = logs
            .filter {
                $0.loggedAt >= startThisWeek &&
                $0.loggedAt < startOfTrackingTomorrow
            }
            .reduce(0) {
                $0 + $1.ayahsRead
            }

        let lastWeek = logs
            .filter {
                $0.loggedAt >= startLastWeek &&
                $0.loggedAt < startThisWeek
            }
            .reduce(0) {
                $0 + $1.ayahsRead
            }

        return (
            thisWeek,
            lastWeek
        )
    }

    var quranAveragePerSession: Int {
        guard !logs.isEmpty else { return 0 }

        let total = logs.reduce(0) {
            $0 + $1.ayahsRead
        }

        return total / logs.count
    }

    var quranTodayAyahs: Int {
        logs
            .filter {
                $0.loggedAt >= startOfTrackingDay &&
                $0.loggedAt < startOfTrackingTomorrow
            }
            .reduce(0) {
                $0 + $1.ayahsRead
            }
    }

    func nudgeMessage(
        language: String
    ) -> String? {
        guard quranAveragePerSession > 0 else {
            return nil
        }

        if quranTodayAyahs == 0 {
            return String(
                format: localizedString(
                    "quran.nudge.zero",
                    language: language
                ),
                quranAveragePerSession
            )
        }

        if quranTodayAyahs < quranAveragePerSession {
            return String(
                format: localizedString(
                    "quran.nudge.below",
                    language: language
                ),
                quranTodayAyahs,
                quranAveragePerSession
            )
        }

        return nil
    }

    func activityLast63Days() -> [
        (date: Date, ayahs: Int)
    ] {
        let calendar = Calendar.current

        var result: [
            (date: Date, ayahs: Int)
        ] = []

        for offset in stride(
            from: 62,
            through: 0,
            by: -1
        ) {
            let start = calendar.date(
                byAdding: .day,
                value: -offset,
                to: startOfTrackingDay
            )!

            let end = calendar.date(
                byAdding: .day,
                value: 1,
                to: start
            )!

            let total = logs
                .filter {
                    $0.loggedAt >= start &&
                    $0.loggedAt < end
                }
                .reduce(0) {
                    $0 + $1.ayahsRead
                }

            result.append(
                (
                    calendar.startOfDay(
                        for: start
                    ),
                    total
                )
            )
        }

        return result
    }
}
