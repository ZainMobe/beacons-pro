import Foundation
import CoreBluetooth
import SwiftData
import Observation

@Observable
final class BroadcastViewModel {
    var quickUUID = ""
    var quickMajor = "0"
    var quickMinor = "0"
    var showProfileEditor = false
    var editingProfile: BroadcastProfile?
    var activeProfile: BroadcastProfile?
    var showError = false

    private let broadcasterService: BeaconBroadcasterService
    private let modelContext: ModelContext

    var isBroadcasting: Bool { broadcasterService.isBroadcasting }
    var bluetoothState: CBManagerState { broadcasterService.bluetoothState }
    var errorMessage: String? { broadcasterService.error?.localizedDescription }

    init(broadcasterService: BeaconBroadcasterService, modelContext: ModelContext) {
        self.broadcasterService = broadcasterService
        self.modelContext = modelContext
    }

    func startBroadcasting(profile: BroadcastProfile) {
        activeProfile = profile
        profile.lastUsed = .now
        try? modelContext.save()
        broadcasterService.startBroadcasting(
            uuid: profile.uuid,
            major: profile.major,
            minor: profile.minor,
            measuredPower: profile.measuredPower
        )
        HapticsService.broadcastStarted()
    }

    func startQuickBroadcast() {
        guard let uuid = UUID(uuidString: quickUUID.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            showError = true
            return
        }
        let major = UInt16(quickMajor) ?? 0
        let minor = UInt16(quickMinor) ?? 0
        activeProfile = nil
        broadcasterService.startBroadcasting(uuid: uuid, major: major, minor: minor)
        HapticsService.broadcastStarted()
    }

    func stopBroadcasting() {
        broadcasterService.stopBroadcasting()
        activeProfile = nil
    }

    func generateRandomUUID() {
        quickUUID = UUID().uuidString
    }

    func saveProfile(uuid: UUID, major: UInt16, minor: UInt16, name: String) {
        let profile = BroadcastProfile(uuid: uuid, major: major, minor: minor, name: name)
        modelContext.insert(profile)
        try? modelContext.save()
    }

    func deleteProfile(_ profile: BroadcastProfile) {
        if activeProfile?.persistentModelID == profile.persistentModelID {
            stopBroadcasting()
        }
        modelContext.delete(profile)
        try? modelContext.save()
    }
}
