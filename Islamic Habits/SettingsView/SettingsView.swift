import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @AppStorage("dailyGoal") private var dailyGoal: Int = 1
    @AppStorage("hasSeenTierPopup") private var hasSeenTierPopup: Bool = false
    @AppStorage("upgradeIconVisible") private var upgradeIconVisible: Bool = false
    @AppStorage("smartNotifications") private var smartNotificationsEnabled: Bool = false
    @State private var resetDataIsOn = false
    @State private var showLanguagePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.12, green: 0.09, blue: 0.07)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 32) {
                    
                    Text(localizedString("Settings", language: selectedLanguage))
                        .font(.system(size: 28, weight: .light))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 60)
                        .padding(.horizontal, 24)
                    
                    // Language
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LANGUAGE")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(selectedLanguage == "ar" ? 0 : 2)
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 24)
                        
                        Button {
                            showLanguagePicker = true
                        } label: {
                            HStack {
                                Text(localizedString("App Language", language: selectedLanguage))
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(AppLanguage(rawValue: selectedLanguage)?.displayName ?? "EN")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.05))
                        }
                    }
                    .sheet(isPresented: $showLanguagePicker) {
                        LanguagePickerView()
                            .presentationDetents([.fraction(0.4)])
                    }
                    // Notifications
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizedString("onboard.notif.title", language: selectedLanguage))
                            .font(.system(size: 10, weight: .medium))
                            .tracking(selectedLanguage == "ar" ? 0 : 2)
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 24)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizedString("onboard.notif.title", language: selectedLanguage))
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text(localizedString("onboard.notif.desc", language: selectedLanguage))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $smartNotificationsEnabled)
                                .tint(Color("#D9B883"))
                                .onChange(of: smartNotificationsEnabled) { _, enabled in
                                    if enabled {
                                        NotificationManager.requestPermission()
                                    } else {
                                        NotificationManager.cancelAll()
                                    }
                                }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.05))
                    }
                    // Data
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizedString("DATA", language: selectedLanguage))
                            .font(.system(size: 10, weight: .medium))
                            .tracking(selectedLanguage == "ar" ? 0 : 2)
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 24)
                        
                        Button(localizedString("Erase all data", language: selectedLanguage)) {
                            resetDataIsOn = true
                        }
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.red.opacity(0.7))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .alert(localizedString("Reset All Data", language: selectedLanguage), isPresented: $resetDataIsOn) {
                            Button(role: .destructive) {
                                do {
                                    try modelContext.delete(model: DeedLog.self)
                                    try modelContext.save()
                                    dailyGoal = 1
                                    hasSeenTierPopup = false
                                    upgradeIconVisible = false
                                } catch {
                                    print("Failed to erase data: \(error)")
                                }
                            } label: {
                                Text(localizedString("Delete", language: selectedLanguage))
                            }
                            Button(localizedString("Cancel", language: selectedLanguage), role: .cancel) {}
                        } message: {
                            Text(localizedString("settings.delete.message", language: selectedLanguage))
                        }
                    }
                    
                    // About
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizedString("about.miraat", language: selectedLanguage))
                            .font(.system(size: 10, weight: .medium))
                            .tracking(selectedLanguage == "ar" ? 0 : 2)
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 24)
                        
                        NavigationLink {
                            AboutView()
                        } label: {
                            HStack {
                                Text("About مرآة")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.05))
                        }
                    }
                    
                    Spacer()
                }
            }
            .environment(\.layoutDirection, AppLanguage(rawValue: selectedLanguage)?.layoutDirection ?? .leftToRight)
        }
    }
}
