import Foundation
import SwiftData
import Observation

@Observable
final class BeaconFleetViewModel {
    var searchText = ""
    var showAddBeacon = false
    var showGroupManagement = false
    var sortOrder: FleetSortOrder = .name

    private let modelContext: ModelContext

    enum FleetSortOrder: String, CaseIterable {
        case name = "Name"
        case lastSeen = "Last Seen"
        case dateAdded = "Date Added"
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func deleteBeacon(_ beacon: SavedBeacon) {
        modelContext.delete(beacon)
        try? modelContext.save()
    }

    func moveBeacon(_ beacon: SavedBeacon, to group: BeaconGroup?) {
        beacon.group = group
        try? modelContext.save()
    }

    func createGroup(name: String, colorHex: String, iconName: String) {
        let group = BeaconGroup(name: name, colorHex: colorHex, iconName: iconName)
        modelContext.insert(group)
        try? modelContext.save()
    }

    func deleteGroup(_ group: BeaconGroup) {
        modelContext.delete(group)
        try? modelContext.save()
    }
}
