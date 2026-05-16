import Foundation

var startOfIslamicDay: Date {
    let now = Date()
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: now)
    components.hour = 2
    components.minute = 0
    let todayAt2am = calendar.date(from: components)!
    
    if now < todayAt2am {
        return calendar.date(byAdding: .day, value: -1, to: todayAt2am)!
    }
    return todayAt2am
}

var startOfIslamicTomorrow: Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: startOfIslamicDay)!
}
