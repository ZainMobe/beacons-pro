import Foundation
import SwiftData

@Model
final class BeaconGroup {
    var name: String
    var colorHex: String
    var iconName: String
    var dateCreated: Date

    @Relationship(deleteRule: .nullify)
    var beacons: [SavedBeacon]

    init(name: String, colorHex: String = "#34C759", iconName: String = "folder.fill") {
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.dateCreated = .now
        self.beacons = []
    }
}
