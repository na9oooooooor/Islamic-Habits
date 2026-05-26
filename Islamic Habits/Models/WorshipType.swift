import Foundation

enum WorshipType: String, CaseIterable {
    case quran = "worship.quran"
    case dhikr = "worship.dhikr"
    case sunnah = "worship.sunnah"
    case duaa = "worship.duaa"
    case sadaqah = "worship.sadaqah"
    case qiyam = "worship.qiyam"
    case masjid = "worship.masjid"
    case hadith = "worship.hadith"
    case fasting = "worship.fasting"
    case other = "worship.other"
    
    var cadence: String {
        switch self {
        case .quran: return "daily"
        case .dhikr: return "daily"
        case .sunnah: return "daily"
        case .duaa: return "daily"
        case .sadaqah: return "monthly"
        case .qiyam: return "weekly"
        case .masjid: return "weekly"
        case .hadith: return "daily"
        case .fasting: return "monthly"
        case .other: return "daily"
        }
    }
    
    
    var nameKey: String { rawValue }
    
    var arabicName: String {
        switch self {
        case .quran: return "قرآن"
        case .dhikr: return "ذكر"
        case .sunnah: return "صلاة سنّة"
        case .duaa: return "دعاء"
        case .sadaqah: return "صدقة"
        case .qiyam: return "قيام"
        case .masjid: return "مسجد"
        case .hadith: return "حديث"
        case .fasting: return "صيام"
        case .other: return "اخرى"
        }
    }
    
    
    var systemIcon: String {
        switch self {
        case .quran: return "book"
        case .dhikr: return "circle.grid.3x3"
        case .sunnah: return "moon.stars"
        case .duaa: return "hands.sparkles"
        case .sadaqah: return "heart"
        case .qiyam: return "moon"
        case .masjid: return "house.lodge"
        case .hadith: return "text.book.closed"
        case .fasting: return "sun.and.horizon"
        case .other: return "gift"
        }
    }
}
