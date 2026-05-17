import SwiftUI
import SwiftData

struct AddPastLogView: View {
    
    let day: Date
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @State private var selectedWorship: WorshipType = .quran
    
    var formattedDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: day)
    }
    
    var logDate: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? day
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 4) {
                    Text(formattedDay)
                        .font(.system(size: 13, weight: .light))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("Add a deed")
                        .font(.system(size: 24, weight: .light))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 40)
                
                // Worship picker
                VStack(spacing: 12) {
                    ForEach(WorshipType.allCases.filter { $0.isActive }, id: \.self) { worship in
                        Button {
                            selectedWorship = worship
                        } label: {
                            HStack {
                                Text(worship.arabicName)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                Text(LocalizedStringKey(worship.nameKey))
                                    .font(.system(size: 13, weight: .light))
                                    .italic()
                                    .foregroundColor(.white.opacity(0.5))
                                    .environment(\.locale, Locale(identifier: selectedLanguage))
                                
                                if selectedWorship == worship {
                                    Circle()
                                        .fill(Color(red: 0.85, green: 0.72, blue: 0.52))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                selectedWorship == worship ?
                                Color.white.opacity(0.08) :
                                Color.white.opacity(0.03)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                        }
                    }
                }
                
                Spacer()
                
                // Confirm button
                Button {
                    let newLog = DeedLog(worshipType: selectedWorship, loggedAt: logDate)
                    print("logDate UTC: \(logDate)")
                    print("logDate local hour: \(Calendar.current.component(.hour, from: logDate))")
                    modelContext.insert(newLog)
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Text("Log deed")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 0.12, green: 0.09, blue: 0.07))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.85, green: 0.72, blue: 0.52))
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
