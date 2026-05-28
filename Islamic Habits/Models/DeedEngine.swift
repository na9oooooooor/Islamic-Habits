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
        let sixtySixDaysAgo = Calendar.current.date(byAdding: .day, value: -66, to: startOfIslamicTomorrow)!
        let recentLogs = logs.filter { $0.loggedAt >= sixtySixDaysAgo && $0.loggedAt <= startOfIslamicTomorrow }
        let grouped = Dictionary(grouping: recentLogs) { islamicStartOfDay(for: $0.loggedAt) }
        let activeDays = grouped.filter { $0.value.count >= dailyGoal }.count
        let habitEstablishedAt = 66 * 0.8
        return Int(round((Double(activeDays) / habitEstablishedAt) * 100))
    }
    
    // MARK: - Commitment
    var readyForNextCommitment: Bool {
        rhythmLast66Days >= 70
    }
    
    var has3Logs: Bool {
    
        let recentLogs = logs.filter { $0.loggedAt <= startOfIslamicTomorrow }
        let grouped = Dictionary(grouping: recentLogs) { islamicStartOfDay(for: $0.loggedAt) }
        let activeDays = grouped.filter { $0.value.count >= dailyGoal }.count
         if activeDays >= 3 {
            return true
         } else {return false}
    }
    
    func countLast66Days(for worshipType: WorshipType) -> Int {
        let sixtySixDaysAgo = Calendar.current.date(byAdding: .day, value: -66, to: startOfIslamicTomorrow)!
        return logs.filter {
            $0.worshipType == worshipType.rawValue &&
            $0.loggedAt >= sixtySixDaysAgo
        }.count+1
    }
    
    func daysSinceLastLog(for worshipType: WorshipType) -> Int? {
        let worshipLogs = logs.filter { $0.worshipType == worshipType.rawValue }
        guard let lastLog = worshipLogs.max(by: { $0.loggedAt < $1.loggedAt }) else { return nil }
        return Calendar.current.dateComponents([.day], from: lastLog.loggedAt, to: Date()).day
    }

    func isOverdue(for worshipType: WorshipType) -> Bool {
        guard let days = daysSinceLastLog(for: worshipType) else { return false }
        switch worshipType.cadence {
        case "daily": return days >= 3
        case "weekly": return days >= 14
        case "monthly": return days >= 60
        default: return false
        }
    }
}
