import SwiftUI

struct PostLogView: View {
    
    let worship: WorshipType
    let insightKey: String
    let globalStreak: Int
    let totalToday: Int
    let selectedLanguage: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            IslamicPattern()
                .ignoresSafeArea()
                .opacity(0.3)
            
            VStack(spacing: 0) {
                
                Spacer()
                
                // Icon + name
                VStack(spacing: 12) {
                    Image(systemName: worship.icon)
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.8))
                    
                    Text(worship.arabicName)
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                    
                    if selectedLanguage != "ar" {
                        Text(LocalizedStringKey(worship.nameKey))
                            .font(.system(size: 14, weight: .light))
                            .italic()
                            .foregroundColor(.white.opacity(0.4))
                            .environment(\.locale, Locale(identifier: selectedLanguage))
                    }
                }
                
                Spacer()
                
                // Insight
                Text(localizedString(insightKey, language: selectedLanguage))
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 0.5)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                // Stats
                VStack(spacing: 16) {
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text(localizedString("postlog.last66days", language: selectedLanguage))
                                .font(.system(size: 28, weight: .thin))
                                .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52))
                            Text(localizedString("focus.streak.healthy", language: selectedLanguage))
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 0.5, height: 40)
                        
                        VStack(spacing: 4) {
                            Text("\(totalToday)")
                                .font(.system(size: 28, weight: .thin))
                                .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52))
                            Text(localizedString("postlog.deeds.today", language: selectedLanguage))
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.white.opacity(0.35))
                        }
                    }
                    
                    Text(localizedString("postlog.science.disclaimer", language: selectedLanguage))
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Dismiss
                Button {
                    onDismiss()
                } label: {
                    Text(localizedString("postlog.dismiss", language: selectedLanguage))
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.8))
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.2), lineWidth: 0.5)
                                )
                        )
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 48)
            }
        }
    }
}
