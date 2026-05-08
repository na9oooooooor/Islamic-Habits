import Foundation
import SwiftData

@Model
class DeedLog {
    var id: UUID
    var worshipTypeId: UUID
    var loggedAt: Date
    var note: String?
    
    init(worshipTypeId: UUID) {
        self.id = UUID()
        self.worshipTypeId = worshipTypeId
        self.loggedAt = Date()
        self.note = nil
    }
}
