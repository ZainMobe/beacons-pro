import Foundation
import SwiftData

@Model
final class BroadcastProfile {
    var uuid: UUID
    var major: UInt16
    var minor: UInt16
    var name: String
    var measuredPower: Int?
    var dateCreated: Date
    var lastUsed: Date?

    init(uuid: UUID, major: UInt16 = 0, minor: UInt16 = 0, name: String = "Default") {
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.name = name
        self.dateCreated = .now
    }
}
