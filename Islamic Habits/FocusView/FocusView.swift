//
//  FocusView.swift
//  Islamic Habits
//
//  Created by NASER ALALI on 01/06/2026.
//


import SwiftUI
import SwiftData


struct FocusView: View {
    @AppStorage("focusDeeds") var focusDeedsRaw: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @AppStorage("dailyGoal") var dailyGoal: Int = 1
    @Query var allLogs: [DeedLog]

    @State private var showPicker = false

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

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()
            if focusDeeds.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "scope")
                        .font(.system(size: 48))
                        .foregroundColor(gold.opacity(0.4))

                    Text(localizedString("focus.view.empty.subtitle", language: selectedLanguage))
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
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(gold)
                            )
                    }
                }

            } else {
                ScrollView {
                    VStack(spacing: 16) {

                        // Header
                        HStack {
                            Text(localizedString("focus.view.title", language: selectedLanguage))
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(gold)

                            Spacer()

                            // Edit button — open picker to change
                            Button {
                                showPicker = true
                            } label: {
                                Image(systemName: "pencil.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(gold.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)

                        // Focus deed cards
                        ForEach(focusDeeds, id: \.self) { worship in
                            let streak = engine.streak(for: worship)
                            let level = engine.effectiveLevel(for: worship)
                            let status = engine.streakStatus(for: worship)
                            let progress = level.progress(streak: streak)
                            let loggedDays = engine.last66DaysLogged(for: worship)  // new

                            FocusDeedProgressCard(
                                worship: worship,
                                streak: streak,
                                level: level,
                                status: status,
                                progress: progress,
                                selectedLanguage: selectedLanguage,
                                loggedDays: loggedDays                              // new
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showPicker) {
            FocusDeedPickerView(
                onContinue: { showPicker = false },
                onSkip: { showPicker = false }
            )
        }
    }
}
#Preview {
    FocusView()
        .modelContainer(for: [DeedLog.self, QuranLog.self])
}
