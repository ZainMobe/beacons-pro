import UIKit

enum HapticsService {
    static func beaconDiscovered() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func beaconLost() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func broadcastStarted() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    static func tap() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
