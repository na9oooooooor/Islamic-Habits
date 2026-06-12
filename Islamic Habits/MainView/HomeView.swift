
import SwiftUI
import SwiftData
import StoreKit


struct HomeView: View {
    
    private let viewModel = HomeViewModel()
    @Environment(\.modelContext) private var context
    @Query private var allLogs: [DeedLog]
    @AppStorage("dailyGoal") private var dailyGoal: Int = 1
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @AppStorage("hasSeenTierPopup") var hasSeenTierPopup: Bool = false
    @AppStorage("upgradeIconVisible") var upgradeIconVisible: Bool = false
    @Environment(\.requestReview) var requestReview
    @AppStorage("focusDeeds") var focusDeedsRaw: String = ""
    @AppStorage("smartNotifications") var smartNotificationsEnabled: Bool = true
    @AppStorage("lastMilestoneDate") var lastMilestoneDateString: String = ""
    @State private var showDailyMilestone = false
    @State private var pendingPostLogWorship: WorshipType? = nil
    @State private var selectedSurahFrom: Surah = QuranData.surahs[0]
    @State private var selectedAyahFrom: Int = 1
    @State private var selectedSurahTo: Surah = QuranData.surahs[0]
    @State private var selectedAyahTo: Int = 1
    @State private var postLogWorship: WorshipType? = nil
    @State private var postLogInsight: String = ""
    @State private var postLogCount66: Int = 0
    @State private var showLanguagePicker = false
    @State private var showUpgradePopup: Bool = false
    @State private var showQuranSheet = false
    
    
    var engine: DeedEngine {
        viewModel.engine(logs: allLogs, dailyGoal: dailyGoal)
    }
    
    var levelText: String {
        if selectedLanguage == "ar" {
            return "\(localizedString("general.a_day", language: selectedLanguage)) \(dailyGoal > 1 ? localizedString("general.deeds", language: selectedLanguage) : localizedString("general.deed", language: selectedLanguage)) \(dailyGoal)  ·  \(localizedString("general.level", language: selectedLanguage)) \(dailyGoal)"
        } else {
            return "\(localizedString("general.level", language: selectedLanguage)) \(dailyGoal)  ·  \(dailyGoal) \(dailyGoal > 1 ? localizedString("general.deeds", language: selectedLanguage) : localizedString("general.deed", language: selectedLanguage)) \(localizedString("general.a_day", language: selectedLanguage))"
        }
    }
    
    
    
