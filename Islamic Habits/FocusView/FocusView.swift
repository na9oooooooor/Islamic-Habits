import SwiftUI
import SwiftData

struct FocusView: View {
    @AppStorage("focusDeeds") var focusDeedsRaw: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @AppStorage("dailyGoal") var dailyGoal: Int = 1
    @Query var allLogs: [DeedLog]
    @Query var quranLogs: [QuranLog]

    @State private var showPicker = false
    @State private var currentPage = 0

    private let gold = Color("#D9B883")
    private let background = Color("#1F1712")

    var focusDeeds: [WorshipType] {
        focusDeedsRaw
            .split(separator: ",")
            .compactMap { WorshipType(rawValue: String($0)) }
    }

    var engine: DeedEngine {
        DeedEngine(logs: allLogs, dailyGoal: dailyGoal)
    }

    var quranEngine: QuranEngine {
        QuranEngine(logs: quranLogs)
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            if focusDeeds.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {

                    // Top bar
                    HStack {
                        Text("\(localizedString("focus.on", language: selectedLanguage)) \(focusDeeds[currentPage].localizedName(language: selectedLanguage))")
                            .font(.system(size: 20, weight: .light))
                            .italic()
                            .foregroundColor(gold)
                            .animation(.easeInOut, value: currentPage)

                        Spacer()

                        Button {
                            showPicker = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 20))
                                .foregroundColor(gold.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 12)


                    // Level progression + swipeable card side by side
                    TabView(selection: $currentPage) {
                        ForEach(Array(focusDeeds.enumerated()), id: \.offset) { index, worship in
                            VStack(spacing: 0) {
                                // Dots inside each page, at the top
                                if focusDeeds.count > 1 {
                                    HStack(spacing: 6) {
                                        ForEach(0..<focusDeeds.count, id: \.self) { i in
                                            Circle()
                                                .fill(currentPage == i ? gold : gold.opacity(0.25))
                                                .frame(width: 5, height: 5)
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }

                                HStack(alignment: .top, spacing: 0) {
                                    levelProgressionBar(for: worship)
                                        .frame(width: 88)

                                    ScrollView(showsIndicators: false) {
                                        VStack(spacing: 10) {
                                            let streak = engine.streak(for: worship)
                                            let level = engine.effectiveLevel(for: worship)

                                            if worship == .quran {
                                                QuranFocusCard(
                                                    engine: quranEngine,
                                                    level: level,
                                                    streak: streak,
                                                    selectedLanguage: selectedLanguage
                                                )
                                                .padding(.trailing, 16)
                                            } else {
                                                let status = engine.streakStatus(for: worship)
                                                let progress = level.progress(streak: streak)
                                                let loggedDays = engine.last66DaysLogged(for: worship)

                                                FocusDeedProgressCard(
                                                    worship: worship,
                                                    streak: streak,
                                                    level: level,
                                                    status: status,
                                                    progress: progress,
                                                    selectedLanguage: selectedLanguage,
                                                    loggedDays: loggedDays
                                                )
                                                .padding(.trailing, 16)
                                            }
                                        }
                                        .padding(.bottom, 40)
                                    }
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)                }
            }
        }
        .onAppear {
            print("QuranLogs count: \(quranLogs.count)")
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showPicker) {
            FocusDeedPickerView(
                onContinue: { showPicker = false },
                onSkip: { showPicker = false }
            )
        }
    }

    // MARK: - Level Progression Bar
    func levelProgressionBar(for worship: WorshipType) -> some View {
        let currentLevel = engine.effectiveLevel(for: worship)
        let levels = DeedLevel.allCases

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                let isActive = level.rawValue == currentLevel.rawValue
                let isPast = level.rawValue < currentLevel.rawValue

                HStack(spacing: 8) {
                    // Timeline dot + line
                    VStack(spacing: 0) {
                        if index > 0 {
                            Rectangle()
                                .fill(isPast || isActive ? gold.opacity(0.4) : gold.opacity(0.1))
                                .frame(width: 1, height: 10)
                        } else {
                            Spacer().frame(height: 10)
                        }

                        Circle()
                            .fill(isActive ? gold : (isPast ? gold.opacity(0.45) : Color.clear))
                            .frame(width: 7, height: 7)
                            .overlay(
                                Circle().stroke(
                                    isActive ? gold : (isPast ? gold.opacity(0.45) : gold.opacity(0.2)),
                                    lineWidth: 1
                                )
                            )

                        if index < levels.count - 1 {
                            Rectangle()
                                .fill(isPast ? gold.opacity(0.4) : gold.opacity(0.1))
                                .frame(width: 1, height: 10)
                        } else {
                            Spacer().frame(height: 10)
                        }
                    }
                    .frame(width: 12)

                    // Label
                    VStack(alignment: .leading, spacing: 1) {
                        Text(level.arabicName)
                            .font(.system(size: isActive ? 12 : 10, weight: isActive ? .semibold : .regular))
                            .foregroundColor(
                                isActive ? gold :
                                isPast   ? gold.opacity(0.45) :
                                           gold.opacity(0.18)
                            )
                    }
                }
            }
        }
        .padding(.leading, 20)
        .padding(.top, 4)
        .animation(.easeInOut, value: currentLevel)
    }

    // MARK: - Empty State
    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "scope")
                .font(.system(size: 48))
                .foregroundColor(gold.opacity(0.4))

            Text(localizedString("focus.view.empty.title", language: selectedLanguage))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(gold)

            Text(localizedString("focus.view.empty.subtitle", language: selectedLanguage))
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Button {
                showPicker = true
            } label: {
                Text(localizedString("focus.view.empty.button", language: selectedLanguage))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(background)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(gold))
            }
        }
    }
}

#Preview {
    FocusView()
        .modelContainer(for: [DeedLog.self, QuranLog.self])
}
