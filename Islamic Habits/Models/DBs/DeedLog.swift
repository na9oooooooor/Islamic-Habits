import Foundation
import SwiftData

@Model
class DeedLog {
    var worshipType: String
    var loggedAt: Date
    var note: String?
    
    init(worshipType: WorshipType, loggedAt: Date = Date()) {
        self.worshipType = worshipType.rawValue
        self.loggedAt = loggedAt
        self.note = nil
    }
}
