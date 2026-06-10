import SwiftUI

struct DeedHeatmapView: View {
    let loggedDays: [Date: Bool]

    private let gold = Color("#D9B883")
    private let squareSize: CGFloat = 28
    private let spacing: CGFloat = 6

    // Last 14 days oldest → newest
    var last14Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<14).reversed().map {
            calendar.date(byAdding: .day, value: -$0, to: today)!
        }
    }

    // Split 14 days into 2 rows of 7
    var rows: [[Date]] {
        let days = last14Days
        return [Array(days[0..<7]), Array(days[7..<14])]
    }

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<2, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { date in
                        let isLogged = loggedDays[date] ?? false
                        let isToday = Calendar.current.isDateInToday(date)
                        let dayNumber = Calendar.current.component(.day, from: date)

                        VStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isLogged ? gold : Color.white.opacity(0.07))
                                .frame(width: squareSize, height: squareSize)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isToday ? gold : Color.clear, lineWidth: 2)
                                )

                            Text("\(dayNumber)")
                                .font(.system(size: 9))
                                .foregroundColor(isToday ? gold : .white.opacity(0.25))
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}
