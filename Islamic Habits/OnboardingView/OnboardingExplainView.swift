import SwiftUI

struct OnboardingExplainView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSeenFocusOnboarding") private var hasSeenFocusOnboarding: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @State private var currentPage = 0

    private let gold = Color(red: 0.85, green: 0.72, blue: 0.52)
    private let bg = Color(red: 0.12, green: 0.09, blue: 0.07)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            IslamicPattern().ignoresSafeArea().opacity(0.4)

            VStack(spacing: 0) {

                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<4) { i in
                        Circle()
                            .fill(currentPage == i ? gold : Color.white.opacity(0.2))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 60)

                Spacer()

                TabView(selection: $currentPage) {
                    missionPage.tag(0)
                    howPage.tag(1)
                    focusPage.tag(2)
                    notifPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                Spacer()

                Button {
                    if currentPage < 3 {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        NotificationManager.requestPermission()
                        hasCompletedOnboarding = true
                        hasSeenFocusOnboarding = true
                    }
                } label: {
                    Text(currentPage < 3
                        ? localizedString("Continue", language: selectedLanguage)
                        : localizedString("Begin", language: selectedLanguage))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(gold)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Page 1: The Mission
    var missionPage: some View {
        VStack(spacing: 32) {

            // 66 circle
            ZStack {
                Circle()
                    .stroke(gold.opacity(0.15), lineWidth: 1)
                    .frame(width: 160, height: 160)
                Circle()
                    .stroke(gold.opacity(0.3), lineWidth: 1)
                    .frame(width: 120, height: 120)
                VStack(spacing: 2) {
                    Text("٦٦")
                        .font(.system(size: 52, weight: .thin))
                        .foregroundColor(gold)
                    Text(localizedString("onboard.p4.p2", language: selectedLanguage))
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            VStack(spacing: 16) {
                Text(localizedString("Build Islamic habits,\none deed at a time.", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Text(localizedString("onboard.p4.p4", language: selectedLanguage))
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)

                Text(localizedString("\"The most beloved deeds to Allah are the most consistent, even if small.\"", language: selectedLanguage))
                    .font(.system(size: 13, weight: .light))
                    .italic()
                    .foregroundColor(gold.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Page 2: How it works
    var howPage: some View {
        VStack(spacing: 40) {

            // Mini grid of deed cards
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(["book", "moon.stars", "hands.sparkles"], id: \.self) { icon in
                        miniCard(icon: icon, opacity: 1.0)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(["heart", "building.columns", "sun.and.horizon"], id: \.self) { icon in
                        miniCard(icon: icon, opacity: 0.5)
                    }
                }
            }
            .padding(.horizontal, 48)

            VStack(spacing: 20) {
                Text(localizedString("onboard.p3.p1", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))

                // Single clear instruction
                VStack(spacing: 0) {
                    Text(selectedLanguage == "ar"
                        ? "اضغط على أي بطاقة كل يوم لتسجيل عمل صالح.\nالثبات على العمل الصغير أحب إلى الله من الكثير المنقطع."
                        : selectedLanguage == "th"
                        ? "แตะการ์ดใดก็ได้ทุกวันเพื่อบันทึกความดี\nความสม่ำเสมอสำคัญกว่าปริมาณ — เสมอ"
                        : "Tap any card each day to log a good deed.\nConsistency over volume — always.")

                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Page 3: Focus Deeds
    var focusPage: some View {
        VStack(spacing: 24) {
            Image(systemName: "scope")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(gold.opacity(0.8))

            VStack(spacing: 12) {
                Text(localizedString("onboard.focus.title", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))

                Text(selectedLanguage == "ar"
                    ? "اختر حتى ٣ أعمال تريد بناءها كعادة راسخة.\nستتتبع مرآة تقدمك فيها بشكل خاص."
                    : selectedLanguage == "th"
                    ? "เลือกสูงสุด 3 งานที่ต้องการสร้างเป็นนิสัยลึกซึ้ง\nมรآة จะติดตามเส้นทางของคุณในแต่ละงานอย่างใกล้ชิด"
                    : "Pick up to 3 deeds to build as deep habits.\nمرآة will track your journey in each one closely.")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
            }

            FocusDeedPickerEmbedded()
                .frame(height: 300)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Page 4: Notifications
    var notifPage: some View {
        VStack(spacing: 32) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(gold.opacity(0.8))

            VStack(spacing: 12) {
                Text(localizedString("onboard.notif.title", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))

                Text(localizedString("onboard.notif.subtitle", language: selectedLanguage))
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                notifRow(icon: "clock", text: localizedString("onboard.notif.row1", language: selectedLanguage))
                notifRow(icon: "checkmark.circle", text: localizedString("onboard.notif.row2", language: selectedLanguage))
                notifRow(icon: "scope", text: localizedString("onboard.notif.row3", language: selectedLanguage))
            }
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers
    func miniCard(icon: String, opacity: Double) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(gold.opacity(0.1 * opacity))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(gold.opacity(0.2 * opacity), lineWidth: 0.5)
            )
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(gold.opacity(0.7 * opacity))
            )
            .frame(height: 70)
    }

    func notifRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(gold.opacity(0.7))
                .frame(width: 20)
            Text(text)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }
}
