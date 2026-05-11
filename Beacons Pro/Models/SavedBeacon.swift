import Foundation
import SwiftData

@Model
final class SavedBeacon {
    var uuid: UUID
    var major: UInt16?
    var minor: UInt16?

    var customName: String
    var notes: String
    var colorTag: String
    var dateAdded: Date
    var isFavorite: Bool

    @Relationship(inverse: \BeaconGroup.beacons)
    var group: BeaconGroup?

    @Relationship(deleteRule: .cascade)
    var encounters: [BeaconEncounter]

    var lastSeenDate: Date?

    init(
        uuid: UUID,
        major: UInt16? = nil,
        minor: UInt16? = nil,
        customName: String = "",
        notes: String = "",
        colorTag: String = "#007AFF",
        isFavorite: Bool = false
    ) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.customName = customName
        self.notes = notes
        self.colorTag = colorTag
        self.dateAdded = .now
        self.isFavorite = isFavorite
        self.encounters = []
    }

    var displayName: String {
        customName.isEmpty ? uuid.uuidString.prefix(8).uppercased() + "..." : customName
    }
}
