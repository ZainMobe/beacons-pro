import Foundation
import SwiftData

@Model
final class BeaconEncounter {
    var timestamp: Date
    var rssi: Int
    var accuracy: Double
    var proximity: Int

    var beacon: SavedBeacon?

    init(rssi: Int, accuracy: Double, proximity: Int, beacon: SavedBeacon? = nil) {
        self.timestamp = .now
        self.rssi = rssi
        self.accuracy = accuracy
        self.proximity = proximity
        self.beacon = beacon
    }
}
