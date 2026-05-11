import Foundation
import CoreBluetooth
import CoreLocation
import Observation

enum BroadcasterError: LocalizedError {
    case bluetoothOff
    case bluetoothUnauthorized
    case advertisingFailed(String)

    var errorDescription: String? {
        switch self {
        case .bluetoothOff: "Bluetooth is turned off. Enable it in Settings."
        case .bluetoothUnauthorized: "Bluetooth permission is not granted."
        case .advertisingFailed(let msg): "Broadcasting failed: \(msg)"
        }
    }
}

struct BroadcastConfig {
    let uuid: UUID
    let major: UInt16
    let minor: UInt16
    let measuredPower: Int?
}

@Observable
final class BeaconBroadcasterService: NSObject, CBPeripheralManagerDelegate {
    var isBroadcasting = false
    var bluetoothState: CBManagerState = .unknown
    var error: BroadcasterError?

    private var peripheralManager: CBPeripheralManager!
    private var pendingConfig: BroadcastConfig?

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    // MARK: - Public API

    func startBroadcasting(uuid: UUID, major: UInt16, minor: UInt16, measuredPower: Int? = nil) {
        let config = BroadcastConfig(uuid: uuid, major: major, minor: minor, measuredPower: measuredPower)

        guard peripheralManager.state == .poweredOn else {
            pendingConfig = config
            if peripheralManager.state == .poweredOff {
                error = .bluetoothOff
            }
            return
        }

        broadcast(config)
    }

    func stopBroadcasting() {
        peripheralManager.stopAdvertising()
        isBroadcasting = false
        pendingConfig = nil
    }

    // MARK: - CBPeripheralManagerDelegate

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        bluetoothState = peripheral.state

        switch peripheral.state {
        case .poweredOn:
            error = nil
            if let config = pendingConfig {
                broadcast(config)
                pendingConfig = nil
            }
        case .poweredOff:
            isBroadcasting = false
            error = .bluetoothOff
        case .unauthorized:
            isBroadcasting = false
            error = .bluetoothUnauthorized
        default:
            break
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?) {
        if let error {
            self.error = .advertisingFailed(error.localizedDescription)
            isBroadcasting = false
        }
    }

    // MARK: - Private

    private func broadcast(_ config: BroadcastConfig) {
        peripheralManager.stopAdvertising()

        let constraint = CLBeaconIdentityConstraint(uuid: config.uuid, major: config.major, minor: config.minor)
        let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: Bundle.main.bundleIdentifier!)

        let power: NSNumber? = config.measuredPower.map { NSNumber(value: $0) }
        let peripheralData = region.peripheralData(withMeasuredPower: power) as? [String: Any]

        peripheralManager.startAdvertising(peripheralData)
        isBroadcasting = true
        error = nil
    }
}
