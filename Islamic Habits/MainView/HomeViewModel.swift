//
//  MainTabViewModel.swift
//  Islamic Habits
//
//  Created by NASER ALALI on 16/05/2026.
//


import Foundation
import SwiftData
import SwiftUI
internal import Combine

class HomeViewModel: ObservableObject {
    
    @Published var allLogs: [DeedLog] = []
    var isResetting = false

    var globalEngine: DeedEngine {
        DeedEngine(logs: allLogs, worshipType: .quran)
    }
    
    var totalDeedsToday: Int {
        let startOfDay = startOfIslamicDay
        let startOfTomorrow = startOfIslamicTomorrow
        return allLogs.filter { $0.loggedAt >= startOfDay && $0.loggedAt < startOfTomorrow }.count
    }

    var isReadyForNextCommitment: Bool {
        globalEngine.readyForNextCommitment
    }

    var globalRhythm: Int {
        globalEngine.rhythmLast66Days
    }
    
    
    
    func engine(for worshipType: WorshipType) -> DeedEngine {
        let worshipLogs = allLogs.filter { $0.worshipType == worshipType.rawValue }
        return DeedEngine(logs: worshipLogs, worshipType: worshipType)
    }
    
    func log(worshipType: WorshipType, context: ModelContext) {
        let engine = engine(for: worshipType)
        guard !engine.loggedToday else { return }
        let newLog = DeedLog(worshipType: worshipType)
        context.insert(newLog)
        allLogs.append(newLog)
    }
    
    func undoLastLog(context: ModelContext) {
        let startOfDay = startOfIslamicDay
        let startOfTomorrow = startOfIslamicTomorrow
        
        let todayLogs = allLogs.filter { log in
            log.loggedAt >= startOfDay && log.loggedAt < startOfTomorrow
        }
        
        let sorted = todayLogs.sorted { $0.loggedAt > $1.loggedAt }
        
        guard let latest = sorted.first else { return }
        
        context.delete(latest)
        allLogs.removeAll { $0.id == latest.id }
    }
    
    var canUndo: Bool {
        let startOfDay = startOfIslamicDay
        let startOfTomorrow = startOfIslamicTomorrow
        return allLogs.contains { $0.loggedAt >= startOfDay && $0.loggedAt < startOfTomorrow }
    }
    
   }
    

