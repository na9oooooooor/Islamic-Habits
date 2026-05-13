import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class HomeViewModel {
    
    var allLogs: [DeedLog] = []
    
    var globalEngine: DeedEngine {
        DeedEngine(logs: allLogs, worshipType: .quran)
    }
    
    var totalDeedsToday: Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return allLogs.filter { $0.loggedAt >= startOfDay && $0.loggedAt < startOfTomorrow }.count
    }

    var isReadyForNextCommitment: Bool {
        globalEngine.readyForNextCommitment
    }

    var globalRhythm: Int {
        globalEngine.rhythmLast66Days
    }
    
    func engine(for worshipType: WorshipType) -> DeedEngine {
        let worshipLogs = allLogs.filter { $0.worshipType == worshipType.rawValue }
        return DeedEngine(logs: worshipLogs, worshipType: worshipType)
    }
    
    func log(worshipType: WorshipType, context: ModelContext) {
        let engine = engine(for: worshipType)
        guard !engine.loggedToday else { return }
        let newLog = DeedLog(worshipType: worshipType)
        context.insert(newLog)
        allLogs.append(newLog)
    }
    
}
