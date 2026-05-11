import Foundation
import CoreLocation

struct LiveBeacon: Identifiable {
    let id: String
    let beaconUUID: UUID
    let major: UInt16
    let minor: UInt16
    var rssi: Int
    var accuracy: Double
    var proximity: CLProximity
    var lastSeen: Date

    init(from clBeacon: CLBeacon) {
        self.id = "\(clBeacon.uuid.uuidString)-\(clBeacon.major)-\(clBeacon.minor)"
        self.beaconUUID = clBeacon.uuid
        self.major = clBeacon.major.uint16Value
        self.minor = clBeacon.minor.uint16Value
        self.rssi = clBeacon.rssi
        self.accuracy = clBeacon.accuracy
        self.proximity = clBeacon.proximity
        self.lastSeen = .now
    }

    #if DEBUG
    init(uuid: UUID, major: UInt16, minor: UInt16, rssi: Int, accuracy: Double, proximity: CLProximity) {
        self.id = "\(uuid.uuidString)-\(major)-\(minor)"
        self.beaconUUID = uuid
        self.major = major
        self.minor = minor
        self.rssi = rssi
        self.accuracy = accuracy
        self.proximity = proximity
        self.lastSeen = .now
    }
    #endif

    mutating func update(from clBeacon: CLBeacon) {
        self.rssi = clBeacon.rssi
        self.accuracy = clBeacon.accuracy
        self.proximity = clBeacon.proximity
        self.lastSeen = .now
    }
}

extension LiveBeacon: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: LiveBeacon, rhs: LiveBeacon) -> Bool {
        lhs.id == rhs.id
    }
}
