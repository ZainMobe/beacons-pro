import CoreLocation
import SwiftUI

extension CLProximity {
    var level: ProximityLevel {
        ProximityLevel(clProximity: self)
    }
}
