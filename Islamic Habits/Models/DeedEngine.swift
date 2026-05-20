import Foundation

struct DeedEngine {
    let logs: [DeedLog]
    let dailyGoal: Int
    
    // MARK: - Today
    var todayLogs: [DeedLog] {
        logs.filter { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }
    }
    
    var loggedTodayByWorship: [String: Bool] {
        var result: [String: Bool] = [:]
        for worship in WorshipType.allCases {
            result[worship.rawValue] = todayLogs.contains { $0.worshipType == worship.rawValue }
        }
        return result
    }
    
    var todayCountByWorship: [String: Int] {
        var result: [String: Int] = [:]
        for worship in WorshipType.allCases {
            result[worship.rawValue] = todayLogs.filter { $0.worshipType == worship.rawValue }.count
        }
        return result
    }
    
    // MARK: - Rhythm
    var rhythmLast66Days: Int {
        let sixtySixDaysAgo = Calendar.current.date(byAdding: .day, value: -66, to: startOfIslamicDay)!
        let recentLogs = logs.filter { $0.loggedAt >= sixtySixDaysAgo && $0.loggedAt < startOfIslamicDay }
        let grouped = Dictionary(grouping: recentLogs) { islamicStartOfDay(for: $0.loggedAt) }
        let activeDays = grouped.filter { $0.value.count >= dailyGoal }.count
        return Int(round(Double(activeDays) / 66.0 * 100))
    }
    
    // MARK: - Commitment
    var readyForNextCommitment: Bool {
        rhythmLast66Days >= 70
    }
}
