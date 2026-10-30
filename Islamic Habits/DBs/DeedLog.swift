import Foundation
import SwiftData

@Model
class DeedLog {
    var worshipType: String
    var loggedAt: Date
    var note: String?
    var quranSessionID: UUID? = nil

    init(
        worshipType: WorshipType,
        loggedAt: Date = Date()
    ) {
        self.worshipType = worshipType.rawValue
        self.loggedAt = loggedAt
        self.note = nil
    }

    func linkedQuranLog(
        in quranLogs: [QuranLog],
        among deeds: [DeedLog]
    ) -> QuranLog? {
        guard worshipType == WorshipType.quran.rawValue else {
            return nil
        }

        if let sessionID = quranSessionID {
            let matches = quranLogs.filter {
                $0.quranSessionID == sessionID
            }

            return matches.count == 1 ? matches.first : nil
        }

        // Older records used an identical timestamp when saved.
        // Only accept an unambiguous, exact match.
        let matchingDeeds = deeds.filter {
            $0.worshipType == WorshipType.quran.rawValue &&
            $0.quranSessionID == nil &&
            $0.loggedAt == loggedAt
        }

        let matchingReadings = quranLogs.filter {
            $0.quranSessionID == nil &&
            $0.loggedAt == loggedAt
        }

        guard matchingDeeds.count == 1,
              matchingReadings.count == 1 else {
            return nil
        }

        return matchingReadings.first
    }
}
