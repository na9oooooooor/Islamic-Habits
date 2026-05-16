import Foundation

struct DeedEngine {
    let logs: [DeedLog]
    let worshipType: WorshipType
    
    // MARK: - Today
    var loggedToday: Bool {
        let startOfDay = startOfIslamicDay
        let startOfTomorrow = startOfIslamicTomorrow
        return logs.contains { $0.loggedAt >= startOfDay && $0.loggedAt < startOfTomorrow }
    }
    
    var todayCount: Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return logs.filter { $0.loggedAt >= startOfDay }.count
    }
    
    // MARK: - Rhythm
    var rhythmLast66Days: Int {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let sixtySixDaysAgo = calendar.date(byAdding: .day, value: -66, to: today)!
            
            let recentLogs = logs.filter { $0.loggedAt >= sixtySixDaysAgo && $0.loggedAt < today }
            
            let activeDays = Set(recentLogs.map { calendar.startOfDay(for: $0.loggedAt) })
            
            return Int(round(Double(activeDays.count) / 66.0 * 100))
        }
    
    var readyForNextCommitment: Bool {
        rhythmLast66Days >= 70
    }
}
