import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct CalendarView: View {
    
    @Query(sort: \DeedLog.loggedAt, order: .reverse) private var allLogs: [DeedLog]
    @AppStorage("selectedLanguage") private var selectedLanguage: String = AppLanguage.english.rawValue
    @State private var selectedDay: IdentifiableDate? = nil
    @State private var displayedMonth: Date = Date()
    @State private var addLogDay: Bool = false
    
    var groupedLogs: [Date: [DeedLog]] {
        Dictionary(grouping: allLogs) { log in
            trackingCalendarDate(for: log.loggedAt)
        }
    }
    
    var sortedDays: [Date] {
        groupedLogs.keys.sorted { $0 > $1 }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        
                 
                        CalendarGrid(
                            month: displayedMonth,
                            loggedDays: Set(groupedLogs.keys),
                            selectedLanguage: selectedLanguage,
                            islamicToday: startOfTrackingDay,
                            onPreviousMonth: {
                                displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                            },
                            onNextMonth: {
                                displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                            },
                            selectedDay: $selectedDay
                        )
                        .padding(.top, 70)
                            .padding(.bottom, 24)
                        
                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.horizontal, 24)
                        
                        HStack {
                            Spacer()
                            Button {
                                addLogDay = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(10)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }
                        
                        if allLogs.isEmpty {
                            VStack(spacing: 12) {
                                Text(localizedString("general.nologgs", language: selectedLanguage))
                                    .font(.system(size: 18, weight: .light))
                                    .italic()
                                    .foregroundColor(.white.opacity(0.4))
                                Text(localizedString("general.nologgsMessage", language: selectedLanguage))
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.white.opacity(0.25))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(sortedDays, id: \.self) { day in
                                    DaySection(
                                        day: day,
                                        logs: groupedLogs[day] ?? [],
                                        selectedLanguage: selectedLanguage,
                                        isHighlighted: selectedDay?.date == day
                                    )
                                    .id(day)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
                .onChange(of: selectedDay) { _, newDay in
                    guard let day = newDay else { return }

                    let calendarDay = Calendar.current.startOfDay(
                        for: day.date
                    )

                    withAnimation {
                        proxy.scrollTo(calendarDay, anchor: .top)
                    }
                }
                .sheet(isPresented: $addLogDay) {
                    AddPastLogView(
                        initialDate: selectedDay?.date
                    )
                    .presentationDetents([.fraction(0.7)])
                }
            }
        }
        .environment(
            \.layoutDirection,
            selectedLanguage == "ar"
                ? .rightToLeft
                : .leftToRight
        )
        .environment(
            \.locale,
            Locale(identifier: selectedLanguage)
        )
    }
}

struct IdentifiableDate: Identifiable, Equatable, Hashable {
    let id = UUID()
    let date: Date
}

struct CalendarGrid: View {
    let month: Date
    let loggedDays: Set<Date>
    let selectedLanguage: String
    let islamicToday: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    @Binding var selectedDay: IdentifiableDate?
    @State private var showAddPastLog = false

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.calendar = calendar

        let symbols: [String] =
            formatter.shortStandaloneWeekdaySymbols

        let firstIndex = calendar.firstWeekday - 1

