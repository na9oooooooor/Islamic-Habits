import SwiftUI

struct OnboardingExplainView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            IslamicPattern()
                .ignoresSafeArea()
                .opacity(0.4)
            
            VStack(spacing: 0) {
                
                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(currentPage == i ?
                                Color(red: 0.85, green: 0.72, blue: 0.52) :
                                Color.white.opacity(0.2)
                            )
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Pages
                TabView(selection: $currentPage) {
                    page1.tag(0)
                    page2.tag(1)
                    page3.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Button
                Button {
                    if currentPage < 2 {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text(currentPage < 2 ?
                         localizedString("Continue", language: selectedLanguage) :
                         localizedString("Begin", language: selectedLanguage)
                    )
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.12, green: 0.09, blue: 0.07))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.85, green: 0.72, blue: 0.52))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)
            }
        }
    }
    
    // MARK: - Page 1: What is Mirror
    var page1: some View {
        VStack(spacing: 24) {
            Text("مرآة")
                .font(.system(size: 64, weight: .thin))
                .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.9))
            
            VStack(spacing: 12) {
                Text(localizedString("Build Islamic habits,\none deed at a time.", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Text(localizedString("onboard.p2.p2", language: selectedLanguage))
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Page 3: How it works
    var page2: some View {
        VStack(spacing: 32) {
            
            // Mini card grid
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(["book", "moon.stars", "hands.sparkles"], id: \.self) { icon in
                        miniCard(icon: icon, opacity: 1.0)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(["heart", "building.columns", "sun.and.horizon"], id: \.self) { icon in
                        miniCard(icon: icon, opacity: 0.6)
                    }
                }
            }
            .padding(.horizontal, 48)
            
            VStack(spacing: 12) {
                Text(localizedString("onboard.p3.p1", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                
                VStack(alignment: .leading, spacing: 12) {
                    howItWorksRow(icon: "hand.tap", text: localizedString("onboard.p3.p2", language: selectedLanguage))
                    howItWorksRow(icon: "chart.line.uptrend.xyaxis", text:localizedString( "onboard.p3.p3", language: selectedLanguage))
                    howItWorksRow(icon: "arrow.up.circle", text: localizedString("onboard.p3.p4", language: selectedLanguage))
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Page ٤: The 66-day science
    var page3: some View {
        VStack(spacing: 32) {
            
            // 66 visual
            ZStack {
                Circle()
                    .stroke(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.15), lineWidth: 1)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .stroke(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.3), lineWidth: 1)
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 2) {
                    Text(localizedString("onboard.p4.p1", language: selectedLanguage))
                        .font(.system(size: 52, weight: .thin))
                        .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52))
                    Text(localizedString("onboard.p4.p2", language: selectedLanguage))
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            VStack(spacing: 12) {
                Text(localizedString("onboard.p4.p3", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                
                Text(localizedString("onboard.p4.p4", language: selectedLanguage))
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                
                Text(localizedString("\"The most beloved deeds to Allah are the most consistent, even if small.\"", language: selectedLanguage))
                    .font(.system(size: 13, weight: .light))
                    .italic()
                    .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helpers
    func miniCard(icon: String, opacity: Double) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.1 * opacity))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.2 * opacity), lineWidth: 0.5)
            )
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.7 * opacity))
            )
            .frame(height: 70)
    }
    
    func howItWorksRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.7))
                .frame(width: 20)
            Text(text)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}
