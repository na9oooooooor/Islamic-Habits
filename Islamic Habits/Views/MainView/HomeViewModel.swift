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
    
    @discardableResult
    func undoLastLog(
        logs: [DeedLog],
        quranLogs: [QuranLog],
        context: ModelContext
    ) -> Bool {
        let todayLogs = logs.filter {
            $0.loggedAt >= startOfTrackingDay &&
            $0.loggedAt < startOfTrackingTomorrow
        }

        guard let latest = todayLogs.max(
            by: { $0.loggedAt < $1.loggedAt }
        ) else {
            return true
        }

        // Save existing pending work before attempting deletion.
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Could not prepare undo: \(error)")
            return false
        }

        if let reading = latest.linkedQuranLog(
            in: quranLogs,
            among: logs
        ) {
            context.delete(reading)
        }

        context.delete(latest)

        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            print("Undo failed: \(error)")
            return false
        }
    }
    
    @discardableResult
    func log(
        worshipType: WorshipType,
        context: ModelContext
    ) -> Bool {
        let newLog = DeedLog(worshipType: worshipType)
        context.insert(newLog)

        do {
            try context.save()
        } catch {
            context.delete(newLog)
            print("Failed to save deed: \(error)")
            return false
        }

        MirrorAnalytics.deedSubmitted()
        return true
    }
    
    
}
