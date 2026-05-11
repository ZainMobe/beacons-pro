import SwiftUI
import CoreLocation

struct BeaconRadarView: View {
    let beacons: [LiveBeacon]
    @State private var animate = false

    private let maxRadius: CGFloat = 140
    private let ringCount = 3

    var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { index in
                let fraction = CGFloat(index + 1) / CGFloat(ringCount)
                Circle()
                    .stroke(Color.blue.opacity(0.12), lineWidth: 1)
                    .frame(width: maxRadius * 2 * fraction, height: maxRadius * 2 * fraction)
            }

            ForEach(0..<ringCount, id: \.self) { index in
                let fraction = CGFloat(index + 1) / CGFloat(ringCount)
                let label: String = switch index {
                case 0: "< 0.5m"
                case 1: "1-3m"
                default: "3m+"
                }
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
                    .offset(x: maxRadius * fraction + 4, y: 0)
            }

            Image(systemName: "iphone")
                .font(.system(size: 16))
                .foregroundStyle(.blue)

            ForEach(Array(beacons.enumerated()), id: \.element.id) { index, beacon in
                let position = beaconPosition(for: beacon, index: index, total: beacons.count)
                BeaconDot(beacon: beacon)
                    .offset(x: position.x, y: position.y)
                    .animation(.easeInOut(duration: 0.5), value: beacon.accuracy)
            }
        }
        .frame(width: maxRadius * 2 + 40, height: maxRadius * 2 + 40)
        .onAppear { animate = true }
    }

    private func beaconPosition(for beacon: LiveBeacon, index: Int, total: Int) -> CGPoint {
        let distance = distanceToRadius(beacon.accuracy)
        let angle = angleForBeacon(index: index, total: total)
        return CGPoint(
            x: cos(angle) * distance,
            y: sin(angle) * distance
        )
    }

    private func distanceToRadius(_ accuracy: Double) -> CGFloat {
        guard accuracy > 0 else {
            return maxRadius * 0.9
        }
        let clamped = min(accuracy, 10.0)
        let normalized = clamped / 10.0
        return CGFloat(normalized) * maxRadius * 0.95 + 20
    }

    private func angleForBeacon(index: Int, total: Int) -> CGFloat {
        guard total > 0 else { return 0 }
        let baseAngle = (2 * .pi) / CGFloat(max(total, 1))
        let offset: CGFloat = -.pi / 2
        return baseAngle * CGFloat(index) + offset
    }
}

private struct BeaconDot: View {
    let beacon: LiveBeacon
    @State private var pulse = false

    private var level: ProximityLevel {
        ProximityLevel(clProximity: beacon.proximity)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(level.color.opacity(0.2))
                .frame(width: 32, height: 32)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

            Circle()
                .fill(level.color)
                .frame(width: 14, height: 14)
                .shadow(color: level.color.opacity(0.4), radius: 4)

            Text("\(beacon.minor)")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
        .onAppear { pulse = true }
    }
}
