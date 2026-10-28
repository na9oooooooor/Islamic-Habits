import Foundation
import SwiftData

struct HomeViewModel {
    
    func engine(logs: [DeedLog], dailyGoal: Int) -> DeedEngine {
        DeedEngine(logs: logs, dailyGoal: dailyGoal)
    }
    
    func totalDeedsToday(logs: [DeedLog]) -> Int {
        logs.filter { $0.loggedAt >= startOfTrackingDay && $0.loggedAt < startOfTrackingTomorrow }.count
    }
    
    func globalRhythm(logs: [DeedLog], dailyGoal: Int) -> Int {
        engine(logs: logs, dailyGoal: dailyGoal).rhythmLast66Days
    }
    
    func isReadyForNextCommitment(logs: [DeedLog], dailyGoal: Int) -> Bool {
        engine(logs: logs, dailyGoal: dailyGoal).readyForNextCommitment
    }
    
    func canUndo(logs: [DeedLog]) -> Bool {
        logs.contains { $0.loggedAt >= startOfTrackingDay && $0.loggedAt < startOfTrackingTomorrow }
    }
    
    func undoLastLog(
        logs: [DeedLog],
        quranLogs: [QuranLog],
        context: ModelContext
    ) {
        let todayLogs = logs.filter {
            $0.loggedAt >= startOfTrackingDay &&
            $0.loggedAt < startOfTrackingTomorrow
        }

        guard let latest = todayLogs.max(
            by: { $0.loggedAt < $1.loggedAt }
        ) else {
            return
        }

        if latest.worshipType == WorshipType.quran.rawValue {

            let matchingQuranLog = quranLogs
                .filter {
                    abs(
                        $0.loggedAt.timeIntervalSince(
                            latest.loggedAt
                        )
                    ) < 10
                }
                .min {
                    abs(
                        $0.loggedAt.timeIntervalSince(
                            latest.loggedAt
                        )
                    )
                    <
                    abs(
                        $1.loggedAt.timeIntervalSince(
                            latest.loggedAt
                        )
                    )
                }

            if let matchingQuranLog {
                context.delete(matchingQuranLog)
            }
        }

        context.delete(latest)

        do {
            try context.save()
        } catch {
            print("Undo failed: \(error)")
        }
    }
    
    func log(worshipType: WorshipType, context: ModelContext) {
        let newLog = DeedLog(worshipType: worshipType)
        context.insert(newLog)
    }
    
    
}
