import Foundation
import SwiftData

@Model
class DeedLog {
    var worshipType: String
    var loggedAt: Date
    var note: String?
    
    init(worshipType: WorshipType) {
        self.worshipType = worshipType.rawValue
        self.loggedAt = Date()
        self.note = nil
    }
}
