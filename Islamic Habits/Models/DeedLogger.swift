import Foundation
import SwiftData

struct DeedLogger {
    
    static func alreadyLoggedToday(worshipTypeId: UUID, context: ModelContext) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DeedLog>(
            predicate: #Predicate { log in
                log.worshipTypeId == worshipTypeId &&
                log.loggedAt >= startOfDay
            }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        return !results.isEmpty
    }
    
    static func log(worshipTypeId: UUID, context: ModelContext) {
        guard !alreadyLoggedToday(worshipTypeId: worshipTypeId, context: context) else { return }
        let newLog = DeedLog(worshipTypeId: worshipTypeId)
        context.insert(newLog)
    }
    
}
