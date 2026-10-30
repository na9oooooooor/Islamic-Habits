import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case arabic = "ar"
    case thai = "th"
    
    var displayName: String {
        switch self {
        case .english: return "EN"
        case .arabic: return "AR"
        case .thai: return "TH"
        }
    }
    
    var layoutDirection: LayoutDirection {
        switch self {
        case .arabic: return .rightToLeft
        default: return .leftToRight
        }
    }
    
    func localizedString(_ key: String, language: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
    }
}
