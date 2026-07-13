
import Foundation
import UserNotifications

struct NotificationManager {

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Notifications granted: \(granted)")
        }
    }

    static func scheduleAll(
        engine: DeedEngine,
        focusDeeds: [WorshipType],
        smartNotificationsEnabled: Bool,
        language: String
    ) {
        guard smartNotificationsEnabled else {
            cancelAll()
            return
        }

        cancelAll()

        // Only schedule general reminder if nothing logged today
        let totalToday = engine.loggedTodayByWorship.values.reduce(0) { $0 + ($1 ? 1 : 0) }
        if totalToday == 0 {
            scheduleGeneral(hour: engine.averageLogHour, language: language)
        }

        // Only schedule focus deed reminder if that specific deed not logged today
        for worship in focusDeeds {
            let isAlreadyLogged = engine.loggedTodayByWorship[worship.rawValue] ?? false
            if !isAlreadyLogged {
                let hour = engine.averageLogHour(for: worship)
                scheduleFocusDeed(worship: worship, hour: hour, language: language)
            }
        }
    }

    // MARK: - General
    private static func scheduleGeneral(hour: Int, language: String) {
        let content = UNMutableNotificationContent()
        content.title = "مرآة"
        content.body = switch language {
            case "ar": "لا تنسَ عملك اليومي. الأعمال الدائمة أحب إلى الله."
            case "th": "อย่าลืมความดีประจำวัน ความสม่ำเสมอเป็นที่รักของอัลลอฮ์"
            default:   "Don't forget your daily deed. Small and consistent is beloved to Allah."
        }
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "general.daily", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Focus Deed
    private static func scheduleFocusDeed(worship: WorshipType, hour: Int, language: String) {
        let content = UNMutableNotificationContent()
        content.title = worship.arabicName
        content.body = focusBody(for: worship, language: language)
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "focus.\(worship.rawValue)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Body text per worship

    private static func focusBody(for worship: WorshipType, language: String) -> String {
        switch language {
        case "ar":
            switch worship.cadence {
            case "daily":   return "لم تسجّل هذا العمل اليوم بعد. خذ لحظة."
            case "weekly":  return "لم تؤدِّ \(worship.arabicName) هذا الأسبوع بعد."
            case "monthly": return "لا تدع هذا الشهر يمر دون \(worship.arabicName)."
            default:        return "حان وقت \(worship.arabicName)."
            }
        case "th":
            switch worship.cadence {
            case "daily":   return "ยังไม่ได้บันทึกวันนี้ ใช้เวลาสักครู่"
            case "weekly":  return "\(worship.arabicName) สัปดาห์นี้รอคุณอยู่"
            case "monthly": return "อย่าให้เดือนนี้ผ่านไปโดยไม่ทำ \(worship.arabicName)"
            default:        return "ถึงเวลาบันทึก \(worship.arabicName)"
            }
        default:
            switch worship.cadence {
            case "daily":   return "You haven't logged today. Take a moment."
            case "weekly":  return "This week's \(worship.arabicName) is waiting for you."
            case "monthly": return "Don't let this month pass without \(worship.arabicName)."
            default:        return "Time to log \(worship.arabicName)."
            }
        }
    }
    
    static func cancelToday() {
        // Cancel all pending — they'll be rescheduled when app backgrounds
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
