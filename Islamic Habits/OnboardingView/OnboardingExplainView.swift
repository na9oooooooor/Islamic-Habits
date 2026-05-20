import SwiftUI

struct OnboardingExplainView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            IslamicPattern()
                .ignoresSafeArea()
                .opacity(0.5)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Art — glowing orbs arrangement
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.15), Color.clear],
                            center: .center, startRadius: 0, endRadius: 120
                        ))
                        .frame(width: 240, height: 240)
                    
                    // Center orb
                    Circle()
                        .fill(RadialGradient(
                            colors: [
                                Color(red: 0.98, green: 0.92, blue: 0.75),
                                Color(red: 0.82, green: 0.68, blue: 0.42),
                                Color(red: 0.40, green: 0.30, blue: 0.18)
                            ],
                            center: UnitPoint(x: 0.30, y: 0.20),
                            startRadius: 0, endRadius: 50
                        ))
                        .frame(width: 90, height: 90)
                    
                    // Small orbs around
                    ForEach(0..<6) { i in
                        let angle = Double(i) * 60.0
                        let radius: CGFloat = 100
                        Circle()
                            .fill(RadialGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.75, blue: 0.50),
                                    Color(red: 0.45, green: 0.33, blue: 0.18)
                                ],
                                center: UnitPoint(x: 0.30, y: 0.25),
                                startRadius: 0, endRadius: 25
                            ))
                            .frame(width: 46, height: 46)
                            .offset(
                                x: cos(angle * .pi / 180) * radius,
                                y: sin(angle * .pi / 180) * radius
                            )
                    }
                }
                .frame(height: 280)
                
                Spacer()
                
                // Message
                VStack(spacing: 20) {
                    Text("بِسْمِ اللَّهِ")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Build Islamic habits,\none deed at a time.")
                        .font(.system(size: 24, weight: .light))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    Text("Tap an orb each day to log a deed.\nShow up consistently — for yourself, toward Allah.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("Begin")
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
}
