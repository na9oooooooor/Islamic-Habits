import SwiftUI
import SwiftData

struct AddPastLogView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @State private var selectedWorship: WorshipType = .quran
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    
    var logDate: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? selectedDate
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Add a past deed")
                    .font(.system(size: 24, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 40)
                
                // Date picker
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color(red: 0.85, green: 0.72, blue: 0.52))
                .colorScheme(.dark)
                .environment(\.locale, Locale(identifier: selectedLanguage))
                .padding(.horizontal, 16)
                
                // Worship picker
                VStack(spacing: 8) {
                    ForEach(WorshipType.allCases.filter { $0.isActive }, id: \.self) { worship in
                        Button {
                            selectedWorship = worship
                        } label: {
                            HStack {
                                Text(worship.arabicName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                Text(localizedString(worship.nameKey, language: selectedLanguage))
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                if selectedWorship == worship {
                                    Circle()
                                        .fill(Color(red: 0.85, green: 0.72, blue: 0.52))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                selectedWorship == worship ?
                                Color.white.opacity(0.08) :
                                Color.white.opacity(0.03)
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
                
                Button {
                    let newLog = DeedLog(worshipType: selectedWorship, loggedAt: logDate)
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
