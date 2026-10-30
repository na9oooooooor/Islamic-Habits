import TelemetryDeck
import Foundation

enum MirrorAnalytics {
    static func configure() {
        let config = TelemetryDeck.Config(
            appID: "6FE77B4E-DF00-4840-9D0C-A47477F9729B"
        )

        
        TelemetryDeck.initialize(config: config)
    }

    static func appOpened() {
        TelemetryDeck.signal("app_open")
    }

    static func deedSubmitted() {
        TelemetryDeck.signal("deed_submitted")
    }
}

