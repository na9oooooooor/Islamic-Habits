
import SwiftUI
import SwiftData
import StoreKit
import Combine

struct HomeView: View {
    var isActive: Bool = true
    @Environment(\.scenePhase) private var scenePhase

    @State private var visibleTrackingDay = startOfTrackingDay

    private let trackingDayTimer = Timer.publish(
        every: 30,
        on: .main,
        in: .common
    ).autoconnect()

    private func refreshTrackingDay() {
        let currentDay = startOfTrackingDay

        if currentDay != visibleTrackingDay {
            visibleTrackingDay = currentDay
        }
    }
    
    @State private var pendingLevelCheck = false
    private let viewModel = HomeViewModel()
    @Environment(\.modelContext) private var context
    @Query private var allLogs: [DeedLog]
    @Query private var rhythmStates: [GlobalRhythmState]
    @Query private var quranLogs: [QuranLog]
    @AppStorage("dailyGoal") private var dailyGoal: Int = 1
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @Environment(\.requestReview) var requestReview
    @AppStorage("focusDeeds") var focusDeedsRaw: String = ""
    @AppStorage("smartNotifications")
    private var smartNotificationsEnabled:
        Bool = false
    @AppStorage("lastRhythmAlertDate") var lastRhythmAlertDate: String = ""
    @State private var logConfirmationID = UUID()
    @State private var showLevelUp = false
    @State private var newlyReachedLevel: DeedLevel = .niyyah
    @State private var showDeedSaveError = false
    @State private var showQuranSheet = false
    @State private var showRhythmAlert = false
    @State private var showToast = false
    @State private var toastMessage: MirrorMessage? = nil
    @State private var showRhythmAlertIsLevelDrop: Bool = false
    @State private var showLevelInfo = false
    @State private var quranWasSaved = false
    @State private var quranWasLoggedBefore = false
    
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
    

    
    func showPostLog(
        for worship: WorshipType,
        wasLoggedBefore _: Bool
    ) {
        let confirmationID = UUID()
        logConfirmationID = confirmationID

        let title: String

        switch selectedLanguage {
        case "ar":
            title = "تم تسجيل العمل"
        case "th":
            title = "บันทึกความดีแล้ว"
        default:
            title = "Deed recorded"
        }

        toastMessage = MirrorMessage(
            priority: .progress,
            icon: "checkmark.circle.fill",
            title: title,
            subtitle: worship.localizedName(
                language: selectedLanguage
            )
        )

        withAnimation(.easeInOut(duration: 0.2)) {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard logConfirmationID == confirmationID else {
                return
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                showToast = false
            }
        }
    }
    
    private func checkForLevelChange() {
        pendingLevelCheck = true
        presentPendingLevelChange()
    }