        return (0..<7).map { offset in
            symbols[(firstIndex + offset) % 7]
        }
    }
    
    var daysInMonth: [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        
        let monthStartWeekday = calendar.component(
            .weekday,
            from: monthStart
        )

        let leadingEmptyDays = (
            monthStartWeekday - calendar.firstWeekday + 7
        ) % 7

        var days: [Date?] = Array(
            repeating: nil,
            count: leadingEmptyDays
        )
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        return days
    }
    
    var isCurrentMonth: Bool {
        Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month)
    }
    
    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }
    

        
        var body: some View {
            VStack(spacing: 16) {
                
                HStack {
                    Button {
                        onPreviousMonth()
                    } label: {
                        Image(
                            systemName: selectedLanguage == "ar"
                                ? "chevron.right"
                                : "chevron.left"
                        )
                        .environment(\.layoutDirection, .leftToRight)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    Text(monthTitle)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button {
                        onNextMonth()
                    } label: {
                        Image(
                            systemName: selectedLanguage == "ar"
                                ? "chevron.left"
                                : "chevron.right"
                        )
                        .environment(\.layoutDirection, .leftToRight)
                        .font(.system(size: 14))
                        .foregroundColor(
                            isCurrentMonth
                                ? .white.opacity(0.15)
                                : .white.opacity(0.4)
                        )
                    }
                    .disabled(isCurrentMonth)
                }
                .padding(.horizontal, 24)
                
            Spacer()
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(
                    Array(weekdaySymbols.enumerated()),
                    id: \.offset
                ) { _, symbol in
                    Text(symbol)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
                
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        let startOfDate = Calendar.current.startOfDay(for: date)
                        let hasLog = loggedDays.contains(startOfDate)
                        let isSelected = selectedDay?.date == startOfDate
                        let isToday = startOfDate == Calendar.current.startOfDay(for: islamicToday)
                        Button {
                            selectedDay = IdentifiableDate(date: date)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.02))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                                    )
                                
                                Circle()
                                    .fill(isSelected ?
                                        Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.3) :
                                        Color.clear
                                    )
                                    .frame(width: 32, height: 32)
                                
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 13, weight: isToday ? .medium : .light))
                                    .foregroundColor(
                                        isToday ? Color(red: 0.85, green: 0.72, blue: 0.52) :
                                        hasLog ? .white.opacity(0.9) :
                                        .white.opacity(0.25)
                                    )
                                
                                if hasLog {
                                    Circle()
                                        .fill(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.7))
                                        .frame(width: 4, height: 4)
                                        .offset(y: 12)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                        }
                        .disabled(
                            startOfDate > Calendar.current.startOfDay(
                                for: islamicToday
                            )
                        )
                        
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.02))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct DaySection: View {
    let day: Date
    let logs: [DeedLog]
    let selectedLanguage: String
    let isHighlighted: Bool
    @Query private var quranLogs: [QuranLog]
    @State private var deletionFailed = false
    @State private var logPendingDeletion: DeedLog?
    @Environment(\.modelContext) private var modelContext
    
    private func deleteLog(_ log: DeedLog) {
        func showFailure() {
            DispatchQueue.main.async {
                deletionFailed = true
                logPendingDeletion = log
            }
        }

        // Preserve existing pending changes before deleting.
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            print("Could not prepare deletion: \(error)")
            showFailure()
            return
        }

        if let reading = log.linkedQuranLog(
            in: quranLogs,
            among: logs
        ) {
            modelContext.delete(reading)
        }

        modelContext.delete(log)

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            print("Failed to delete log: \(error)")
            showFailure()
        }
    }
    
    var formattedDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: day)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDay)
                .font(.system(size: 11, weight: .medium))
                .tracking(1.5)
                .foregroundColor(isHighlighted ?
                    Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.8) :
                    .white.opacity(0.35)
                )
                .padding(.horizontal, 24)
                .padding(.top, 24)
            
            ForEach(logs) { log in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.6))
                        .frame(width: 6, height: 6)
                    
                    Text(localizedString(log.worshipType, language: selectedLanguage))
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    
                    Button {
                        deletionFailed = false
                        logPendingDeletion = log
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.65))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        localizedString("Delete", language: selectedLanguage)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
            
            Divider()
                .background(Color.white.opacity(0.06))
                .padding(.horizontal, 24)
        }
        .background(isHighlighted ?
            Color(red: 0.85, green: 0.72, blue: 0.52).opacity(0.05) :
            Color.clear
        
        )
        .alert(item: $logPendingDeletion) { log in
            if deletionFailed {
                let title: String
                let explanation: String

                switch selectedLanguage {
                case "ar":
                    title = "تعذّر الحذف"
                    explanation = "لم يتم حذف التسجيل. حاول مجددًا."

                case "th":
                    title = "ลบไม่สำเร็จ"
                    explanation = "ยังไม่ได้ลบรายการ กรุณาลองอีกครั้ง"

                default:
                    title = "Couldn’t delete"
                    explanation = "The entry wasn’t deleted. Please try again."
                }

                return Alert(
                    title: Text(title),
                    message: Text(explanation),
                    dismissButton: .default(Text("OK"))
                )
            }

            let message: String

            switch selectedLanguage {
            case "ar":
                message = "هل تريد حذف هذا التسجيل وأي تفاصيل قراءة مرتبطة به؟ سيُعاد حساب تقدمك."
            case "th":
                message = "ลบรายการนี้และรายละเอียดการอ่านที่เชื่อมโยงหรือไม่ ระบบจะคำนวณความก้าวหน้าใหม่"
            default:
                message = "Delete this entry and any linked reading details? Your progress will be recalculated."
            }

            return Alert(
                title: Text(
                    localizedString(
                        "Delete",
                        language: selectedLanguage
                    )
                ),
                message: Text(message),
                primaryButton: .destructive(
                    Text(
                        localizedString(
                            "Delete",
                            language: selectedLanguage
                        )
                    )
                ) {
                    deleteLog(log)
                },
                secondaryButton: .cancel(
                    Text(
                        localizedString(
                            "Cancel",
                            language: selectedLanguage
                        )
                    )
                )
            )
        }
    }
}
