
import SwiftUI

struct LanguagePickerView: View {
    
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("Language")
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button {
                            selectedLanguage = language.rawValue
                            dismiss()
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
                                Color.white.opacity(selectedLanguage == language.rawValue ? 0.08 : 0.03)
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
            }
        }
    }
}
