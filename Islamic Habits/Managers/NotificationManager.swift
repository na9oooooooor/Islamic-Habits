import Foundation
import UserNotifications

struct NotificationManager {

    static func requestPermission(
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, error in
                if let error {
                    print("Notification permission failed: \(error)")
                }

                DispatchQueue.main.async {
                    completion(granted)
                }
            }
    }

    static func scheduleAll(
        engine: DeedEngine,
        focusDeeds: [WorshipType],
        smartNotificationsEnabled: Bool,
        language: String
    ) {
        cancelAll()

        guard smartNotificationsEnabled else {
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let today = trackingDayStart(for: now)

        // General reminders: today and the next 13 days.
        for offset in 0..<14 {
            // A completed day does not need a general reminder.
            if offset == 0,
               engine.todayLogs.count >= engine.dailyGoal {
                continue
            }

            guard
                let day = calendar.date(
                    byAdding: .day,
                    value: offset,
                    to: today
                ),
                let date = reminderDate(
                    on: day,
                    hour: engine.averageLogHour,
                    minute: 30,
                    calendar: calendar
                ),
                date > now
            else {
                continue
            }

            let body: String

            switch language {
            case "ar":
                body = "لحظة لعمل صغير تختاره اليوم."
            case "th":
                body = "หาเวลาสักครู่เพื่อทำความดีเล็ก ๆ วันนี้"
            default:
                body = "Make a little time for a small good deed today."
            }

            enqueue(
                identifier: "general.\(offset)",
                title: "مرآة",
                body: body,
                date: date,
                calendar: calendar
            )
        }

        // At most three distinct focus habits.
        var seen = Set<String>()
        let selectedDeeds = focusDeeds.filter {
            seen.insert($0.rawValue).inserted
        }.prefix(3)

        for worship in selectedDeeds {
            let interval = max(1, worship.streakUnit)

            let lastLog = engine.logs
                .filter {
                    $0.worshipType == worship.rawValue &&
                    $0.loggedAt <= now
                }
                .max {
                    $0.loggedAt < $1.loggedAt
                }

            var dueDay = today

            if let lastLog,
               let nextDay = calendar.date(
                   byAdding: .day,
                   value: interval,
                   to: trackingDayStart(for: lastLog.loggedAt)
               ) {
                dueDay = max(today, nextDay)
            }

            // Queue the next 14 occurrences for this habit.
            for index in 0..<14 {
                guard var date = reminderDate(
                    on: dueDay,
                    hour: engine.averageLogHour(for: worship),
                    minute: 0,
                    calendar: calendar
                ) else {
                    break
                }

                // If today's chosen time passed, start tomorrow.
                if date <= now {
                    guard
                        let tomorrow = calendar.date(
                            byAdding: .day,
                            value: 1,
                            to: today
                        ),
                        let nextDate = reminderDate(
                            on: tomorrow,
                            hour: engine.averageLogHour(for: worship),
                            minute: 0,
                            calendar: calendar
                        )
                    else {
                        break
                    }

                    dueDay = tomorrow
                    date = nextDate
                }

                let body: String

                switch language {
                case "ar":
                    body = "لحظة للعمل الذي اخترت التركيز عليه."
                case "th":
                    body = "หาเวลาสักครู่ให้ความดีที่คุณเลือกมุ่งเน้น"
                default:
                    body = "A moment for the habit you chose to focus on."
                }

                enqueue(
                    identifier: "focus.\(worship.rawValue).\(index)",
                    title: worship.localizedName(language: language),
                    body: body,
                    date: date,
                    calendar: calendar
                )

                guard let nextDay = calendar.date(
                    byAdding: .day,
                    value: interval,
                    to: dueDay
                ) else {
                    break
                }

                dueDay = nextDay
            }
        }
    }

    private static func reminderDate(
        on day: Date,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date? {
        // Keep the reminder inside the intended tracking day.
        let safeHour = min(max(hour, 0), 23)

        guard let date = calendar.date(
            bySettingHour: safeHour,
            minute: minute,
            second: 0,
            of: day
        ) else {
            return nil
        }

        if trackingDayStart(for: date) < day {
            return calendar.date(
                byAdding: .day,
                value: 1,
                to: date
            )
        }

        return date
    }

    private static func enqueue(
        identifier: String,
        title: String,
        body: String,
        date: Date,
        calendar: Calendar
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Reminder scheduling failed: \(error)")
            }
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }

    static func cancelToday() {
        cancelAll()
    }
}
