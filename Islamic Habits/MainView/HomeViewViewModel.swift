import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class HomeViewModel {
    
    var allLogs: [DeedLog] = []
    
    var totalDeedsToday: Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return allLogs.filter { $0.loggedAt >= startOfDay && $0.loggedAt < startOfTomorrow }.count
    }

    var isReadyForNextCommitment: Bool {
        WorshipType.allCases
            .filter { $0.isActive }
            .allSatisfy { engine(for: $0).readyForNextCommitment }
    }

    
    func engine(for worshipType: WorshipType) -> DeedEngine {
        let worshipLogs = allLogs.filter { $0.worshipType == worshipType.rawValue }
        return DeedEngine(logs: worshipLogs, worshipType: worshipType)
    }
    
    func log(worshipType: WorshipType, context: ModelContext) {
        let engine = engine(for: worshipType)
        print("Tapped: \(worshipType.rawValue) | loggedToday: \(engine.loggedToday) | allLogs count: \(allLogs.count)")
        guard !engine.loggedToday else { return }
        let newLog = DeedLog(worshipType: worshipType)
        context.insert(newLog)
        allLogs.append(newLog)
        print("After log | allLogs count: \(allLogs.count) | totalDeedsToday: \(totalDeedsToday)")
    }
    
}
