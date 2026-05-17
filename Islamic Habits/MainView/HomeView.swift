import SwiftUI
import SwiftData

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.modelContext) private var context
    @Query private var allLogs: [DeedLog]
    @AppStorage("dailyGoal") private var dailyGoal: Int = 1
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @AppStorage("hasSeenTierPopup") var hasSeenTierPopup: Bool = false
    @AppStorage("upgradeIconVisible") var upgradeIconVisible: Bool = false
    
    var dailyGoalMet: Bool {
        viewModel.totalDeedsToday >= dailyGoal
    }
    

    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
    var levelText: String {
                if selectedLanguage == "ar" {
                    return "\(localizedString("general.a_day", language: selectedLanguage)) \(dailyGoal > 1 ? localizedString("general.deeds", language: selectedLanguage) : localizedString("general.deed", language: selectedLanguage)) \(dailyGoal)  ·  \(localizedString("general.level", language: selectedLanguage)) \(dailyGoal)"
                } else {
                    return "\(localizedString("general.level", language: selectedLanguage)) \(dailyGoal)  ·  \(dailyGoal) \(dailyGoal > 1 ? localizedString("general.deeds", language: selectedLanguage) : localizedString("general.deed", language: selectedLanguage)) \(localizedString("general.a_day", language: selectedLanguage))"
                }
            }
            
            var formattedDate: String {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: selectedLanguage)
                formatter.dateFormat = "EEEE, d MMMM"
                return formatter.string(from: Date()).uppercased()
            }
          
            
                IslamicPattern()
                    .ignoresSafeArea()
            
      
            
            // Top header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedDate)
                            .font(.system(size: 11, weight: .medium))
                            .tracking(selectedLanguage == "ar" ? 0 : 2)
                            .foregroundColor(.white.opacity(0.5))
                            .textCase(.uppercase)

                        Text(greetingText)
                            .font(.system(size: 28, weight: .light))
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                            .environment(\.locale, Locale(identifier: selectedLanguage))
                       
                        Text(levelText)
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Spacer()

                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                Spacer()
            }
            .padding(.bottom, 100)
            .padding(.top, 20)
            

            
            // Orbs
            GeometryReader { geo in
                
                let baseSize = geo.size.width * 0.33

                let orbLayout: [(worship: WorshipType, x: CGFloat, y: CGFloat, multiplier: CGFloat)] = [
                    (.quran,   0.50, 0.25, 0.75),
                    (.dhikr,   0.15, 0.30, 0.60),
                    (.sunnah,  0.82, 0.32, 0.62),
                    (.duaa,    0.35, 0.44, 0.70),
                    (.sadaqah, 0.72, 0.49, 0.66),
                    (.qiyam,   0.20, 0.59, 0.57),
                    (.masjid,  0.58, 0.65, 0.74),
                    (.hadith,  0.88, 0.67, 0.53),
                    (.fasting, 0.35, 0.77, 0.59),
                ]
                ForEach(orbLayout, id: \.worship) { item in
                    let engine = viewModel.engine(for: item.worship)
                    
                    OrbView(
                        worship: item.worship,
                        size: baseSize * item.multiplier,
                        isLogged: engine.loggedToday,
                        isActive: item.worship.isActive,
                        selectedLanguage: selectedLanguage
                    ) {
                        viewModel.log(worshipType: item.worship, context: context)
                    }
                    .position(
                        x: geo.size.width * item.x,
                        y: geo.size.height * item.y
                    )
                    .id("\(item.worship.rawValue)-\(viewModel.totalDeedsToday)")
                }
            }
            
            // Bottom counter
            VStack {
                Spacer()
                HabitProgressBar(
                    progress: Double(viewModel.globalRhythm) / 70.0,
                    deedsToday: viewModel.totalDeedsToday,
                    selectedLanguage: selectedLanguage,
                    canUndo: viewModel.canUndo,
                    onUndo: { viewModel.undoLastLog(context: context) }
                )
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            viewModel.allLogs = allLogs
        }
        .onChange(of: allLogs) { _, new in
            guard !viewModel.isResetting else {
                viewModel.isResetting = false
                return
            }
            viewModel.allLogs = new
        }

        .onChange(of: viewModel.isReadyForNextCommitment) { _, isReady in
            if isReady && !hasSeenTierPopup {
                hasSeenTierPopup = true
                upgradeIconVisible = true
            }
        }
        .environment(\.layoutDirection, AppLanguage(rawValue: selectedLanguage)?.layoutDirection ?? .leftToRight)
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
}


struct OrbView: View {
    let worship: WorshipType
    let size: CGFloat
    let isLogged: Bool
    let isActive: Bool
    let selectedLanguage: String
    let onTap: () -> Void
    
    @State private var isPulsing = false
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.85, green: 0.72, blue: 0.52).opacity(
                                isLogged ? 0.35 : (isActive ? 0.28 : 0.08)
                            ),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.9
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .scaleEffect(isLogged && isPulsing ? 1.06 : 1.0)
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
            // Main orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.90, green: 0.78, blue: 0.58),
                            Color(red: 0.65, green: 0.52, blue: 0.35),
                            Color(red: 0.40, green: 0.30, blue: 0.18)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size, height: size)
                .opacity(isLogged ? 0.45 : (isActive ? 1.0 : 0.5))
                .scaleEffect(isPressed ? 1.08 : 1.0)
            
            // Text
            VStack(spacing: 2) {
                Text(LocalizedStringKey(worship.nameKey))
                    .environment(\.locale, Locale(identifier: selectedLanguage))
                    .font(.system(size: size * 0.18))
                    .foregroundColor(.white.opacity(0.95))
                
            }
            .scaleEffect(isPressed ? 1.05 : 1.0)
            // Count badge
            if isLogged {
                Text("1")
                    .font(.system(size: size * 0.13, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: size * 0.28, height: size * 0.28)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
                    .offset(x: size * 0.32, y: -(size * 0.32))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            guard isActive else { return }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            onTap()
        }
    }
}

//#Preview {
//    let container = try! ModelContainer(
//        for: DeedLog.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    return HomeView()
//        .modelContainer(container)
//}
