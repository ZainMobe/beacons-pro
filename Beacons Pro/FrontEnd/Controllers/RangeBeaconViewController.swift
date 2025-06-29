/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller that illustrates how to start and stop ranging for a beacon region.
*/

import UIKit
import CoreLocation

class RangeBeaconViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var outletAddBeacon: UIButton!
    @IBOutlet weak var emptyIconImg: UIImageView!
    @IBOutlet weak var viewEmpty: UIView!
    /**
     This hardcoded UUID appears by default in the ranging prompt.
     It is the same UUID used in ConfigureBeaconViewController
     for creating a beacon.
     */
    let defaultUUID = "31313439-3939-3930-3032-000000000000"
    /// This location manager is used to demonstrate how to range beacons.
    var locationManager = CLLocationManager()
    var beaconConstraints = [CLBeaconIdentityConstraint: [CLBeacon]]()
    var beacons = [CLProximity: [CLBeacon]]()
    var findingBeaconAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop monitoring when the view disappears.
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        // Stop ranging when the view disappears.
        for constraint in beaconConstraints.keys {
            locationManager.stopRangingBeacons(satisfying: constraint)
        }
    }

    fileprivate func setup() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showAddBeaconAlert))
        outletAddBeacon.layer.cornerRadius = 12
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        emptyIconImg.rotate360Continuously()
        updateUIForBeacons()
    }
    
    @objc private func showAddBeaconAlert() {
        let controller = self.getController(identifier: .EnterUUIDController) as! EnterUUIDController
        controller.uuidAdded = {[weak self] uuid in
            self?.locationManager.requestWhenInUseAuthorization()
            // Create a new constraint and add it to the dictionary.
            print("Adding uuid: ", uuid)
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            self?.beaconConstraints[constraint] = []
            /*
             By monitoring for the beacon before ranging, the app is more
             energy efficient if the beacon is not immediately observable.
             */
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
            self?.locationManager.startMonitoring(for: beaconRegion)
        }
        self.present(controller, animated: true)
    }
    
    private func showFindingBeaconAlert() {
        findingBeaconAlert = UIAlertController(title: "Finding Beacons", message: "Please wait...", preferredStyle: .alert)
        self.present(findingBeaconAlert!, animated: true)
    }
    
    private func hideFindingBeaconAlert() {
        findingBeaconAlert?.dismiss(animated: true)
    }
    
    private func updateUIForBeacons() {
        viewEmpty.isHidden = !beacons.isEmpty
        outletAddBeacon.isHidden = beacons.isEmpty
        tableView.isHidden = beacons.isEmpty
    }
    
    @IBAction func actionAddBeacon(_ sender: Any) {
        showAddBeaconAlert()
    }

}

// MARK: - Location Manager Delegate
extension RangeBeaconViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("didStartMonitoringFor")
        showFindingBeaconAlert()
    }
    /// - Tag: didDetermineState
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let beaconRegion = region as? CLBeaconRegion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: hideFindingBeaconAlert)
        
        if state == .inside {
            // Start ranging when inside a region.
            print("Location is inside given region")
            manager.startRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        } else {
            print("Location is outside given region")
            // Stop ranging when not inside a region.
            self.alert(title: "Not Found", message: "Beacon location is outside the region.")
            manager.stopRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        }
    }
    
    /// - Tag: didRange
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        /*
         Beacons are categorized by proximity. A beacon can satisfy
         multiple constraints and can be displayed multiple times.
         */
        print("Ranged beacon: ", beacons)
        beaconConstraints[beaconConstraint] = beacons
        
        self.beacons.removeAll()
        
        var allBeacons = [CLBeacon]()
        
        for regionResult in beaconConstraints.values {
            allBeacons.append(contentsOf: regionResult)
        }
        
        for range in [CLProximity.unknown, .immediate, .near, .far] {
            let proximityBeacons = allBeacons.filter { $0.proximity == range }
            if !proximityBeacons.isEmpty {
                self.beacons[range] = proximityBeacons
            }
        }
        
        updateUIForBeacons()
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source
extension RangeBeaconViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let sectionKeys = Array(beacons.keys)
        // The table view displays beacons by proximity.
        let sectionKey = sectionKeys[section]
        
        switch sectionKey {
            case .immediate:
                title = "Immediate"
            case .near:
                title = "Near"
            case .far:
                title = "Far"
            default:
                title = "Unknown"
        }
        return title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return beacons.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(beacons.values)[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_identifiers.BeaconCell, for: indexPath) as! BeaconCell

        // Display the UUID, major, and minor for each beacon.
        let sectionkey = Array(beacons.keys)[indexPath.section]
        let beacon = beacons[sectionkey]![indexPath.row]
    
        cell.lblTitle.text = "UUID: \(beacon.uuid.uuidString)"
        cell.lblSubtitle.text = "Major: \(beacon.major) Minor: \(beacon.minor)"
        cell.lblDistance.text = "Distance: \(String(format: "%0.2f", beacon.accuracy)) meters"
        
        return cell
    }
}


extension UIImageView {
    func applyBounceEffect() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.values = [0, -10, 0] // bounce up and back
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 0.6
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.layer.add(animation, forKey: "bounce")
    }
    
    func applyBellBounce() {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.repeatCount = .infinity
        
        // 🌀 Rotation (like bell swing)
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = [0, -0.2, 0.2, 0]
        rotation.keyTimes = [0, 0.25, 0.75, 1]
        rotation.duration = 1.0
        
        // 📍 Vertical bounce (slight up/down)
        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [0, -4, 0]
        bounce.keyTimes = [0, 0.5, 1]
        bounce.duration = 1.0
        bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        animationGroup.animations = [rotation, bounce]
        self.layer.add(animationGroup, forKey: "bellBounce")
    }
    
    func rotate360Continuously() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1.5
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        
        self.layer.add(rotation, forKey: "rotate360")
    }
}
