import SwiftUI
import SwiftData

struct MainTabView: View {
    
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case .home:
                HomeView()
            case .calendar:
                CalendarView()
            case .settings:
                SettingsView()
            }
            
            HStack(spacing: 0) {
                TabBarButton(icon: "house.fill", tab: .home, selectedTab: $selectedTab)
                TabBarButton(icon: "calendar", tab: .calendar, selectedTab: $selectedTab)
                TabBarButton(icon: "gearshape.fill", tab: .settings, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color(red: 0.18, green: 0.14, blue: 0.10))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.bottom, 24)
        }
        .ignoresSafeArea()
    }
}

enum Tab {
    case home
    case calendar
    case settings
}

struct TabBarButton: View {
    let icon: String
    let tab: Tab
    @Binding var selectedTab: Tab
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isSelected ?
                    Color(red: 0.85, green: 0.72, blue: 0.52) :
                    Color.white.opacity(0.3)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
    }
}
