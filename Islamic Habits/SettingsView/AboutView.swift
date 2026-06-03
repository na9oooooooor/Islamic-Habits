import SwiftUI

struct AboutView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {

                    // App icon + name
                    VStack(spacing: 12) {
                        Image("logo")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        Text("مرآة")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(gold)

                        Text("Mirror")
                            .font(.system(size: 14, weight: .light))
                            .italic()
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 40)

                    // What is it
                    AboutCard(
                        title: localizedString("about.title", language: selectedLanguage),
                        text: localizedString("about.text", language: selectedLanguage),
                        gold: gold
                    )

                    AboutCard(
                        title: localizedString("about.privacy.title", language: selectedLanguage),
                        text: localizedString("about.privacy.text", language: selectedLanguage),
                        gold: gold
                    )

                    // Feedback
                    VStack(alignment: .leading, spacing: 10) {
                        Text(localizedString("about.feedback.title", language: selectedLanguage))
                            .font(.system(size: 10, weight: .medium))
                            .tracking(2)
                            .foregroundColor(gold.opacity(0.5))

                        Text(localizedString("about.feedback.text", language: selectedLanguage))
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.white.opacity(0.5))
                            .lineSpacing(4)

                        Button {
                            if let url = URL(string: "mailto:alali.nasx@gmail.com") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("alali.nasx@gmail.com")
                                .font(.system(size: 13))
                                .foregroundColor(gold.opacity(0.7))
                                .underline()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(gold.opacity(0.1), lineWidth: 1)
                            )
                    )

                    // Footer
                    Text(localizedString("about.footer", language: selectedLanguage))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.2))
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .environment(\.layoutDirection, AppLanguage(rawValue: selectedLanguage)?.layoutDirection ?? .leftToRight)
    }
}

struct AboutCard: View {
    let title: String
    let text: String  // renamed from body → text
    let gold: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(gold.opacity(0.5))

            Text(text)  // updated
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.5))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(gold.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
