import SwiftUI
import SwiftData
import UserNotifications

@main
struct Islamic_HabitsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasTrackedForegroundOpen = false

    init() {
        MirrorAnalytics.configure()
    }
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
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if !hasSeenFocusOnboarding {
                    FocusOnboardingView()
                } else {
                    MainTabView()
                }
            }
            .modifier(ReminderLifecycleModifier())
            .onChange(of: scenePhase, initial: true) { _, phase in
                if phase == .active && !hasTrackedForegroundOpen {
                    hasTrackedForegroundOpen = true
                    MirrorAnalytics.appOpened()
                } else if phase == .background {
                    hasTrackedForegroundOpen = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    private struct ReminderLifecycleModifier: ViewModifier {
        @Environment(\.scenePhase) private var scenePhase

        @Query(sort: \DeedLog.loggedAt)
        private var logs: [DeedLog]

        @AppStorage("smartNotifications")
        private var remindersEnabled = false

        @AppStorage("focusDeeds")
        private var focusDeedsRaw = ""

        @AppStorage("dailyGoal")
        private var dailyGoal = 1

        @AppStorage("selectedLanguage")
        private var language = "en"

        private var logSignature: [String] {
            logs.map {
                "\($0.worshipType)|\($0.loggedAt.timeIntervalSince1970)"
            }
        }

        func body(content: Content) -> some View {
            content
                .onAppear {
                    refreshPermissionAndSchedule()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        refreshPermissionAndSchedule()
                    } else if phase == .background {
                        schedule()
                    }
                }
                .onChange(of: logSignature) { _, _ in
                    schedule()
                }
                .onChange(of: remindersEnabled) { _, _ in
                    schedule()
                }
                .onChange(of: focusDeedsRaw) { _, _ in
                    schedule()
                }
                .onChange(of: dailyGoal) { _, _ in
                    schedule()
                }
                .onChange(of: language) { _, _ in
                    schedule()
                }
        }

        private func schedule() {
            let focusDeeds = focusDeedsRaw
                .split(separator: ",")
                .compactMap {
                    WorshipType(rawValue: String($0))
                }

            NotificationManager.scheduleAll(
                engine: DeedEngine(
                    logs: logs,
                    dailyGoal: dailyGoal
                ),
                focusDeeds: focusDeeds,
                smartNotificationsEnabled: remindersEnabled,
                language: language
            )
        }

        private func refreshPermissionAndSchedule() {
            UNUserNotificationCenter.current()
                .getNotificationSettings { settings in
                    let denied =
                        settings.authorizationStatus == .denied

                    Task { @MainActor in
                        if denied {
                            remindersEnabled = false
                            NotificationManager.cancelAll()
                        } else {
                            schedule()
                        }
                    }
                }
        }
    }
}

