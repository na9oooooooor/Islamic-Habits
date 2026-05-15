import SwiftUI
import SwiftData

struct MainTabView: View {
    
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            switch selectedTab {
            case .home:
                HomeView()
            case .calendar:
                CalendarView()
            case .settings:
                SettingsView()
            }
            
            // Custom tab bar
            HStack(spacing: 0) {
                TabBarButton(icon: "house", tab: .home, selectedTab: $selectedTab)
                TabBarButton(icon: "calendar", tab: .calendar, selectedTab: $selectedTab)
                TabBarButton(icon: "gearshape", tab: .settings, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
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
            Image(systemName: isSelected ? "\(icon).fill" : icon)
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
