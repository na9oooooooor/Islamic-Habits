import Foundation
import SwiftData
import SwiftUI

struct HomeViewModel {
    
    func engine(for worshipType: WorshipType, logs: [DeedLog], dailyGoal: Int) -> DeedEngine {
        let worshipLogs = logs.filter { $0.worshipType == worshipType.rawValue }
        return DeedEngine(logs: worshipLogs, worshipType: worshipType, dailyGoal: dailyGoal)
    }

    func globalEngine(logs: [DeedLog], dailyGoal: Int) -> DeedEngine {
        DeedEngine(logs: logs, worshipType: .quran, dailyGoal: dailyGoal)
    }
    
    func totalDeedsToday(logs: [DeedLog]) -> Int {
        return logs.filter {
            $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow
        }.count
    }
    
    func globalRhythm(logs: [DeedLog], dailyGoal: Int) -> Int {
        globalEngine(logs: logs, dailyGoal: dailyGoal).rhythmLast66Days
    }

    func isReadyForNextCommitment(logs: [DeedLog], dailyGoal: Int) -> Bool {
        globalEngine(logs: logs, dailyGoal: dailyGoal).readyForNextCommitment
    }
    
    func canUndo(logs: [DeedLog]) -> Bool {
        logs.contains { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }
    }
    
    func log(worshipType: WorshipType, context: ModelContext) {
        let newLog = DeedLog(worshipType: worshipType)
        context.insert(newLog)
    }
    
    func undoLastLog(logs: [DeedLog], context: ModelContext) {
        let todayLogs = logs.filter { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }
        let sorted = todayLogs.sorted { $0.loggedAt > $1.loggedAt }
        guard let latest = sorted.first else { return }
        context.delete(latest)
    }
}
