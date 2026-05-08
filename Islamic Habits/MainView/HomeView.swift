import SwiftUI
import SwiftData

struct HomeView: View {
    
    @State private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var context
    @Query private var allLogs: [DeedLog]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(WorshipType.allCases, id: \.self) { worship in
                let engine = viewModel.engine(for: worship)
                
                Button {
                    viewModel.log(worshipType: worship, context: context)
                } label: {
                    Text(worship.nameKey)
                }
                .opacity(engine.loggedToday ? 0.4 : 1.0)
            }
        }
        .onChange(of: allLogs) { _, new in
            viewModel.allLogs = new
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: DeedLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return HomeView()
        .modelContainer(container)
}
