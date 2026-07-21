import Foundation

struct DeedEngine {
    let logs: [DeedLog]
    let dailyGoal: Int
    
    // MARK: - Today
    var todayLogs: [DeedLog] {
        logs.filter { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }
    }
    
    func localizedDayCount(_ count: Int, language: String) -> String {
        switch language {
        case "ar":
            if count == 1 { return "يوم واحد" }
            else if count >= 3 && count <= 10 { return "\(count) أيام" }
            else { return "\(count) يوم" } // 11+ uses singular in Arabic
        case "th":
            return "\(count) วัน"
        default:
            return count == 1 ? "1 day" : "\(count) days"
        }
    }
    
    // MARK: - Rhythm
    var rhythmLast66Days: Int {
        let sixtySixDaysAgo = Calendar.current.date(byAdding: .day, value: -66, to: startOfIslamicTomorrow)!
        let recentLogs = logs.filter { $0.loggedAt >= sixtySixDaysAgo && $0.loggedAt <= startOfIslamicTomorrow }
        let grouped = Dictionary(grouping: recentLogs) { islamicStartOfDay(for: $0.loggedAt) }
        let activeDays = grouped.filter { $0.value.count >= dailyGoal }.count
        let habitEstablishedAt = 66 * 0.8
        return Int(round((Double(activeDays) / habitEstablishedAt) * 100))
    }
    
