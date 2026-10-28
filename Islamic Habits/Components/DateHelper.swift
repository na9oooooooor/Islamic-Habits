import Foundation

private let trackingDayBoundaryHour = 2

var startOfTrackingDay: Date {
    trackingDayStart(for: Date())
}

var startOfTrackingTomorrow: Date {
    Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: startOfTrackingDay
    )!
}

func trackingDayStart(for date: Date) -> Date {
    let calendar = Calendar.current

    var components = calendar.dateComponents(
        [.year, .month, .day],
        from: date
    )

    components.hour = trackingDayBoundaryHour
    components.minute = 0
    components.second = 0

    let boundary = calendar.date(from: components)!

    if date < boundary {
        return calendar.date(
            byAdding: .day,
            value: -1,
            to: boundary
        )!
    }

    return boundary
}

func trackingCalendarDate(for date: Date) -> Date {
    Calendar.current.startOfDay(
        for: trackingDayStart(for: date)
    )
}

func todayString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    return formatter.string(
        from: trackingCalendarDate(for: Date())
    )
}
