import SwiftUI

enum Theme {
    static let accentColor = Color.blue
    static let scannerActive = Color.green
    static let scannerIdle = Color.gray
    static let broadcastActive = Color.orange
    static let destructive = Color.red
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let groupedBackground = Color(.systemGroupedBackground)

    static let proximityImmediate = Color.green
    static let proximityNear = Color.blue
    static let proximityFar = Color.orange
    static let proximityUnknown = Color.gray

    static let rssiExcellent = Color.green
    static let rssiGood = Color.blue
    static let rssiFair = Color.yellow
    static let rssiWeak = Color.orange
    static let rssiPoor = Color.red

    static func rssiColor(for rssi: Int) -> Color {
        switch rssi {
        case -50...0: rssiExcellent
        case -65 ..< -50: rssiGood
        case -75 ..< -65: rssiFair
        case -85 ..< -75: rssiWeak
        default: rssiPoor
        }
    }

    static let tagColors: [String] = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#FF2D55", "#5856D6", "#00C7BE",
        "#FFD60A", "#8E8E93"
    ]
}
