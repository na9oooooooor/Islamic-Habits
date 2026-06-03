//
//  DeedLevel.swift
//  Islamic Habits
//
//  Created by NASER ALALI on 01/06/2026.
//

import Foundation

enum DeedLevel: Int, CaseIterable {
    case niyyah = 1        // days 1–14
    case muraqabah = 2     // days 15–35
    case istiqamah = 3     // days 36–55
    case aadah = 4         // days 56–66
    case tabiah = 5        // days 66+

    var arabicName: String {
        switch self {
        case .niyyah:     return "نيّة"
        case .muraqabah:  return "مراقبة"
        case .istiqamah:  return "استقامة"
        case .aadah:      return "عادة"
        case .tabiah:     return "طبيعة"
        }
    }

    var englishName: String {
        switch self {
        case .niyyah:     return "Intention"
        case .muraqabah:  return "Watchfulness"
        case .istiqamah:  return "Steadfastness"
        case .aadah:      return "Habit"
        case .tabiah:     return "Second Nature"
        }
    }

    var thaiName: String {
        switch self {
        case .niyyah:     return "ความตั้งใจ"
        case .muraqabah:  return "การตระหนักรู้"
        case .istiqamah:  return "ความมั่นคง"
        case .aadah:      return "นิสัย"
        case .tabiah:     return "ธรรมชาติที่สอง"
        }
    }

    var streakRange: String {
        switch self {
        case .niyyah:     return "1–14 days"
        case .muraqabah:  return "15–35 days"
        case .istiqamah:  return "36–55 days"
        case .aadah:      return "56–66 days"
        case .tabiah:     return "66+ days"
        }
    }
    
    func streakRange(language: String) -> String {
        switch language {
        case "ar":
            switch self {
            case .niyyah:    return "١–١٤ يوم"
            case .muraqabah: return "١٥–٣٥ يوم"
            case .istiqamah: return "٣٦–٥٥ يوم"
            case .aadah:     return "٥٦–٦٦ يوم"
            case .tabiah:    return "٦٦+ يوم"
            }
        case "th":
            switch self {
            case .niyyah:    return "1–14 วัน"
            case .muraqabah: return "15–35 วัน"
            case .istiqamah: return "36–55 วัน"
            case .aadah:     return "56–66 วัน"
            case .tabiah:    return "66+ วัน"
            }
        default:
            return streakRange
        }
    }

    static func from(streak: Int) -> DeedLevel {
        switch streak {
        case 0..<15:  return .niyyah
        case 15..<36: return .muraqabah
        case 36..<56: return .istiqamah
        case 56..<67: return .aadah
        default:      return .tabiah
        }
    }

    // Progress within current level (0.0 to 1.0)
    var progressRange: ClosedRange<Int> {
        switch self {
        case .niyyah:    return 1...14
        case .muraqabah: return 15...35
        case .istiqamah: return 36...55
        case .aadah:     return 56...66
        case .tabiah:    return 67...200
        }
    }

    func progress(streak: Int) -> Double {
        if self == .tabiah { return 1.0 }
        let range = progressRange
        let position = streak - range.lowerBound
        let total = range.upperBound - range.lowerBound
        return min(max(Double(position) / Double(total), 0), 1)
    }
    
    var graceDays: Int {
        switch self {
        case .niyyah:    return 0
        case .muraqabah: return 2
        case .istiqamah: return 2
        case .aadah:     return 4
        case .tabiah:    return 4
        }
    }
    
    func gracePeriods(for worshipType: WorshipType) -> Int {
        switch worshipType.cadence {
        case "daily":
            // grace in days
            return graceDays
        case "weekly":
            // more forgiving — life happens week to week
            switch self {
            case .niyyah:    return 0
            case .muraqabah: return 1
            case .istiqamah: return 1
            case .aadah:     return 2
            case .tabiah:    return 2
            }
        case "monthly":
            // very forgiving — missing one month is ok at higher levels
            switch self {
            case .niyyah:    return 0
            case .muraqabah: return 1
            case .istiqamah: return 1
            case .aadah:     return 1
            case .tabiah:    return 2
            }
        default:
            return graceDays
        }
    }
    
    func localizedName(language: String) -> String {
        switch language {
        case "ar": return arabicName
        case "th": return thaiName
        default:   return englishName
        }
    }
}
