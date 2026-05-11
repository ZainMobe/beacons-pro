import Foundation
import SwiftData

enum ExportService {
    static func exportBeaconsJSON(from context: ModelContext) throws -> Data {
        let descriptor = FetchDescriptor<SavedBeacon>(sortBy: [SortDescriptor(\.dateAdded)])
        let beacons = try context.fetch(descriptor)

        var result = [[String: Any]]()
        for beacon in beacons {
            var dict: [String: Any] = [
                "uuid": beacon.uuid.uuidString,
                "customName": beacon.customName,
                "notes": beacon.notes,
                "colorTag": beacon.colorTag,
                "dateAdded": ISO8601DateFormatter().string(from: beacon.dateAdded),
                "isFavorite": beacon.isFavorite
            ]
            if let major = beacon.major { dict["major"] = major }
            if let minor = beacon.minor { dict["minor"] = minor }
            if let group = beacon.group { dict["group"] = group.name }
            result.append(dict)
        }

        return try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
    }

    static func exportEncountersCSV(from context: ModelContext) throws -> Data {
        let descriptor = FetchDescriptor<BeaconEncounter>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        let encounters = try context.fetch(descriptor)

        var csv = "timestamp,uuid,major,minor,rssi,accuracy,proximity\n"
        let formatter = ISO8601DateFormatter()

        for encounter in encounters {
            let uuid = encounter.beacon?.uuid.uuidString ?? "unknown"
            let major = encounter.beacon?.major.map { String($0) } ?? ""
            let minor = encounter.beacon?.minor.map { String($0) } ?? ""
            let proximity = ProximityLevel(rawValue: encounter.proximity)?.displayName ?? "unknown"

            csv += "\(formatter.string(from: encounter.timestamp)),\(uuid),\(major),\(minor),\(encounter.rssi),\(String(format: "%.2f", encounter.accuracy)),\(proximity)\n"
        }

        return Data(csv.utf8)
    }

    static func purgeOldEncounters(olderThan days: Int, from context: ModelContext) throws {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now)!
        let descriptor = FetchDescriptor<BeaconEncounter>(predicate: #Predicate { $0.timestamp < cutoff })
        let old = try context.fetch(descriptor)
        for encounter in old {
            context.delete(encounter)
        }
        try context.save()
    }
}
