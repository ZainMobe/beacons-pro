import SwiftUI
import CoreLocation

struct ProximityBadge: View {
    let proximity: CLProximity

    private var level: ProximityLevel {
        ProximityLevel(clProximity: proximity)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.iconName)
                .font(.caption2)
            Text(level.displayName)
                .font(.caption2.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(level.color.opacity(0.15))
        .foregroundStyle(level.color)
        .clipShape(Capsule())
    }
}