    var shownMilestoneToday: Bool {
        lastMilestoneDateString == todayString()
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
    
    var dailyGoalMet: Bool {
        viewModel.totalDeedsToday(logs: allLogs) >= dailyGoal
    }
    
    var hijriDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date()).uppercased()
    }
    
    var ayahsRead: Int {
        engine.calculateAyahsRead(
            surahFromNumber: selectedSurahFrom.number,
            ayahFrom: selectedAyahFrom,
            surahToNumber: selectedSurahTo.number,
            ayahTo: selectedAyahTo
        )
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            IslamicPattern()
                .ignoresSafeArea()
            
            // Top header
            VStack(alignment: .leading, spacing: 4) {
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
                            .textCase(.uppercase)
                        
                        Text(greetingText)
                            .font(.system(size: 28, weight: .light))
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                        
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
                    
                    Spacer()
                    
                    // Right column — upgrade icon + mirror box stacked
                    VStack(alignment: .trailing, spacing: 8) {
                        if upgradeIconVisible {
                            Button {
                                showUpgradePopup = true
                            } label: {
                                Image(systemName: "arrow.up.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.8))
                            }
                        }
                        
                        if let message = engine
                            .mirrorMessage(focusDeeds: focusDeeds, language: selectedLanguage) {
                            MirrorBoxView(message: message)
                                .frame(width: 150)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 70)
                Spacer()
            }
            .padding(.bottom, 100)
            .padding(.top, 20)
            
            // Worship grid
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
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
                                let wasLoggedBefore = isLogged  // capture before tap
                                
                                WorshipCard(
                                    worship: worship,
                                    isLogged: isLogged,
                                    logCount: logCount,
                                    selectedLanguage: selectedLanguage,
                                    isOverdue: isOverdue,
                                    isFocused: focusDeeds.contains(worship)  // new
                                ) {
                                    viewModel.log(worshipType: worship, context: context)

                                    if worship == .quran && focusDeeds.contains(.quran) {
                                        showQuranSheet = true
                                    }
                                        if !wasLoggedBefore {
                                            let freshEngine = engine
                                            postLogInsight = worship.randomInsight
                                            postLogCount66 = freshEngine.countLast66Days(for: worship)

                                            // wait for SwiftData to update allLogs
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                let totalToday = viewModel.totalDeedsToday(logs: allLogs)
                                                if totalToday == dailyGoal && !shownMilestoneToday {
                                                    lastMilestoneDateString = todayString()
                                                    pendingPostLogWorship = worship
                                                    showDailyMilestone = true
                                                } else {
                                                    postLogWorship = worship
                                                }
                                            }
                                        }
                                    
                                    
                                    
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                    .padding(.top, geo.size.height * 0.25)
                    
                    // Fade overlay
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.09, blue: 0.07).opacity(0),
                            Color(red: 0.12, green: 0.09, blue: 0.07)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, geo.size.height * 0.18)
            }
            // Progress bar
            VStack {
                Spacer()
                HabitProgressBar(
                    progress: Double(viewModel.globalRhythm(logs: allLogs, dailyGoal: dailyGoal)) / 100,
                    deedsToday: viewModel.totalDeedsToday(logs: allLogs),
                    selectedLanguage: selectedLanguage,
                    canUndo: viewModel.canUndo(logs: allLogs),
                    onUndo: {
                        viewModel.undoLastLog(logs: allLogs, context: context)
                        // if total drops below goal, allow milestone to show again
                        let totalAfterUndo = viewModel.totalDeedsToday(logs: allLogs) - 1
                        if totalAfterUndo < dailyGoal {
                            lastMilestoneDateString = ""
                        }
                    }
                )
                .padding(.bottom, 100)
            }            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
        }
        
        .sheet(isPresented: $showDailyMilestone, onDismiss: {
            if let pending = pendingPostLogWorship {
                postLogWorship = pending
                pendingPostLogWorship = nil
            }
        }) {
            DailyMilestoneView(
                dailyGoal: dailyGoal,
                selectedLanguage: selectedLanguage,
                rhythmPercent: viewModel.globalRhythm(logs: allLogs, dailyGoal: dailyGoal),  // add
                onDismiss: { showDailyMilestone = false }
            )
            .presentationDetents([.fraction(0.75)])
        }
        .onAppear {
            NotificationManager.requestPermission()
            NotificationManager.cancelToday()
            let has3Logs = engine.has3Logs
            if has3Logs && AppReviewManager.shouldRequestReview() {
                requestReview()
            }
        
           
            NotificationManager.scheduleAll(
                engine: engine,
                focusDeeds: focusDeeds,
                smartNotificationsEnabled: smartNotificationsEnabled,
                language: selectedLanguage 
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            
            NotificationManager.scheduleAll(
                engine: engine,
                focusDeeds: focusDeeds,
                smartNotificationsEnabled: smartNotificationsEnabled,
                language: selectedLanguage 
            )
        }
        .sheet(item: $postLogWorship) { worship in
            PostLogView(
                worship: worship,
                insightKey: postLogInsight,
                countLast66: postLogCount66,
                totalToday: viewModel.totalDeedsToday(logs: allLogs),
                selectedLanguage: selectedLanguage,
                onDismiss: { postLogWorship = nil }
            )
            .presentationDetents([.fraction(0.75)])
        }
        .sheet(isPresented: $showUpgradePopup) {
            CommitmentUpgradeView()
                .presentationDetents([.fraction(0.75)])
        }
        .onChange(of: viewModel.isReadyForNextCommitment(logs: allLogs, dailyGoal: dailyGoal)) { _, isReady in
            if isReady && !hasSeenTierPopup {
                hasSeenTierPopup = true
                upgradeIconVisible = true
                showUpgradePopup = true
            }
        }
        .sheet(isPresented: $showQuranSheet) {
            QuranLogSheet(
                selectedLanguage: selectedLanguage,
                onSave: {
                }
            )
            .presentationDetents([.fraction(0.75)])
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
        let isFocused: Bool  // add this
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
    
    
