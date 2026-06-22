import Foundation
import SwiftData

struct HomeViewModel {
    
    func engine(logs: [DeedLog], dailyGoal: Int) -> DeedEngine {
        DeedEngine(logs: logs, dailyGoal: dailyGoal)
    }
    
    func totalDeedsToday(logs: [DeedLog]) -> Int {
        logs.filter { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }.count
    }
    
    func globalRhythm(logs: [DeedLog], dailyGoal: Int) -> Int {
        engine(logs: logs, dailyGoal: dailyGoal).rhythmLast66Days
    }
    
    func isReadyForNextCommitment(logs: [DeedLog], dailyGoal: Int) -> Bool {
        engine(logs: logs, dailyGoal: dailyGoal).readyForNextCommitment
    }
    
    func canUndo(logs: [DeedLog]) -> Bool {
        logs.contains { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }
    }
    
    func undoLastLog(logs: [DeedLog], context: ModelContext) {
        let todayLogs = logs.filter { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }
        let sorted = todayLogs.sorted { $0.loggedAt > $1.loggedAt }
        guard let latest = sorted.first else { return }
        context.delete(latest)
    }
    
    func log(worshipType: WorshipType, context: ModelContext) {
        let newLog = DeedLog(worshipType: worshipType)
        context.insert(newLog)
    }
    
    
}
