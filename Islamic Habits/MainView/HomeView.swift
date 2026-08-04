
import SwiftUI
import SwiftData
import StoreKit


struct HomeView: View {
    
    private let viewModel = HomeViewModel()
    @Environment(\.modelContext) private var context
    @Query private var allLogs: [DeedLog]
    @Query private var rhythmStates: [GlobalRhythmState]
    @AppStorage("dailyGoal") private var dailyGoal: Int = 1
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @Environment(\.requestReview) var requestReview
    @AppStorage("focusDeeds") var focusDeedsRaw: String = ""
    @AppStorage("smartNotifications") var smartNotificationsEnabled: Bool = true
    @AppStorage("lastRhythmAlertDate") var lastRhythmAlertDate: String = ""
    @State private var postLogWorship: WorshipType? = nil
    @State private var postLogInsight: String = ""
    @State private var postLogCount66: Int = 0
    @State private var showLevelUp = false
    @State private var newlyReachedLevel: DeedLevel = .niyyah
    @State private var showQuranSheet = false
    @State private var showRhythmAlert = false
    @State private var showToast = false
    @State private var toastMessage: MirrorMessage? = nil
    @State private var showRhythmAlertIsLevelDrop: Bool = false
    @State private var showLevelInfo = false
    
    
    var engine: DeedEngine {
        viewModel.engine(logs: allLogs, dailyGoal: dailyGoal)
    }
    
    var levelText: String {
        let result = engine.computedLevelAndDays()
        let levelName = result.level.localizedName(language: selectedLanguage)
        let days = engine.localizedDayCount(result.days, language: selectedLanguage)
        return "\(levelName)  ·  \(days)"
    }
    
    var palmImageName: String {
        let level = engine.computedCurrentLevel()
        switch level {
        case .niyyah:    return "palm_tree_level1"
        case .muraqabah: return "palm_tree_level2"
        case .istiqamah: return "palm_tree_level3"
        case .aadah:     return "palm_tree_level4"
        case .tabiah:    return "palm_tree_level5"
        }
    }
    
