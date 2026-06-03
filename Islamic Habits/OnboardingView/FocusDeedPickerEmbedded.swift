import SwiftUI

struct FocusDeedPickerEmbedded: View {
    @AppStorage("focusDeeds") var focusDeedsRaw: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"

    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    var focusDeeds: [WorshipType] {
        focusDeedsRaw
            .split(separator: ",")
            .compactMap { WorshipType(rawValue: String($0)) }
    }

    var isFull: Bool { focusDeeds.count >= 3 }

    func toggle(_ worship: WorshipType) {
        var current = focusDeeds
        if current.contains(worship) {
            current.removeAll { $0 == worship }
        } else {
            guard !isFull else { return }
            current.append(worship)
        }
        focusDeedsRaw = current.map { $0.rawValue }.joined(separator: ",")
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(localizedString("focus.picker.selected", language: selectedLanguage).replacingOccurrences(of: "%d", with: "\(focusDeeds.count)"))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))

            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(WorshipType.allCases, id: \.self) { worship in
                        let isSelected = focusDeeds.contains(worship)
                        let isDisabled = isFull && !isSelected

                        FocusDeedCard(
                            worship: worship,
                            isSelected: isSelected,
                            isDisabled: isDisabled,
                            selectedLanguage: selectedLanguage
                        ) {
                            toggle(worship)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}