    var totalActiveDays: Int {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: logs) {
            calendar.startOfDay(for: $0.loggedAt)
        }
        return grouped.filter { $0.value.count >= dailyGoal }.count
    }
    // MARK: - Commitment
    

    
    var readyForNextCommitment: Bool {
        rhythmLast66Days >= 70
    }
    
    var has3Logs: Bool {
    
        let recentLogs = logs.filter { $0.loggedAt <= startOfIslamicTomorrow }
        let grouped = Dictionary(grouping: recentLogs) { islamicStartOfDay(for: $0.loggedAt) }
        let activeDays = grouped.filter { $0.value.count >= dailyGoal }.count
         if activeDays >= 3 {
            return true
         } else {return false}
    }
    
    func countLast66Days(for worshipType: WorshipType) -> Int {
        let sixtySixDaysAgo = Calendar.current.date(byAdding: .day, value: -66, to: startOfIslamicTomorrow)!
        return logs.filter {
            $0.worshipType == worshipType.rawValue &&
            $0.loggedAt >= sixtySixDaysAgo
        }.count+1
    }
    
    func globalDaysSinceLastLog() -> Int? {
        guard let lastLog = logs.max(by: { $0.loggedAt < $1.loggedAt }) else { return nil }
        let lastLogIslamicDay = islamicStartOfDay(for: lastLog.loggedAt)
        return Calendar.current.dateComponents([.day], from: lastLogIslamicDay, to: startOfIslamicDay).day
    }


    // MARK: - Streak & Level

    func computedCurrentLevel() -> DeedLevel {
        let calendar = Calendar.current
        
        // Group all logs by calendar day
        let grouped = Dictionary(grouping: logs) {
            calendar.startOfDay(for: $0.loggedAt)
        }
        
        // Count days where at least dailyGoal logs exist
        let activeDays = grouped.filter { $0.value.count >= dailyGoal }.count
        
        return DeedLevel.from(streak: activeDays)
    }

    func globalEffectiveStreak(state: GlobalRhythmState) -> Int {
        let calendar = Calendar.current
        // Use computed level — NOT stored level — for grace days
        let level = computedCurrentLevel()
        let graceDays = level.graceDays
        var periodStart = startOfIslamicDay
        var streak = 0
        var consecutiveMisses = 0

        while true {
            let periodEnd = calendar.date(byAdding: .day, value: 1, to: periodStart)!
            let logCount = logs.filter {
                $0.loggedAt >= periodStart && $0.loggedAt < periodEnd
            }.count

            let isToday = periodStart == startOfIslamicDay

            if logCount >= dailyGoal {
                streak += 1
                consecutiveMisses = 0
            } else if isToday {
                // don't penalize today
            } else {
                consecutiveMisses += 1
                if consecutiveMisses > graceDays { break }
            }

            periodStart = calendar.date(byAdding: .day, value: -1, to: periodStart)!
        }
        return streak
    }

    func globalBasePercentage(state: GlobalRhythmState) -> Double {
        let level = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
        let streak = globalEffectiveStreak(state: state)
        return level.progress(streak: streak) * 100
    }



    func globalDaysPastGrace(state: GlobalRhythmState) -> Int {
        guard let daysSince = globalDaysSinceLastLog() else { return 0 }
        let level = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
        let graceDays = level.graceDays
        let completedMissedDays = max(0, daysSince - 1)
        return max(0, completedMissedDays - graceDays)
    }
    
    func globalDecayedPercentage(state: GlobalRhythmState) -> Double {
        let level = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
        let basePercentage = globalBasePercentage(state: state)
        let daysPastGrace = globalDaysPastGrace(state: state)

        guard daysPastGrace > 0 else { return basePercentage }

        var result = basePercentage
        for _ in 0..<daysPastGrace {
            result -= result * level.decayRate
        }
        return result
    }
    
    func globalShouldDropLevel(state: GlobalRhythmState) -> Bool {
        return globalDecayedPercentage(state: state) <= DeedLevel.rhythmDecayThreshold
    }
    
    func droppedLevel(from level: DeedLevel) -> DeedLevel {
        let newRaw = max(1, level.rawValue - 1)
        return DeedLevel(rawValue: newRaw) ?? .niyyah
    }
    
    func applyLevelDropIfNeeded(state: GlobalRhythmState) {
        // Sync stored level with reality first
        let computed = computedCurrentLevel()
        state.currentLevel = max(state.currentLevel, computed.rawValue) // never drop below what logs justify
        
        guard globalShouldDropLevel(state: state) else { return }
        let currentLevel = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
        state.currentLevel = droppedLevel(from: currentLevel).rawValue
    }

    func applyLevelUpIfNeeded(state: GlobalRhythmState) {
        let computed = computedCurrentLevel()
        let streak = globalEffectiveStreak(state: state)
        let streakLevel = DeedLevel.from(streak: streak)
        
        // Take the higher of computed vs streak-based
        let bestLevel = max(computed.rawValue, streakLevel.rawValue)
        if bestLevel > state.currentLevel {
            state.currentLevel = bestLevel
            return
        }
        
        // Immediate level-up at 100%
        let percentage = globalBasePercentage(state: state)
        if percentage >= 100 {
            let currentLevel = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
            if currentLevel != .tabiah {
                state.currentLevel = min(state.currentLevel + 1, 5)
            }
        }
    }
    
    func last66DaysLogged(for worshipType: WorshipType) -> [Date: Bool] {
        var result: [Date: Bool] = [:]
        let calendar = Calendar.current
        
        for dayOffset in 0..<66 {
            let islamicDay = calendar.date(byAdding: .day, value: -dayOffset, to: startOfIslamicDay)!
            let midnightDay = calendar.startOfDay(for: islamicDay)  // normalize to midnight
            
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: islamicDay)!
            
            let hasLog = logs.contains {
                $0.worshipType == worshipType.rawValue &&
                $0.loggedAt >= islamicDay &&
                $0.loggedAt < dayEnd
            }
            
            result[midnightDay] = hasLog  // store with midnight key
        }
        
        return result
    }
    
    func mirrorMessage(state: GlobalRhythmState, language: String) -> MirrorMessage? {
        let currentLevel = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
        let streak = globalEffectiveStreak(state: state)
        let daysPastGrace = globalDaysPastGrace(state: state)
        let randomDeed = WorshipType.allCases.randomElement()!

        // 1. ALERT — level should drop
        if globalShouldDropLevel(state: state) {
            return MirrorMessage(
                priority: .alert,
                icon: "exclamationmark.circle.fill",
                title: currentLevel.localizedName(language: language),
                subtitle: localizedString("mirror.streak.broken", language: language)
            )
        }

        // 2. ALERT — past grace but not yet at drop threshold
        if daysPastGrace > 0 {
            return MirrorMessage(
                priority: .alert,
                icon: "exclamationmark.triangle.fill",
                title: currentLevel.localizedName(language: language),
                subtitle: localizedString("mirror.grace.last", language: language)
            )
        }

        // 3. NUDGE — daily goal not met today
        if todayLogs.count < dailyGoal {
            return MirrorMessage(
                priority: .nudge,
                icon: "moon.stars",
                title: "مرآة",
                subtitle: localizedString("mirror.not.logged", language: language)
            )
        }

        // 4. PROGRESS — streak milestone (every 7 days)
        if streak > 0 && streak % 7 == 0 {
            return MirrorMessage(
                priority: .progress,
                icon: "star",
                title: currentLevel.localizedName(language: language),
                subtitle: "\(streak) \(localizedString("focus.streak.healthy", language: language)). \(localizedString("mirror.angels", language: language))"
            )
        }

        // 5. LEVEL UP — within 5 days of next level
        if currentLevel != .tabiah {
            let daysLeft = currentLevel.progressRange.upperBound - streak
            if daysLeft <= 5 && daysLeft > 0 {
                let nextLevel = DeedLevel(rawValue: currentLevel.rawValue + 1) ?? .tabiah
                return MirrorMessage(
                    priority: .levelUp,
                    icon: "arrow.up.circle.fill",
                    title: currentLevel.localizedName(language: language),
                    subtitle: "\(daysLeft) \(localizedString("mirror.days.to", language: language)) \(nextLevel.arabicName). \(localizedString("mirror.lasting", language: language))"
                )
            }
        }

        // 6. QUOTE — random, three options
        let option = Int.random(in: 1...3)
        switch option {
        case 1:
            let percentage = Int(globalDecayedPercentage(state: state))
            let message = percentage == 0
                ? localizedString("mirror.journey.start", language: language)
                : percentage < 50
                ? "\(percentage)% \(localizedString("mirror.habit.building", language: language))"
                : "\(percentage)% \(localizedString("mirror.habit.progress", language: language))"
            return MirrorMessage(
                priority: .quote,
                icon: "chart.bar",
                title: "مرآة",
                subtitle: message
            )
        case 2:
            return MirrorMessage(
                priority: .nudge,
                icon: "scope",
                title: "مرآة",
                subtitle: localizedString("mirror.pick.focus", language: language)
            )
        default:
            return MirrorMessage(
                priority: .quote,
                icon: "quote.bubble",
                title: randomDeed.arabicName,
                subtitle: localizedString(randomDeed.randomInsight, language: language)
            )
        }
    }
    
    
    private func localizedMirror(_ key: String, language: String) -> String {
        localizedString(key, language: language)
    }
    
    var averageLogHour: Int {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let recentLogs = logs.filter { $0.loggedAt >= sevenDaysAgo }
        guard !recentLogs.isEmpty else { return 8 } // default 8am
        
        let hours = recentLogs.map { calendar.component(.hour, from: $0.loggedAt) }
        return hours.reduce(0, +) / hours.count
    }

    func averageLogHour(for worshipType: WorshipType) -> Int {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let recentLogs = logs.filter {
            $0.worshipType == worshipType.rawValue &&
            $0.loggedAt >= sevenDaysAgo
        }
        guard !recentLogs.isEmpty else { return averageLogHour } // fall back to general average
        
        let hours = recentLogs.map { calendar.component(.hour, from: $0.loggedAt) }
        return hours.reduce(0, +) / hours.count
    }
    
    func calculateAyahsRead(
        surahFromNumber: Int,
        ayahFrom: Int,
        surahToNumber: Int,
        ayahTo: Int
    ) -> Int {
        let surahs = QuranData.surahs

        // Guard: from must come before to
        guard surahFromNumber <= surahToNumber else { return 0 }

        // Case 1: same surah
        if surahFromNumber == surahToNumber {
            return max(0, ayahTo - ayahFrom + 1)
        }

        // Case 2: multiple surahs
        var total = 0

        for surahNumber in surahFromNumber...surahToNumber {
            guard let surah = surahs.first(where: { $0.number == surahNumber }) else { continue }

            if surahNumber == surahFromNumber {
                total += surah.ayahs - ayahFrom + 1
            } else if surahNumber == surahToNumber {
                total += ayahTo
            } else {
                total += surah.ayahs
            }
        }

        return total
    }
    
    //MARK: pre-worship focus deeds
    
    var loggedTodayByWorship: [String: Bool] {
        var result: [String: Bool] = [:]
        for worship in WorshipType.allCases {
            result[worship.rawValue] = todayLogs.contains { $0.worshipType == worship.rawValue }
        }
        return result
    }

    var todayCountByWorship: [String: Int] {
        var result: [String: Int] = [:]
        for worship in WorshipType.allCases {
            result[worship.rawValue] = todayLogs.filter { $0.worshipType == worship.rawValue }.count
        }
        return result
    }
    
    func daysSinceLastLog(for worshipType: WorshipType) -> Int? {
        let worshipLogs = logs.filter { $0.worshipType == worshipType.rawValue }
        guard let lastLog = worshipLogs.max(by: { $0.loggedAt < $1.loggedAt }) else { return nil }
        return Calendar.current.dateComponents([.day], from: lastLog.loggedAt, to: Date()).day
    }

    func isOverdue(for worshipType: WorshipType) -> Bool {
        guard let days = daysSinceLastLog(for: worshipType) else { return false }
        switch worshipType.cadence {
        case "daily": return days >= 3
        case "weekly": return days >= 14
        case "monthly": return days >= 60
        default: return false
        }
    }
    
    func rawStreak(for worshipType: WorshipType) -> Int {
        let calendar = Calendar.current
        let unit = worshipType.streakUnit
        var periodStart = startOfIslamicDay
        var streak = 0

        while true {
            let periodEnd = calendar.date(byAdding: .day, value: 1, to: periodStart)!
            let windowStart = calendar.date(byAdding: .day, value: -(unit - 1), to: periodStart)!

            let hasLog = logs.contains {
                $0.worshipType == worshipType.rawValue &&
                $0.loggedAt >= windowStart &&
                $0.loggedAt < periodEnd
            }

            guard hasLog else { break }
            streak += 1
            periodStart = calendar.date(byAdding: .day, value: -unit, to: periodStart)!
        }
        return streak
    }

    func level(for worshipType: WorshipType) -> DeedLevel {
        DeedLevel.from(streak: rawStreak(for: worshipType))
    }

    func streak(for worshipType: WorshipType) -> Int {
        let calendar = Calendar.current
        let unit = worshipType.streakUnit
        let graceDays = level(for: worshipType).graceDays
        var periodStart = startOfIslamicDay
        var streak = 0
        var consecutiveMisses = 0

        while true {
            let periodEnd = calendar.date(byAdding: .day, value: 1, to: periodStart)!
            let windowStart = calendar.date(byAdding: .day, value: -(unit - 1), to: periodStart)!

            let hasLog = logs.contains {
                $0.worshipType == worshipType.rawValue &&
                $0.loggedAt >= windowStart &&
                $0.loggedAt < periodEnd
            }

            if hasLog {
                streak += 1
                consecutiveMisses = 0
            } else {
                consecutiveMisses += 1
                if consecutiveMisses > graceDays { break }
            }

            periodStart = calendar.date(byAdding: .day, value: -unit, to: periodStart)!
        }
        return streak
    }

    func effectiveLevel(for worshipType: WorshipType) -> DeedLevel {
        let currentLevel = level(for: worshipType)
        let used = graceDaysUsed(for: worshipType)
        let total = currentLevel.graceDays
        if used > total {
            let droppedRaw = max(1, currentLevel.rawValue - 1)
            return DeedLevel(rawValue: droppedRaw) ?? .niyyah
        }
        return currentLevel
    }

    func graceDaysUsed(for worshipType: WorshipType) -> Int {
        let calendar = Calendar.current
        let unit = worshipType.streakUnit
        var periodStart = startOfIslamicDay
        var used = 0
        let gracePeriods = level(for: worshipType).graceDays

        while true {
            let periodEnd = calendar.date(byAdding: .day, value: 1, to: periodStart)!
            let windowStart = calendar.date(byAdding: .day, value: -(unit - 1), to: periodStart)!

            let hasLog = logs.contains {
                $0.worshipType == worshipType.rawValue &&
                $0.loggedAt >= windowStart &&
                $0.loggedAt < periodEnd
            }

            if hasLog { break }
            used += 1
            if used > gracePeriods { break }

            periodStart = calendar.date(byAdding: .day, value: -unit, to: periodStart)!
        }
        return used
    }

    func streakStatus(for worshipType: WorshipType) -> StreakStatus {
        let used = graceDaysUsed(for: worshipType)
        let total = level(for: worshipType).graceDays
        if used == 0 { return .healthy }
        if used <= total { return .warning(remaining: total - used) }
        return .broken
    }
}
