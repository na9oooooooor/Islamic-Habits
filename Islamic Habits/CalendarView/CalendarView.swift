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
            islamicStartOfDay(for: log.loggedAt)
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
                            islamicToday: startOfIslamicDay,
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
                    let islamicDay = islamicStartOfDay(for: day.date)
                    withAnimation {
                        proxy.scrollTo(islamicDay, anchor: .top)
                    }
                }
                .sheet(isPresented: $addLogDay) {
                    AddPastLogView()
                        .presentationDetents([.fraction(0.7)])
                }
            }
        }
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
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    
    var daysInMonth: [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
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
                        Image(systemName: "chevron.left")
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
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(isCurrentMonth ? .white.opacity(0.15) : .white.opacity(0.4))
                    }
                    .disabled(isCurrentMonth)
                }
                .padding(.horizontal, 24)
                
            Spacer()
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.25))
                        .frame(maxWidth: .infinity)
                }
                
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        let startOfDate = islamicStartOfDay(for: date)
                        let hasLog = loggedDays.contains(startOfDate)
                        let isSelected = selectedDay?.date == startOfDate
                        let isToday = islamicStartOfDay(for: date) == islamicToday
                        
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
                        .disabled(islamicStartOfDay(for: date) > startOfIslamicDay)
                        
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
    
    @Environment(\.modelContext) private var modelContext
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
                        modelContext.delete(log)
                        try? modelContext.save()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.2))
                    }
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
    }
}
