import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showExplain = false

    var body: some View {
        ZStack {
            if showExplain {
                OnboardingExplainView()
                    .transition(.move(edge: .trailing))
            } else {
                ZStack {
                    Color(red: 0.12, green: 0.09, blue: 0.07)
                        .ignoresSafeArea()
                    
                    IslamicPattern()
                        .ignoresSafeArea()
                        .opacity(0.4)
                    
                    VStack(spacing: 40) {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("مرآة")
                                .font(.system(size: 52, weight: .thin))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Mirror")
                                .font(.system(size: 16, weight: .light))
                                .italic()
                                .foregroundColor(.white.opacity(0.4))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 12) {
                            Text("Choose your language")
                                .font(.system(size: 13, weight: .light))
                                .tracking(1.5)
                                .foregroundColor(.white.opacity(0.4))
                            
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Button {
                                    selectedLanguage = language.rawValue
                                } label: {
                                    HStack {
                                        Text(language.displayName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                        Spacer()
                                        if selectedLanguage == language.rawValue {
                                            Circle()
                                                .fill(Color(red: 0.85, green: 0.72, blue: 0.52))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(
                                        selectedLanguage == language.rawValue ?
                                        Color.white.opacity(0.08) :
                                        Color.white.opacity(0.03)
                                    )
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showExplain = true
                            }
                        } label: {
                            Text("Continue")
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
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showExplain)
    }
}
