import Foundation

func localizedString(_ key: String, language: String) -> String {
    guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
          let bundle = Bundle(path: path) else {
        return key
    }
    return NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
}
