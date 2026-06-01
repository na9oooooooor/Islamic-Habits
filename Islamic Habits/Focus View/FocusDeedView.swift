import SwiftUI

struct FocusDeedPickerView: View {
    @AppStorage("focusDeeds") var focusDeedsRaw: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"

    var onContinue: () -> Void
    var onSkip: () -> Void

    private let gold = Color("#D9B883")
    private let background = Color("#1F1712")

    // MARK: - Computed

    var focusDeeds: [WorshipType] {
        focusDeedsRaw
            .split(separator: ",")
            .compactMap { WorshipType(rawValue: String($0)) }
    }

    var isFull: Bool {
        focusDeeds.count >= 3
    }

    // MARK: - Toggle

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

    // MARK: - Body

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                VStack(spacing: 8) {
                    Text("Focus Deeds")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(gold)

                    Text("Pick up to 3 deeds to focus on building as habits")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)
                .padding(.bottom, 24)

                // Grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // space for bottom bar
                }

                Spacer()
            }

            // Bottom bar — pinned to bottom
            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Text("\(focusDeeds.count) of 3 selected")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))

                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(focusDeeds.isEmpty ? .gray : Color("#1F1712"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(focusDeeds.isEmpty ? Color.gray.opacity(0.2) : Color("#D9B883"))
                            )
                    }
                    .disabled(focusDeeds.isEmpty)
                    .padding(.horizontal, 20)

                    Button(action: onSkip) {
                        Text("Skip for now")
                            .font(.system(size: 14))
                            .foregroundColor(Color("#D9B883").opacity(0.6))
                    }
                    .padding(.bottom, 8)
                }
                .padding(.top, 16)
                .background(Color("#1F1712").opacity(0.95))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
