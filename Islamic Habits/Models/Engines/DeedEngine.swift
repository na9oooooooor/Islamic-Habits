import Foundation

struct DeedEngine {
    let logs: [DeedLog]
    let dailyGoal: Int
    
    // MARK: - Today
    var todayLogs: [DeedLog] {
        logs.filter { $0.loggedAt >= startOfIslamicDay && $0.loggedAt < startOfIslamicTomorrow }
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
        return Calendar.current.dateComponents([.day], from: lastLog.loggedAt, to: Date()).day
    }


    // MARK: - Streak & Level

    func globalEffectiveStreak(state: GlobalRhythmState) -> Int {
        let calendar = Calendar.current
        let level = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
        let graceDays = level.graceDays
        var periodStart = startOfIslamicDay
        var streak = 0
        var consecutiveMisses = 0

        while true {
            let periodEnd = calendar.date(byAdding: .day, value: 1, to: periodStart)!
            let windowStart = periodStart

            let logCount = logs.filter {
                $0.loggedAt >= windowStart &&
                $0.loggedAt < periodEnd
            }.count

            if logCount >= dailyGoal {
                streak += 1
                consecutiveMisses = 0
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
        return max(0, daysSince - graceDays)
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
        guard globalShouldDropLevel(state: state) else { return }
        let currentLevel = DeedLevel(rawValue: state.currentLevel) ?? .niyyah
        let newLevel = droppedLevel(from: currentLevel)
        state.currentLevel = newLevel.rawValue
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
    
    func mirrorMessage(focusDeeds: [WorshipType], language: String) -> MirrorMessage? {
        if !focusDeeds.isEmpty {

            // 1. ALERT — streak broken
            for worship in focusDeeds {
                switch streakStatus(for: worship) {
                case .broken:
                    return MirrorMessage(
                        priority: .alert,
                        icon: "exclamationmark.circle.fill",
                        title: worship.arabicName,
                        subtitle: localizedString("mirror.streak.broken", language: language)
                    )
                case .warning(let remaining) where remaining == 0:
                    return MirrorMessage(
                        priority: .alert,
                        icon: "exclamationmark.triangle.fill",
                        title: worship.arabicName,
                        subtitle: localizedString("mirror.grace.last", language: language)
                    )
                default: break
                }
            }

            // 2. NUDGE — not logged today
            for worship in focusDeeds {
                let isLogged = loggedTodayByWorship[worship.rawValue] ?? false
                if !isLogged {
                    return MirrorMessage(
                        priority: .nudge,
                        icon: worship.icon,
                        title: worship.arabicName,
                        subtitle: localizedString("mirror.not.logged", language: language)
                    )
                }
            }

            // 3. PROGRESS — streak multiple of 7
            for worship in focusDeeds {
                let s = streak(for: worship)
                if s > 0 && s % 7 == 0 {
                    return MirrorMessage(
                        priority: .progress,
                        icon: "star",
                        title: worship.arabicName,
                        subtitle: "\(s) \(localizedString("focus.streak.healthy", language: language))s. \(localizedString("mirror.angels", language: language))"
                    )
                }
            }

            // 4. LEVEL UP — within 5 days of next level
            for worship in focusDeeds {
                let s = streak(for: worship)
                let currentLevel = effectiveLevel(for: worship)
                if currentLevel != .tabiah {
                    let daysLeft = currentLevel.progressRange.upperBound - s
                    if daysLeft <= 5 && daysLeft > 0 {
                        let nextLevel = DeedLevel(rawValue: currentLevel.rawValue + 1) ?? .tabiah
                        return MirrorMessage(
                            priority: .levelUp,
                            icon: "arrow.up.circle.fill",
                            title: worship.arabicName,
                            subtitle: "\(daysLeft) \(localizedString("mirror.days.to", language: language)) \(nextLevel.arabicName). \(localizedString("mirror.lasting", language: language))"

                        )
                    }
                }
            }

            // 5. QUOTE — from focus deed
            let focusDeed = focusDeeds.randomElement()!
            return MirrorMessage(
                priority: .quote,
                icon: "quote.bubble",
                title: focusDeed.arabicName,
                subtitle: localizedString(focusDeed.randomInsight, language: language)
            )

        } else {
            // No focus deeds — randomly pick between 3 general messages
            let randomDeed = WorshipType.allCases.randomElement()!
            let option = Int.random(in: 1...3)

            switch option {
            case 1:
                // Rhythm progress
                let rhythm = rhythmLast66Days
                let message = rhythm == 0
                    ? localizedString("mirror.journey.start", language: language)
                    : rhythm < 50
                    ? "\(rhythm)% \(localizedString("mirror.habit.building", language: language))"
                    : "\(rhythm)% \(localizedString("mirror.habit.progress", language: language))"
                return MirrorMessage(
                    priority: .quote,
                    icon: "chart.bar",
                    title: "مرآة",
                    subtitle: message
                )

            case 2:
                // Encourage picking focus deeds
                return MirrorMessage(
                    priority: .nudge,
                    icon: "scope",
                    title: "مرآة",
                    subtitle: localizedString("mirror.pick.focus", language: language)
                )

            default:
                // General Islamic quote
                return MirrorMessage(
                    priority: .quote,
                    icon: "quote.bubble",
                    title: randomDeed.arabicName,
                    subtitle: localizedString(randomDeed.randomInsight, language: language)
                )
            }
        }
    }
    // Helper — reuses your existing localizedString
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
}
