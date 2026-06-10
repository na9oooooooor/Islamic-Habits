import Foundation

struct Surah: Codable, Identifiable {
    let number: Int
    let name: String
    let arabicName: String
    let thaiName: String
    let ayahs: Int
    let startPage: Int

    var id: Int { number }

    func localizedName(language: String) -> String {
        switch language {
        case "ar": return arabicName
        case "th": return thaiName
        default:   return name
        }
    }
}

struct QuranData {
    static let surahs: [Surah] = {
        guard let url = Bundle.main.url(forResource: "Quran", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let surahs = try? JSONDecoder().decode([Surah].self, from: data)
        else { return [] }
        return surahs
    }()
}
