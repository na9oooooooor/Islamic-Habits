import SwiftUI

struct FocusOnboardingView: View {
    @AppStorage("hasSeenFocusOnboarding") var hasSeenFocusOnboarding: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @State private var currentPage = 0

    private let gold = Color(red: 0.85, green: 0.72, blue: 0.52)
    private let bg = Color(red: 0.12, green: 0.09, blue: 0.07)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            IslamicPattern()
                .ignoresSafeArea()
                .opacity(0.4)

            VStack(spacing: 0) {

                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<2) { i in
                        Circle()
                            .fill(currentPage == i ? gold : Color.white.opacity(0.2))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 60)

                Spacer()

                TabView(selection: $currentPage) {
                    focusPage.tag(0)
                    notifPage.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                Spacer()

                Button {
                    if currentPage < 1 {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        NotificationManager.requestPermission()
                        hasSeenFocusOnboarding = true
                    }
                } label: {
                    Text(currentPage < 1
                        ? localizedString("Continue", language: selectedLanguage)
                        : localizedString("onboard.gotit", language: selectedLanguage))
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

    // MARK: - Focus Page
    var focusPage: some View {
        VStack(spacing: 24) {
            Image(systemName: "scope")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(gold.opacity(0.8))

            VStack(spacing: 12) {
                Text(localizedString("onboard.focus.title", language: selectedLanguage))                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))

                Text(localizedString("onboard.focus.subtitle", language: selectedLanguage))

                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
            }

            FocusDeedPickerEmbedded()
                .frame(height: 320)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Notification Page
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
                notifRow(icon: "scope", text: localizedString("onboard.notif.row3", language: selectedLanguage))            }
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 24)
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
