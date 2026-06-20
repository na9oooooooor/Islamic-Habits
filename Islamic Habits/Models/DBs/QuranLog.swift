import Foundation
import SwiftData

@Model
class QuranLog {
    var loggedAt: Date
    var surahFromNumber: Int
    var ayahFrom: Int
    var surahToNumber: Int
    var ayahTo: Int
    var ayahsRead: Int      


    init(
        surahFromNumber: Int,
        ayahFrom: Int,
        surahToNumber: Int,
        ayahTo: Int,
        ayahsRead: Int,
    ) {
        self.loggedAt = Date()
        self.surahFromNumber = surahFromNumber
        self.ayahFrom = ayahFrom
        self.surahToNumber = surahToNumber
        self.ayahTo = ayahTo
        self.ayahsRead = ayahsRead
    }
}
