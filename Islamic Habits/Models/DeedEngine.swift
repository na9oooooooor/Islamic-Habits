import Foundation

struct DeedEngine {
    let logs: [DeedLog]
    let worshipType: WorshipType
    let dailyGoal: Int
    
    // MARK: - Today
    var loggedToday: Bool {
        let startOfDay = startOfIslamicDay
        let startOfTomorrow = startOfIslamicTomorrow
        return logs.contains { $0.loggedAt >= startOfDay && $0.loggedAt < startOfTomorrow }
    }
    
    var todayCount: Int {
        logs.filter { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }.count
    }
    
    // MARK: - Rhythm
    var rhythmLast66Days: Int {
        let calendar = Calendar.current
        let today = startOfIslamicDay
        let sixtySixDaysAgo = calendar.date(byAdding: .day, value: -66, to: today)!
        
        let recentLogs = logs.filter { $0.loggedAt >= sixtySixDaysAgo && $0.loggedAt < today }
        
        // Group by day
        let grouped = Dictionary(grouping: recentLogs) { log in
            islamicStartOfDay(for: log.loggedAt)
        }
        
        // Count days where logs >= dailyGoal
        let activeDays = grouped.filter { $0.value.count >= dailyGoal }.count
        
        return Int(round(Double(activeDays) / 66.0 * 100))
    }
    
    var readyForNextCommitment: Bool {
        rhythmLast66Days >= 70
    }
    
    
    
    
    func totalDeedsToday(logs: [DeedLog]) -> Int {
        return logs.filter {
            $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow
        }.count
    }
}
