import Foundation

struct QuranEngine {
    let logs: [QuranLog]
    
    var quranStreak: Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        while true {
            let hasLog = logs.contains {
                Calendar.current.isDate($0.loggedAt, inSameDayAs: date)
            }
            guard hasLog else { break }
            streak += 1
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        }
        return streak
    }
    
    var quranVolumeTrend: (thisWeek: Int, lastWeek: Int) {
        let now = Date()
        let startThisWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let startLastWeek = Calendar.current.date(byAdding: .day, value: -14, to: now)!

        let thisWeek = logs
            .filter { $0.loggedAt >= startThisWeek }
            .reduce(0) { $0 + $1.ayahsRead }

        let lastWeek = logs
            .filter { $0.loggedAt >= startLastWeek && $0.loggedAt < startThisWeek }
            .reduce(0) { $0 + $1.ayahsRead }

        return (thisWeek, lastWeek)
    }
    
    var quranAveragePerSession: Int {
        guard !logs.isEmpty else { return 0 }
        let total = logs.reduce(0) { $0 + $1.ayahsRead }
        return total / logs.count
    }

    var quranTodayAyahs: Int {
        logs
            .filter { Calendar.current.isDateInToday($0.loggedAt) }
            .reduce(0) { $0 + $1.ayahsRead }
    }

    // nudge: if today < average, show encouragement
    func nudgeMessage(language: String) -> String? {
        guard quranAveragePerSession > 0 else { return nil }

        if quranTodayAyahs == 0 {
            return String(
                format: localizedString("quran.nudge.zero", language: language),
                quranAveragePerSession
            )
        }
        if quranTodayAyahs < quranAveragePerSession {
            return String(
                format: localizedString("quran.nudge.below", language: language),
                quranTodayAyahs,
                quranAveragePerSession
            )
        }
        return nil
    }
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
