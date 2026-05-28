import SwiftUI

struct HabitProgressBar: View {
    let progress: Double
    let deedsToday: Int
    let selectedLanguage: String
    let canUndo: Bool
    let onUndo: () -> Void
    
    @State private var isGlowing = false
    
    var cappedProgress: Double {
        min(progress, 1.0)
    }
    
    var message: String {
        let key: String
        switch progress {
        case 0..<0.3: key = "habitProgress.begin"
        case 0.3..<0.6: key = "habitProgress.forming"
        case 0.6..<1.0: key = "habitProgress.almost"
        default: key = "habitProgress.established"
        }
        return localizedString(key, language: selectedLanguage)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Text(message)
                    .font(.system(size: 11, weight: .light))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    Text("\(Int(cappedProgress * 100))%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.7))
                    
                    Spacer()
                    
                    if canUndo {
                        Button {
                            onUndo()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 10)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.70, green: 0.55, blue: 0.35),
                                    Color(red: 0.92, green: 0.78, blue: 0.55)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(CGFloat(cappedProgress) * geo.size.width, 10), height: 10)
                        .shadow(
                            color: Color(red: 0.85, green: 0.72, blue: 0.52)
                                .opacity(isGlowing ? 0.9 : 0.4),
                            radius: isGlowing ? 10 : 5
                        )
                        .animation(.easeInOut(duration: 1.0), value: cappedProgress)
                }
            }
            .frame(height: 10)
            
            Text("\(deedsToday) \(localizedString("habit.logged_today", language: selectedLanguage))")                .font(.system(size: 11, weight: .light))
                .tracking(1.0)
                .foregroundColor(.white.opacity(0.3))
            
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}
