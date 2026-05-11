import SwiftUI

struct BeaconCardView: View {
    let beacon: SavedBeacon

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: beacon.colorTag))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(beacon.displayName)
                        .font(.headline)
                    if beacon.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }

                Text(beacon.uuid.uuidString)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let major = beacon.major {
                        Text("M:\(major)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if let minor = beacon.minor {
                        Text("m:\(minor)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if let group = beacon.group {
                        Label(group.name, systemImage: group.iconName)
                            .font(.caption2)
                            .foregroundStyle(Color(hex: group.colorHex))
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let lastSeen = beacon.lastSeenDate {
                    Text(lastSeen.relativeString)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text("\(beacon.encounters.count) encounters")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}
