import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class HomeViewModel {
    
    var allLogs: [DeedLog] = []
    
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
