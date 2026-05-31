//
//  StreakStatus.swift
//  Islamic Habits
//
//  Created by NASER ALALI on 01/06/2026.
//

import Foundation

enum StreakStatus {
    case healthy
    case warning(remaining: Int)
    case broken
    
    var isHealthy: Bool {
        if case .healthy = self { return true }
        return false
    }
    
    var isBroken: Bool {
        if case .broken = self { return true }
        return false
    }
    
    var remainingGraceDays: Int? {
        if case .warning(let remaining) = self { return remaining }
        return nil
    }
}
