import CoreLocation
import SwiftUI

enum ProximityLevel: Int, CaseIterable, Identifiable {
    case unknown = 0
    case immediate = 1
    case near = 2
    case far = 3

    var id: Int { rawValue }

    init(clProximity: CLProximity) {
        self = ProximityLevel(rawValue: clProximity.rawValue) ?? .unknown
    }

    var displayName: String {
        switch self {
        case .unknown: "Unknown"
        case .immediate: "Immediate"
        case .near: "Near"
        case .far: "Far"
        }
    }

    var color: Color {
        switch self {
        case .unknown: .gray
        case .immediate: .green
        case .near: .blue
        case .far: .orange
        }
    }

    var iconName: String {
        switch self {
        case .unknown: "questionmark.circle.fill"
        case .immediate: "circle.fill"
        case .near: "circle.inset.filled"
        case .far: "circle.dashed"
        }
    }

    var distanceDescription: String {
        switch self {
        case .unknown: "?"
        case .immediate: "< 0.5m"
        case .near: "0.5 - 3m"
        case .far: "3m+"
        }
    }
}
