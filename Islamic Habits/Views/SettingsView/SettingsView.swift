import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @AppStorage("dailyGoal") private var dailyGoal: Int = 1
    @AppStorage("hasSeenTierPopup") private var hasSeenTierPopup: Bool = false
    @AppStorage("upgradeIconVisible") private var upgradeIconVisible: Bool = false
    @AppStorage("smartNotifications") private var smartNotificationsEnabled: Bool = false
    @AppStorage("focusDeeds")
    private var focusDeedsRaw:
        String = ""
    @State private var showReminderPermissionAlert = false

    @Environment(\.openURL) private var openURL
    @AppStorage("lastRhythmAlertDate")
    private var lastRhythmAlertDate:
        String = ""
    @State private var resetDataIsOn = false
    @State private var showResetFailure = false
    @State private var showLanguagePicker = false
    @State private var showPrivacyPolicy = false
    
    private var reminderPermissionTitle: String {
        switch selectedLanguage {
        case "ar":
            return "التذكيرات غير متاحة"
        case "th":
            return "ไม่สามารถเปิดการเตือน"
        default:
            return "Reminders unavailable"
        }
    }

    private var reminderPermissionMessage: String {
        switch selectedLanguage {
        case "ar":
            return "تعذّر تفعيل الإشعارات. يمكنك مراجعة إذن الإشعارات لمرآة في إعدادات الجهاز ثم المحاولة مجددًا."
        case "th":
            return "เปิดการแจ้งเตือนไม่สำเร็จ ตรวจสอบสิทธิ์การแจ้งเตือนของแอปในการตั้งค่าอุปกรณ์ แล้วลองอีกครั้ง"
        default:
            return "Notifications could not be enabled. Check Mirror’s notification permission in device Settings, then try again."
        }
    }

    private var openSettingsTitle: String {
        switch selectedLanguage {
        case "ar":
            return "فتح الإعدادات"
        case "th":
            return "เปิดการตั้งค่า"
        default:
            return "Open Settings"
        }
    }
    private var resetFailureTitle: String {
        switch selectedLanguage {
        case "ar":
            return "تعذّر حذف البيانات"
        case "th":
            return "ลบข้อมูลไม่สำเร็จ"
        default:
            return "Couldn’t erase data"
        }
    }

    private var resetFailureMessage: String {
        switch selectedLanguage {
        case "ar":
            return "لم تكتمل إعادة التعيين. يرجى المحاولة مجددًا."
        case "th":
            return "รีเซ็ตข้อมูลไม่สำเร็จ โปรดลองอีกครั้ง"
        default:
            return "The reset couldn’t be completed. Please try again."
        }
    }

    @MainActor
    private func eraseAllData() {
        func reportFailure() {
            // Present after the confirmation alert dismisses.
            DispatchQueue.main.async {
                showResetFailure = true
            }
        }

        // Preserve any pending changes before starting the reset.
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            reportFailure()
            return
        }

        do {
            // Fetch everything before marking any records for deletion.
            let deeds = try modelContext.fetch(
                FetchDescriptor<DeedLog>()
            )
            let readings = try modelContext.fetch(
                FetchDescriptor<QuranLog>()
            )
            let rhythmStates = try modelContext.fetch(
                FetchDescriptor<GlobalRhythmState>()
            )

            for deed in deeds {
                modelContext.delete(deed)
            }

            for reading in readings {
                modelContext.delete(reading)
            }

            for state in rhythmStates {
                modelContext.delete(state)
            }

            try modelContext.save()
        } catch {
            modelContext.rollback()
            reportFailure()
            return
        }

        // Reset preferences only after deletion saves successfully.
        smartNotificationsEnabled = false
        dailyGoal = 1
        focusDeedsRaw = ""
        lastRhythmAlertDate = ""
        hasSeenTierPopup = false
        upgradeIconVisible = false

        NotificationManager.cancelAll()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.12, green: 0.09, blue: 0.07)
                    .ignoresSafeArea()
                
                ScrollView {
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
                            
                            Toggle(
                                "",
                                isOn: Binding(
                                    get: {
                                        smartNotificationsEnabled
                                    },
                                    set: { enabled in
                                        if enabled {
                                            NotificationManager.requestPermission { granted in
                                                smartNotificationsEnabled = granted
                                                showReminderPermissionAlert = !granted
                                            }
                                        } else {
                                            smartNotificationsEnabled = false
                                            NotificationManager.cancelAll()
                                        }
                                    }
                                )
                            )
                            .tint(Color("#D9B883"))
                            .alert(
                                reminderPermissionTitle,
                                isPresented: $showReminderPermissionAlert
                            ) {
                                Button(openSettingsTitle) {
                                    guard let url = URL(
                                        string: UIApplication.openSettingsURLString
                                    ) else {
                                        return
                                    }

                                    openURL(url)
                                }

                                Button(
                                    localizedString("Cancel", language: selectedLanguage),
                                    role: .cancel
                                ) {}
                            } message: {
                                Text(reminderPermissionMessage)
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
                                eraseAllData()
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
                       
                        Button {
                            showPrivacyPolicy = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "hand.raised")
                                    .foregroundStyle(
                                        Color(red: 0.85, green: 0.72, blue: 0.52)
                                    )

                                Text(
                                    selectedLanguage == "ar"
                                        ? "سياسة الخصوصية"
                                        : selectedLanguage == "th"
                                            ? "นโยบายความเป็นส่วนตัว"
                                            : "Privacy Policy"
                                )
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.05))
                            .contentShape(Rectangle())
                        }
                        .sheet(isPresented: $showPrivacyPolicy) {
                            if let url = URL(
                                string: "https://app.notion.com/p/Mirror-36665dfadc6780ce96dbc13e9b8afbf4"
                            ) {
                                MirrorPrivacyView(url: url)
                            }
                        }

                        NavigationLink {
                            MirrorGuideView()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "questionmark.circle")
                                    .foregroundStyle(
                                        Color(red: 0.85, green: 0.72, blue: 0.52)
                                    )

                                Text(MirrorGuideView.title(for: selectedLanguage))
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.9))

                                Spacer()

                                Image(
                                    systemName: selectedLanguage == "ar"
                                        ? "chevron.left"
                                        : "chevron.right"
                                )
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.05))
                        }
                       
                    
                    }
                    
                    }
                    .padding(.bottom, 120)
                }
            }
            .environment(
                \.layoutDirection,
                AppLanguage(rawValue: selectedLanguage)?.layoutDirection
                    ?? .leftToRight
            )
        } // NavigationStack
        .alert(resetFailureTitle, isPresented: $showResetFailure) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resetFailureMessage)
        }
    } // body
} // SettingsView
