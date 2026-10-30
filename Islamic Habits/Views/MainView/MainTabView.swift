import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    @AppStorage("selectedLanguage")
    private var selectedLanguage = "en"

    private let gold = Color(
        red: 0.85,
        green: 0.72,
        blue: 0.52
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(isActive: selectedTab == .home)
                    .tag(Tab.home)
                    .toolbar(.hidden, for: .tabBar)

                FocusView()
                    .tag(Tab.focus)
                    .toolbar(.hidden, for: .tabBar)

                CalendarView()
                    .tag(Tab.calendar)
                    .toolbar(.hidden, for: .tabBar)

                SettingsView()
                    .tag(Tab.settings)
                    .toolbar(.hidden, for: .tabBar)
            }

            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background {
                Capsule()
                    .fill(
                        Color(
                            red: 0.18,
                            green: 0.14,
                            blue: 0.10
                        )
                    )
                    .overlay {
                        Capsule()
                            .stroke(
                                Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    }
            }
            .padding(.bottom, 24)
        }
        .ignoresSafeArea()
        .environment(
            \.layoutDirection,
            selectedLanguage == "ar"
                ? .rightToLeft
                : .leftToRight
        )
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button {
            guard selectedTab != tab else { return }
            selectedTab = tab
        } label: {
            Image(systemName: tab.icon)
                .font(.system(size: 18))
                .foregroundStyle(
                    selectedTab == tab
                        ? gold
                        : Color.white.opacity(0.5)
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 44
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            tab.title(language: selectedLanguage)
        )
        .accessibilityAddTraits(
            selectedTab == tab ? .isSelected : []
        )
    }
}

enum Tab: Int, CaseIterable, Hashable {
    case home
    case focus
    case calendar
    case settings

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .focus:
            return "scope"
        case .calendar:
            return "calendar"
        case .settings:
            return "gearshape.fill"
        }
    }

    func title(language: String) -> String {
        let titles: [String]

        switch language {
        case "ar":
            titles = [
                "الرئيسية",
                "التركيز",
                "التقويم",
                "الإعدادات"
            ]

        case "th":
            titles = [
                "หน้าหลัก",
                "โฟกัส",
                "ปฏิทิน",
                "การตั้งค่า"
            ]

        default:
            titles = [
                "Home",
                "Focus",
                "Calendar",
                "Settings"
            ]
        }

        return titles[rawValue]
    }
}
