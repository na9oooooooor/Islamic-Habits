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
            
            IslamicPattern()
                .ignoresSafeArea()
                .opacity(0.3)
            
            VStack(spacing: 0) {
                
                // Header
                Text(localizedString("Add a past deed", language: selectedLanguage))
                    .font(.system(size: 22, weight: .light))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                
                // Date picker
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(Color(red: 0.85, green: 0.72, blue: 0.52))
                .colorScheme(.dark)
                .environment(\.locale, Locale(identifier: selectedLanguage))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                // Worship picker
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(WorshipType.allCases, id: \.self) { worship in
                            Button {
                                selectedWorship = worship
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: worship.icon)
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(.white.opacity(0.6))
                                        .frame(width: 24)
                                    
                                    Text(worship.arabicName)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Spacer()
                                    
                                    Text(localizedString(worship.nameKey, language: selectedLanguage))
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(.white.opacity(0.4))
                                    
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
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                // Log button
                Button {
                    let newLog = DeedLog(worshipType: selectedWorship, loggedAt: logDate)
                    modelContext.insert(newLog)
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Text(localizedString("Log deed", language: selectedLanguage))
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
