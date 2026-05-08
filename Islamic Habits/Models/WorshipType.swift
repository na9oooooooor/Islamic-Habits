import Foundation
import SwiftData

@Model
class WorshipType {
    var id: UUID
    var nameKey: String
    var cadence: String
    var currentTier: Int
    var createdAt: Date
    
    init(nameKey: String, cadence: String) {
        self.id = UUID()
        self.nameKey = nameKey
        self.cadence = cadence
        self.currentTier = 1
        self.createdAt = Date()
    }
}
