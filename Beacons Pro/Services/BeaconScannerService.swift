import Foundation
import CoreLocation
import Observation

enum ScannerError: LocalizedError {
    case bluetoothOff
    case locationDenied
    case locationRestricted
    case rangingFailed(String)
    case monitoringFailed(String)

    var errorDescription: String? {
        switch self {
        case .bluetoothOff: "Bluetooth is turned off."
        case .locationDenied: "Location access was denied. Enable it in Settings."
        case .locationRestricted: "Location access is restricted on this device."
        case .rangingFailed(let msg): "Ranging failed: \(msg)"
        case .monitoringFailed(let msg): "Monitoring failed: \(msg)"
        }
    }
}

@Observable
final class BeaconScannerService: NSObject, CLLocationManagerDelegate {
    var isScanning = false
    var discoveredBeacons: [LiveBeacon] = []
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var error: ScannerError?

    private let locationManager = CLLocationManager()
    private var beaconConstraints = [CLBeaconIdentityConstraint: [CLBeacon]]()
    private var activeRegions = [CLBeaconIdentityConstraint: CLBeaconRegion]()

    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public API

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startScanning(for uuid: UUID) {
        if authorizationStatus == .notDetermined {
            requestAuthorization()
        }

        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        guard beaconConstraints[constraint] == nil else { return }

        beaconConstraints[constraint] = []

        let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
        activeRegions[constraint] = region
        locationManager.startMonitoring(for: region)
        isScanning = true
        error = nil
    }

    func stopScanning(for uuid: UUID) {
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        if let region = activeRegions[constraint] {
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(satisfying: constraint)
            activeRegions.removeValue(forKey: constraint)
            beaconConstraints.removeValue(forKey: constraint)
        }
        rebuildDiscoveredBeacons()
        if beaconConstraints.isEmpty {
            isScanning = false
        }
    }

    func stopAllScanning() {
        for (constraint, region) in activeRegions {
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(satisfying: constraint)
        }
        activeRegions.removeAll()
        beaconConstraints.removeAll()
        discoveredBeacons.removeAll()
        isScanning = false
    }

    var activeUUIDs: [UUID] {
        activeRegions.keys.map { $0.uuid }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .denied:
            error = .locationDenied
        case .restricted:
            error = .locationRestricted
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else { return }
        if state == .inside {
            manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        } else {
            manager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying constraint: CLBeaconIdentityConstraint) {
        beaconConstraints[constraint] = beacons
        rebuildDiscoveredBeacons()
    }

    func locationManager(_ manager: CLLocationManager, didFailRangingFor constraint: CLBeaconIdentityConstraint, error: any Error) {
        self.error = .rangingFailed(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        self.error = .monitoringFailed(error.localizedDescription)
    }

    // MARK: - Private

    private func rebuildDiscoveredBeacons() {
        var allCLBeacons = [CLBeacon]()
        for regionBeacons in beaconConstraints.values {
            allCLBeacons.append(contentsOf: regionBeacons)
        }

        var updatedBeacons = [LiveBeacon]()
        for clBeacon in allCLBeacons {
            let beaconID = "\(clBeacon.uuid.uuidString)-\(clBeacon.major)-\(clBeacon.minor)"
            if var existing = discoveredBeacons.first(where: { $0.id == beaconID }) {
                existing.update(from: clBeacon)
                updatedBeacons.append(existing)
            } else {
                updatedBeacons.append(LiveBeacon(from: clBeacon))
            }
        }

        updatedBeacons.sort { lhs, rhs in
            if lhs.proximity.rawValue != rhs.proximity.rawValue {
                return lhs.proximity.rawValue < rhs.proximity.rawValue
            }
            return lhs.accuracy < rhs.accuracy
        }

        discoveredBeacons = updatedBeacons
    }
}
