import Foundation

enum WorshipType: String, CaseIterable {
    case quran = "worship.quran"
    case dhikr = "worship.dhikr"
    case sunnahSalat = "worship.sunnahSalat"
    case duaa = "worship.duaa"
    case sadaqah = "worship.sadaqah"
    case qiyam = "worship.qiyam"
    case masjid = "worship.masjid"
    case sunnah = "worship.sunnah"
    case hadith = "worship.hadith"
    case fasting = "worship.fasting"
    case feeding = "worship.feeding"
    case water = "worship.water"
    case removeHarm = "worship.remove_harm"
    case smile = "worship.smile"
    case visitSick = "worship.visit_sick"
    case goodWord = "worship.good_word"
    case islamicStudy = "worship.islamic_study"
    case advice = "worship.advice"
    case other = "worship.other"
    
    var cadence: String {
        switch self {
        case .quran: return "daily"
        case .dhikr: return "weekly"
        case .sunnahSalat: return "daily"
        case .duaa: return "daily"
        case .sadaqah: return "monthly"
        case .qiyam: return "weekly"
        case .masjid: return "weekly"
        case .sunnah: return "weekly"
        case .hadith: return "weekly"
        case .fasting: return "monthly"
        case .feeding, .water, .removeHarm, .smile, .visitSick, .goodWord: return "weekly"
        case .other, .islamicStudy, .advice: return "weekly"


        }
    }
    
    
    var nameKey: String { rawValue }
    
    var streakUnit: Int {
        switch cadence {
        case "daily":   return 1    // 1 day window
        case "weekly":  return 7    // 7 day window
        case "monthly": return 30   // 30 day window
        default:        return 1
        }
    }

    var streakLabel: String {
        switch cadence {
        case "daily":   return "day"
        case "weekly":  return "week"
        case "monthly": return "month"
        default:        return "day"
        }
    }
    
    var arabicName: String {
        switch self {
        case .quran: return "قرآن"
        case .dhikr: return "ذكر"
        case .sunnahSalat: return "صلاة سنّة"
        case .duaa: return "دعاء"
        case .sadaqah: return "صدقة"
        case .qiyam: return "قيام"
        case .masjid: return "مسجد"
        case .sunnah: return "سنّه"
        case .hadith: return "حديث"
        case .fasting: return "صيام"
        case .feeding: return "إطعام"
        case .water: return "ماء"
        case .removeHarm: return "إزالة الأذى"
        case .smile: return "ابتسامة"
        case .visitSick: return "عيادة المريض"
        case .goodWord: return "كلمة طيبة"
        case .islamicStudy: return "علم"
        case .advice: return "نصيحة"
        case .other: return "أخرى"
        }
    }
    
    
    var icon: String {
        switch self {
        case .quran: return "book"
        case .dhikr: return "circle.grid.3x3"
        case .sunnahSalat: return "apple.image.playground"
        case .duaa: return "hands.sparkles"
        case .sadaqah: return "heart"
        case .qiyam: return "moon"
        case .masjid: return "house.lodge"
        case .sunnah: return "figure.stand"
        case .hadith: return "text.book.closed"
        case .fasting: return "sun.and.horizon"
        case .feeding: return "fork.knife"
        case .water: return "drop"
        case .removeHarm: return "shield"
        case .smile: return "face.smiling"
        case .visitSick: return "cross.case"
        case .goodWord: return "quote.bubble"
        case .other: return "plus.circle"
        case .islamicStudy: return "graduationcap"
        case .advice: return "person.2"
        }
    }
    
    var insights: [String] {
        switch self {
        case .quran: return ["insight.quran.1", "insight.quran.2", "insight.quran.3"]
        case .dhikr: return ["insight.dhikr.1", "insight.dhikr.2", "insight.dhikr.3"]
        case .sunnahSalat: return ["insight.sunnahSalat.1", "insight.sunnahSalat.2", "insight.sunnahSalat.3"]
        case .duaa: return ["insight.duaa.1", "insight.duaa.2", "insight.duaa.3"]
        case .sadaqah: return ["insight.sadaqah.1", "insight.sadaqah.2", "insight.sadaqah.3"]
        case .qiyam: return ["insight.qiyam.1", "insight.qiyam.2", "insight.qiyam.3"]
        case .masjid: return ["insight.masjid.1", "insight.masjid.2", "insight.masjid.3"]
        case .sunnah: return ["insight.sunnah.1", "insight.sunnah.2", "insight.sunnah.3"]
        case .hadith: return ["insight.hadith.1", "insight.hadith.2", "insight.hadith.3"]
        case .fasting: return ["insight.fasting.1", "insight.fasting.2", "insight.fasting.3"]
        case .feeding: return ["insight.feeding.1", "insight.feeding.2", "insight.feeding.3"]
        case .water: return ["insight.water.1", "insight.water.2", "insight.water.3"]
        case .removeHarm: return ["insight.remove_harm.1", "insight.remove_harm.2", "insight.remove_harm.3"]
        case .smile: return ["insight.smile.1", "insight.smile.2", "insight.smile.3"]
        case .visitSick: return ["insight.visit_sick.1", "insight.visit_sick.2", "insight.visit_sick.3"]
        case .goodWord: return ["insight.good_word.1", "insight.good_word.2", "insight.good_word.3"]
        case .other: return ["insight.good_word.1", "insight.good_word.2", "insight.good_word.3"]
        case .islamicStudy: return ["insight.islamic_study.1", "insight.islamic_study.2", "insight.islamic_study.3"]
        case .advice: return ["insight.advice.1", "insight.advice.2", "insight.advice.3"]
        }
    }

    var randomInsight: String {
        insights.randomElement() ?? insights[0]
    }
}

extension WorshipType: Identifiable {
    var id: String { rawValue }
}
