import SwiftUI
import SwiftData

struct MainTabView: View {
    
    @State private var selectedTab: Tab = .home
    @State private var previousTab: Tab = .home
    
    let tabOrder: [Tab] = [.home, .focus, .calendar, .settings]

    
    func tabEdge(for tab: Tab) -> Edge {
        let current = tabOrder.firstIndex(of: tab) ?? 0
        let previous = tabOrder.firstIndex(of: previousTab) ?? 0
        return current > previous ? .trailing : .leading
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView()
                        .transition(.move(edge: tabEdge(for: .home)))
                case .focus:
                    FocusView()
                        .transition(.move(edge: tabEdge(for: .focus)))
                case .calendar:
                    CalendarView()
                        .transition(.move(edge: tabEdge(for: .calendar)))
                case .settings:
                    SettingsView()
                        .transition(.move(edge: tabEdge(for: .settings)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            
            HStack(spacing: 0) {
                TabBarButton(icon: "house.fill", tab: .home, selectedTab: $selectedTab, previousTab: $previousTab)
                TabBarButton(icon: "scope", tab: .focus, selectedTab: $selectedTab, previousTab: $previousTab)
                TabBarButton(icon: "calendar", tab: .calendar, selectedTab: $selectedTab, previousTab: $previousTab)
                TabBarButton(icon: "gearshape.fill", tab: .settings, selectedTab: $selectedTab, previousTab: $previousTab)
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

enum Tab: CaseIterable {
    case home
    case focus
    case calendar
    case settings
}

struct TabBarButton: View {
    let icon: String
    let tab: Tab
    @Binding var selectedTab: Tab
    @Binding var previousTab: Tab
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button {
            previousTab = selectedTab
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
