import Foundation
import SwiftData

@Model
class GlobalRhythmState {
    var currentLevel: Int
    
    init(currentLevel: DeedLevel) {
        self.currentLevel = currentLevel.rawValue
    }
}

func ensureGlobalRhythmStateExists(states: [GlobalRhythmState], context: ModelContext) {
    guard states.isEmpty else { return }
    let newState = GlobalRhythmState(currentLevel: .niyyah)
    context.insert(newState)
}