    var focusDeeds: [WorshipType] {
        focusDeedsRaw
            .split(separator: ",")
            .compactMap { WorshipType(rawValue: String($0)) }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date()).uppercased()
    }
    
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let key: String
        switch hour {
        case 5..<12: key = "greeting.morning"
        case 12..<16: key = "greeting.afternoon"
        case 16..<21: key = "greeting.evening"
        default: key = "greeting.night"
        }
        return localizedString(key, language: selectedLanguage)
    }
    
    
    var hijriDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date()).uppercased()
    }
    

    
    func showPostLog(for worship: WorshipType, wasLoggedBefore: Bool) {
        guard !wasLoggedBefore else { return }
        postLogInsight = worship.randomInsight
        postLogCount66 = rhythmStates.first.map { engine.globalEffectiveStreak(state: $0) } ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            postLogWorship = worship
        }
    }
    
    func checkRhythmAlerts() {
        guard let state = rhythmStates.first else { return }
        guard let message = engine.mirrorMessage(state: state, language: selectedLanguage) else { return }

        switch message.priority {
        case .alert:
            if lastRhythmAlertDate != todayString() {
                lastRhythmAlertDate = todayString()
                showRhythmAlertIsLevelDrop = engine.globalShouldDropLevel(state: state)
                showRhythmAlert = true
            }
        case .progress:
            // once per session — show as toast
            toastMessage = message
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showToast = false
                }
            }
        case .levelUp:
            newlyReachedLevel = engine.computedCurrentLevel()
            showLevelUp = true
        default:
            break
        }
    }
    
    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()
            IslamicPattern().ignoresSafeArea()
            
            // Fixed header + landscape — pinned VStack overlay
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hijriDate)
                            .font(.system(size: 11, weight: .medium))
                            .tracking(selectedLanguage == "ar" ? 0 : 2)
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text(formattedDate)
                            .font(.system(size: 11, weight: .medium))
                            .tracking(selectedLanguage == "ar" ? 0 : 2)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(greetingText)
                            .font(.system(size: 28, weight: .light))
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                        
                        Button {
                            showLevelInfo = true
                        } label: {
                            Text(levelText)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.9))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.2), lineWidth: 0.5)
                                        )
                                )
                        }
                    }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 8) {
                                    if let rhythmState = rhythmStates.first,
                                       let message = engine.mirrorMessage(state: rhythmState, language: selectedLanguage) {
                                        MirrorBoxView(message: message).frame(width: 150)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 70)
                            
                            // Landscape lives here — fixed, not scrolling
                            Image("desert_landscape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width, height: 160)
                                .clipped()

                                .allowsHitTesting(false)
                                .overlay(
                                       LinearGradient(
                                           colors: [
                                               appBackground.opacity(0),
                                               appBackground
                                           ],
                                           startPoint: .top,
                                           endPoint: .bottom
                                       )
                                       .frame(height: 80),
                                       alignment: .bottom
                                   )
                                .overlay(
                                     // side vignette
                                     HStack(spacing: 0) {
                                         LinearGradient(
                                             colors: [appBackground, appBackground.opacity(0)],
                                             startPoint: .leading,
                                             endPoint: .trailing
                                         )
                                         .frame(width: 40)
                                         Spacer()
                                         LinearGradient(
                                             colors: [appBackground.opacity(0), appBackground],
                                             startPoint: .leading,
                                             endPoint: .trailing
                                         )
                                         .frame(width: 40)
                                     }
                                 )

                                .overlay(
                                    Image(palmImageName)
                                           .resizable()
                                           .scaledToFit()
                                           .frame(height: 160)
                                           .offset(y: -35),
                                       alignment: .bottom
                                   )
                                .environment(\.layoutDirection, .leftToRight)
                
                            Spacer()
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .bottom) {
                                LinearGradient(
                                    colors: [
                                        Color(appBackground).opacity(0),
                                        Color(appBackground)
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 140)
                                .allowsHitTesting(false)
                                ScrollView(showsIndicators: false) {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 12) {
                                        ForEach(WorshipType.allCases, id: \.self) { worship in
                                let isLogged = engine.loggedTodayByWorship[worship.rawValue] ?? false
                                let logCount = engine.todayCountByWorship[worship.rawValue] ?? 0
                                let isOverdue = engine.isOverdue(for: worship)
                                let wasLoggedBefore = isLogged
                                
                                WorshipCard(
                                    worship: worship,
                                    isLogged: isLogged,
                                    logCount: logCount,
                                    selectedLanguage: selectedLanguage,
                                    isOverdue: isOverdue,
                                    isFocused: focusDeeds.contains(worship)
                                ) {
                                    viewModel.log(worshipType: worship, context: context)
                                    if worship == .quran && focusDeeds.contains(.quran) {
                                        showQuranSheet = true
                                    } else {
                                        showPostLog(for: worship, wasLoggedBefore: wasLoggedBefore)
                                    }
                                }
                                        }
                                                        }
                                                        .padding(.horizontal, 16)
                                                        .padding(.bottom, 100)
                                                    }
                                                .padding(.top, 325)
                                                    
                                LinearGradient(
                                    colors: [appBackground.opacity(0), appBackground],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                                    .frame(height: 140)
                                                    .allowsHitTesting(false)
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                           
                            .padding(.bottom, geo.size.height * 0.22)                                            }
            
            // Progress bar — pinned
            VStack {
                Spacer()
                HabitProgressBar(
                    progress: rhythmStates.first.map {
                        engine.globalDecayedPercentage(state: $0) / 100
                    } ?? 0,
                    deedsToday: viewModel.totalDeedsToday(logs: allLogs),
                    selectedLanguage: selectedLanguage,
                    canUndo: viewModel.canUndo(logs: allLogs),
                    onUndo: {
                        viewModel.undoLastLog(logs: allLogs, context: context)
                    }
                )
                .padding(.bottom, 100)
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Toast — pinned
            if showToast, let toast = toastMessage {
                VStack {
                    Spacer()
                    RhythmToast(message: toast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 120)
                }
                .animation(.spring(response: 0.4), value: showToast)
                .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showLevelInfo) {
            LevelUpView(
                newLevel: engine.computedCurrentLevel(),
                selectedLanguage: selectedLanguage,
                onDismiss: { showLevelInfo = false }
            )
            .presentationDetents([.fraction(0.75)])
        }
        .sheet(isPresented: $showRhythmAlert) {
            if let state = rhythmStates.first {
                RhythmAlertSheet(
                    state: state,
                    isLevelDrop: showRhythmAlertIsLevelDrop,
                    selectedLanguage: selectedLanguage,
                    onDismiss: { showRhythmAlert = false }
                )
                .presentationDetents([.fraction(0.75)])
            }
        }
        .sheet(item: $postLogWorship) { worship in
            PostLogView(
                worship: worship,
                insightKey: postLogInsight,
                globalStreak: postLogCount66,
                totalToday: viewModel.totalDeedsToday(logs: allLogs),
                selectedLanguage: selectedLanguage,
                onDismiss: { postLogWorship = nil }
            )
            .presentationDetents([.fraction(0.75)])
        }
        .sheet(isPresented: $showLevelUp) {
            LevelUpView(
                newLevel: newlyReachedLevel,
                selectedLanguage: selectedLanguage,
                onDismiss: { showLevelUp = false }
            )
            .presentationDetents([.fraction(0.75)])
        }
        .sheet(isPresented: $showQuranSheet, onDismiss: {
            showPostLog(for: .quran, wasLoggedBefore: false)
        }) {
            QuranLogSheet(
                selectedLanguage: selectedLanguage,
                onSave: {}
            )
        }
        .onChange(of: allLogs.count) { _, _ in
            guard let state = rhythmStates.first else { return }
            let computed = engine.computedCurrentLevel()
            print("computed: \(computed.rawValue), stored: \(state.currentLevel)")
            
            if computed.rawValue > state.currentLevel {
                state.currentLevel = computed.rawValue
                newlyReachedLevel = computed
                showLevelUp = true
            } else if computed.rawValue < state.currentLevel {
                state.currentLevel = computed.rawValue
                showRhythmAlertIsLevelDrop = true
                showRhythmAlert = true
            }
        }
        .onAppear {
            ensureGlobalRhythmStateExists(states: rhythmStates, context: context)
            
            if let state = rhythmStates.first {
                let computed = engine.computedCurrentLevel()
                
                if computed.rawValue > state.currentLevel {
                    state.currentLevel = computed.rawValue
                    newlyReachedLevel = computed
                    showLevelUp = true
                } else if computed.rawValue < state.currentLevel {
                    state.currentLevel = computed.rawValue
                    if lastRhythmAlertDate != todayString() {
                        lastRhythmAlertDate = todayString()
                        showRhythmAlertIsLevelDrop = true
                        showRhythmAlert = true
                    }
                }
            }
            // ... rest of onAppear
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            NotificationManager.scheduleAll(
                engine: engine,
                focusDeeds: focusDeeds,
                smartNotificationsEnabled: smartNotificationsEnabled,
                language: selectedLanguage
            )
        }
        .environment(\.layoutDirection, AppLanguage(rawValue: selectedLanguage)?.layoutDirection ?? .leftToRight)
    }
    }
    
    
    
    struct WorshipCard: View {
        let worship: WorshipType
        let isLogged: Bool
        let logCount: Int
        let selectedLanguage: String
        let isOverdue: Bool
        let isFocused: Bool
        let onTap: () -> Void
        
        
        @State private var isPressed = false
        @State private var isPulsing = false
        
        var body: some View {
            Button {
                let haptic = UIImpactFeedbackGenerator(style: .medium)
                haptic.prepare()
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                }
                haptic.impactOccurred()
                onTap()
            } label: {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 6) {
                        Image(systemName: worship.icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.white.opacity(isLogged ? 0.5 : 0.7))
                        
                        Text(worship.arabicName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(isLogged ? 0.5 : 0.95))
                        
                        if selectedLanguage != "ar" {
                            Text(LocalizedStringKey(worship.nameKey))
                                .font(.system(size: 13, weight: .light))
                                .italic()
                                .foregroundColor(.white.opacity(isLogged ? 0.3 : 0.55))
                                .environment(\.locale, Locale(identifier: selectedLanguage))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                isLogged ?
                                Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.15) :
                                    Color.white.opacity(0.05)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        isLogged ?
                                        Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.4) :
                                            isFocused ?
                                        Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.5) :
                                            isOverdue ?
                                        Color(red: 0.85, green: 0.72, blue: 0.52).opacity(isPulsing ? 0.4 : 0.15) :
                                            Color.white.opacity(0.08),
                                        lineWidth: isFocused ? 1.5 : isOverdue ? 1.0 : 0.5
                                    )
                            )
                        
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(
                        color: isLogged ?
                        Color(red: 0.85, green: 0.72, blue: 0.52).opacity(isPulsing ? 0.3 : 0.1) :
                            Color.clear,
                        radius: isPulsing ? 12 : 6
                    )
                    
                    if isLogged && logCount > 0 {
                        Text("\(logCount)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 18, height: 18)
                            .background(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.8))
                            .clipShape(Circle())
                            .offset(x: -4, y: 4)
                    }
                    
                }
            }
            .onAppear {
                guard isLogged else { return }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .onChange(of: isLogged) { _, logged in
                if logged {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                } else {
                    isPulsing = false
                }
            }
        }
    }
    
    
