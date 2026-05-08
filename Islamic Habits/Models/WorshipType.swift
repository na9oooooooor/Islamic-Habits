import Foundation

enum WorshipType: String, CaseIterable {
    case sunnahSalat = "worship.sunnah_salat"
    case quran = "worship.quran"
    
    var cadence: String {
        switch self {
        case .sunnahSalat: return "daily"
        case .quran: return "daily"
        }
    }
    
    var nameKey: String { rawValue }
}