    private func presentPendingLevelChange() {
        guard pendingLevelCheck,
              isActive,
              !showQuranSheet,
              !showLevelInfo,
              !showLevelUp,
              !showRhythmAlert,
              let state = rhythmStates.first else {
            return
        }

        pendingLevelCheck = false

        let computed = engine.computedCurrentLevel()
        let previousLevel = state.currentLevel

        guard computed.rawValue != previousLevel else {
            return
        }

        state.currentLevel = computed.rawValue

        if computed.rawValue > previousLevel {
            newlyReachedLevel = computed
            showLevelUp = true
        } else if lastRhythmAlertDate != todayString() {
            lastRhythmAlertDate = todayString()
            showRhythmAlertIsLevelDrop = true
            showRhythmAlert = true
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

                                                if worship == .quran && focusDeeds.contains(.quran) {
                                                    quranWasLoggedBefore = wasLoggedBefore
                                                    showQuranSheet = true
                                                } else {
                                                    guard viewModel.log(
                                                        worshipType: worship,
                                                        context: context
                                                    ) else {
                                                        showDeedSaveError = true
                                                        return
                                                    }

                                                    showPostLog(
                                                        for: worship,
                                                        wasLoggedBefore: wasLoggedBefore
                                                    )
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
                    progress: min(
                        max(
                            Double(engine.computedLevelAndDays().days) / 66.0,
                            0.0
                        ),
                        1.0
                    ),
                    deedsToday: viewModel.totalDeedsToday(logs: allLogs),
                    selectedLanguage: selectedLanguage,
                    canUndo: viewModel.canUndo(logs: allLogs),
                    onUndo: {
                        let didUndo = viewModel.undoLastLog(
                            logs: allLogs,
                            quranLogs: quranLogs,
                            context: context
                        )

                        if didUndo {
                            logConfirmationID = UUID()
                            showToast = false
                        } else {
                            showDeedSaveError = true
                        }
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
        .alert(
            selectedLanguage == "ar"
                ? "تعذّر الحفظ"
                : selectedLanguage == "th"
                    ? "บันทึกไม่สำเร็จ"
                    : "Couldn’t save",
            isPresented: $showDeedSaveError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                selectedLanguage == "ar"
                    ? "تعذّر حفظ التغيير. حاول مجددًا."
                    : selectedLanguage == "th"
                        ? "บันทึกการเปลี่ยนแปลงไม่สำเร็จ กรุณาลองอีกครั้ง"
                        : "Your change couldn’t be saved. Please try again."
            )
        }
        .onDisappear {
            logConfirmationID = UUID()
            showToast = false
        }
        .sheet(
            isPresented: $showLevelInfo,
            onDismiss: presentPendingLevelChange
        ) {
            LevelUpView(
                newLevel: engine.computedCurrentLevel(),
                selectedLanguage: selectedLanguage,
                onDismiss: { showLevelInfo = false }
            )
            .presentationDetents([.fraction(0.75)])
        }
        .sheet(
            isPresented: $showRhythmAlert,
            onDismiss: presentPendingLevelChange
        ) {
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
        .sheet(
            isPresented: $showLevelUp,
            onDismiss: presentPendingLevelChange
        ) {
            LevelUpView(
                newLevel: newlyReachedLevel,
                selectedLanguage: selectedLanguage,
                onDismiss: { showLevelUp = false }
            )
            .presentationDetents([.fraction(0.75)])
        }
        .sheet(
            isPresented: $showQuranSheet,
            onDismiss: {
                if quranWasSaved {
                    showPostLog(
                        for: .quran,
                        wasLoggedBefore: quranWasLoggedBefore
                    )
                }

                quranWasSaved = false
                quranWasLoggedBefore = false

                presentPendingLevelChange()
            }
        ) {
            QuranLogSheet(
                selectedLanguage: selectedLanguage,
                onSave: {
                    quranWasSaved = true
                }
            )
        }
        .onReceive(trackingDayTimer) { _ in
            guard scenePhase == .active else { return }
            refreshTrackingDay()
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                refreshTrackingDay()
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.significantTimeChangeNotification
            )
        ) { _ in
            refreshTrackingDay()
        }
        .onChange(of: visibleTrackingDay) { _, _ in
            checkForLevelChange()
        }
        .onChange(of: allLogs.count) { _, _ in
            checkForLevelChange()
        }
        .onChange(of: rhythmStates.count) { _, _ in
            checkForLevelChange()
        }
        .onChange(of: isActive) { _, active in
            if active {
                checkForLevelChange()
            }
        }
        .onAppear {
            ensureGlobalRhythmStateExists(
                states: rhythmStates,
                context: context
            )

            checkForLevelChange()
        }

        .environment(\.layoutDirection, AppLanguage(rawValue: selectedLanguage)?.layoutDirection ?? .leftToRight)
    }
    func maybeRequestReview() {

        guard engine.totalActiveDays >= 7 else {
            return
        }

        guard AppReviewManager.shouldRequestReview()
        else {
            return
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.5
        ) {
            requestReview()
        }
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
    
    
