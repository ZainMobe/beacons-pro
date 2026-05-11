import SwiftUI

struct BroadcastProfileRow: View {
    let profile: BroadcastProfile
    let isActive: Bool
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(profile.name)
                        .font(.headline)
                    if isActive {
                        PulsingDot(color: Theme.broadcastActive)
                    }
                }
                Text(profile.uuid.uuidString)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text("M:\(profile.major)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("m:\(profile.minor)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let lastUsed = profile.lastUsed {
                        Text("Used \(lastUsed.relativeString)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            Button {
                onStart()
            } label: {
                Image(systemName: isActive ? "stop.fill" : "play.fill")
                    .font(.title3)
            }
            .buttonStyle(.bordered)
            .tint(isActive ? .red : Theme.broadcastActive)
        }
        .padding(.vertical, 2)
    }
}
