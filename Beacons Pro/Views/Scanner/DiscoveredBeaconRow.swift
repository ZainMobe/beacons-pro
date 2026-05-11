import SwiftUI
import CoreLocation

struct DiscoveredBeaconRow: View {
    let beacon: LiveBeacon
    let isSaved: Bool
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(beacon.beaconUUID.uuidString)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 12) {
                    Label("M: \(beacon.major)", systemImage: "number")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Label("m: \(beacon.minor)", systemImage: "number")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    ProximityBadge(proximity: beacon.proximity)

                    if beacon.accuracy >= 0 {
                        Text(String(format: "%.1fm", beacon.accuracy))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                BeaconSignalBars(rssi: beacon.rssi)

                Text("\(beacon.rssi) dBm")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)

                if !isSaved {
                    Button {
                        onSave()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .tint(Theme.accentColor)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
