
import SwiftUI

struct FocusDeedCard: View {
    let worship: WorshipType
    let isSelected: Bool
    let isDisabled: Bool
    let selectedLanguage: String
    let onTap: () -> Void

    private let gold = Color("#D9B883")
    private let background = Color("#1F1712")
    

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                // Icon
                Image(systemName: worship.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isDisabled ? .gray : gold)

                // Name
                Text(selectedLanguage == "ar" ? worship.arabicName : localizedString(worship.nameKey, language: selectedLanguage))

                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isDisabled ? .gray : gold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Checkmark
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? gold : .gray.opacity(0.4))
                    .font(.system(size: 18))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? gold : Color.white.opacity(0.06),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .opacity(isDisabled ? 0.4 : 1.0)
        }
        .disabled(isDisabled)
    }
}
