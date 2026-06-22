import SwiftUI
import SwiftData

@main
struct Islamic_HabitsApp: App {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSeenFocusOnboarding") var hasSeenFocusOnboarding: Bool = false

    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DeedLog.self, QuranLog.self, GlobalRhythmState.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if !hasSeenFocusOnboarding {
                FocusOnboardingView()
            } else {
                MainTabView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

