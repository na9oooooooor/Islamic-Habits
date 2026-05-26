import SwiftUI

struct CommitmentUpgradeView: View {
    
    @AppStorage("dailyGoal") private var dailyGoal: Int = 1
    @AppStorage("hasSeenTierPopup") private var hasSeenTierPopup: Bool = false
    @AppStorage("upgradeIconVisible") private var upgradeIconVisible: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            IslamicPattern()
                .ignoresSafeArea()
                .opacity(0.4)
            
            VStack(spacing: 32) {
                Spacer()
                
                // Orb visual
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.98, green: 0.92, blue: 0.75),
                                Color(red: 0.82, green: 0.68, blue: 0.42),
                                Color(red: 0.50, green: 0.38, blue: 0.20),
                                Color(red: 0.28, green: 0.20, blue: 0.10)
                            ],
                            center: UnitPoint(x: 0.30, y: 0.20),
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // Message
                VStack(spacing: 12) {
                    Text("You've been showing up consistently.")
                        .font(.system(size: 22, weight: .light))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    Text("You're ready to take on one more deed a day — whenever you feel ready.")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        dailyGoal += 1
                        upgradeIconVisible = false
                        dismiss()
                    } label: {
                        Text("I'm ready — \(dailyGoal + 1) deeds a day")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.12, green: 0.09, blue: 0.07))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.85, green: 0.72, blue: 0.52))
                            .cornerRadius(14)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Not yet")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
#Preview {
    CommitmentUpgradeView()
}

