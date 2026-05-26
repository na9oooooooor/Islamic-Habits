import Foundation

struct AppReviewManager {
    private static let lastRequestDateKey = "ReviewManager.LastRequestDate"
    private static let lastRequestVersionKey = "ReviewManager.LastRequestVersion"
    
    static func shouldRequestReview() -> Bool {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        
        // 1. Get current app version
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return false
        }
        
        // 2. Check: Did we already ask today?
        if let lastDate = defaults.object(forKey: lastRequestDateKey) as? Date {
            if calendar.isDateInToday(lastDate) {
                return false // Stop: Already asked today
            }
        }
        
        // 3. Check: Did we already ask for this specific app version?
        if let lastVersion = defaults.string(forKey: lastRequestVersionKey) {
            if lastVersion == currentVersion {
                return false // Stop: Already asked for this version
            }
        }
        
        // 4. Safe to ask! Save the current date and version.
        defaults.set(Date(), forKey: lastRequestDateKey)
        defaults.set(currentVersion, forKey: lastRequestVersionKey)
        return true
    }
}
