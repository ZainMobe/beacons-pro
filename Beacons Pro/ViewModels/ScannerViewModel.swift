import Foundation
import CoreLocation
import SwiftData
import Observation

@Observable
final class ScannerViewModel {
    var activeUUIDs: [UUID] = []
    var searchText = ""
    var showUUIDEntry = false
    var showError = false
    var sortOrder: SortOrder = .proximity

    enum SortOrder: String, CaseIterable {
        case proximity = "Proximity"
        case rssi = "Signal"
        case uuid = "UUID"
    }

    private let scannerService: BeaconScannerService
    private let modelContext: ModelContext
    private var lastEncounterTimes = [String: Date]()
    private let encounterInterval: TimeInterval = 5

    var isScanning: Bool { scannerService.isScanning }
    var discoveredBeacons: [LiveBeacon] { scannerService.discoveredBeacons }
    var errorMessage: String? { scannerService.error?.localizedDescription }

    init(scannerService: BeaconScannerService, modelContext: ModelContext) {
        self.scannerService = scannerService
        self.modelContext = modelContext
    }

    var filteredBeacons: [LiveBeacon] {
        var beacons = discoveredBeacons
        if !searchText.isEmpty {
            beacons = beacons.filter {
                $0.beaconUUID.uuidString.localizedCaseInsensitiveContains(searchText) ||
                String($0.major).contains(searchText) ||
                String($0.minor).contains(searchText)
            }
        }
        switch sortOrder {
        case .proximity:
            return beacons
        case .rssi:
            return beacons.sorted { $0.rssi > $1.rssi }
        case .uuid:
            return beacons.sorted { $0.beaconUUID.uuidString < $1.beaconUUID.uuidString }
        }
    }

    // MARK: - Actions

    func addUUIDAndStartScanning(_ uuid: UUID) {
        guard !activeUUIDs.contains(uuid) else { return }
        activeUUIDs.append(uuid)
        scannerService.startScanning(for: uuid)
    }

    func removeUUID(_ uuid: UUID) {
        activeUUIDs.removeAll { $0 == uuid }
        scannerService.stopScanning(for: uuid)
    }

    func toggleScanning() {
        if isScanning {
            stopAllScanning()
        } else if activeUUIDs.isEmpty {
            showUUIDEntry = true
        } else {
            for uuid in activeUUIDs {
                scannerService.startScanning(for: uuid)
            }
        }
    }

    func stopAllScanning() {
        scannerService.stopAllScanning()
    }

    func saveBeacon(_ liveBeacon: LiveBeacon) -> SavedBeacon {
        let saved = SavedBeacon(
            uuid: liveBeacon.beaconUUID,
            major: liveBeacon.major,
            minor: liveBeacon.minor
        )
        modelContext.insert(saved)
        try? modelContext.save()
        HapticsService.tap()
        return saved
    }

    func isBeaconSaved(_ liveBeacon: LiveBeacon) -> Bool {
        findSavedBeacon(for: liveBeacon) != nil
    }

    func recordEncounters() {
        let now = Date.now
        for beacon in discoveredBeacons {
            if let lastTime = lastEncounterTimes[beacon.id],
               now.timeIntervalSince(lastTime) < encounterInterval {
                continue
            }
            if let saved = findSavedBeacon(for: beacon) {
                let encounter = BeaconEncounter(
                    rssi: beacon.rssi,
                    accuracy: beacon.accuracy,
                    proximity: beacon.proximity.rawValue,
                    beacon: saved
                )
                modelContext.insert(encounter)
                saved.lastSeenDate = now
                lastEncounterTimes[beacon.id] = now
            }
        }
        try? modelContext.save()
    }

    private func findSavedBeacon(for liveBeacon: LiveBeacon) -> SavedBeacon? {
        let uuid = liveBeacon.beaconUUID
        let major = liveBeacon.major
        let minor = liveBeacon.minor
        let descriptor = FetchDescriptor<SavedBeacon>(predicate: #Predicate {
            $0.uuid == uuid
        })
        guard let results = try? modelContext.fetch(descriptor) else { return nil }
        return results.first { saved in
            (saved.major == nil || saved.major == major) &&
            (saved.minor == nil || saved.minor == minor)
        }
    }
}
