import Foundation

struct DeedEngine {
    let logs: [DeedLog]
    let worshipType: WorshipType
    
    // MARK: - Today
    var loggedToday: Bool {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return logs.contains { $0.loggedAt >= startOfDay && $0.loggedAt < startOfTomorrow }
    }
    
    var todayCount: Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return logs.filter { $0.loggedAt >= startOfDay }.count
    }
    
    // MARK: - Rhythm
    var rhythmLast30Days: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
        
        let recentLogs = logs.filter { $0.loggedAt >= thirtyDaysAgo && $0.loggedAt < today }
        
        let activeDays = Set(recentLogs.map { calendar.startOfDay(for: $0.loggedAt) })
        
        return Int(round(Double(activeDays.count) / 30.0 * 100))
    }
}
