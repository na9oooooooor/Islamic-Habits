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
    case feeding = "worship.feeding"
    case water = "worship.water"
    case removeHarm = "worship.remove_harm"
    case smile = "worship.smile"
    case visitSick = "worship.visit_sick"
    case goodWord = "worship.good_word"
    
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
        case .feeding, .water, .removeHarm, .smile, .visitSick, .goodWord: return "daily"

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
        case .feeding: return "إطعام"
        case .water: return "ماء"
        case .removeHarm: return "إزالة الأذى"
        case .smile: return "ابتسامة"
        case .visitSick: return "عيادة المريض"
        case .goodWord: return "كلمة طيبة"
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
        case .feeding: return "fork.knife"
        case .water: return "drop"
        case .removeHarm: return "shield"
        case .smile: return "face.smiling"
        case .visitSick: return "cross.case"
        case .goodWord: return "quote.bubble"
        }
    }
}
