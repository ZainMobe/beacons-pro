import SwiftUI

struct BroadcastStatusView: View {
    let isActive: Bool
    @State private var animate = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if isActive {
                    Circle()
                        .fill(Theme.broadcastActive.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .scaleEffect(animate ? 1.4 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)
                }
                Circle()
                    .fill(isActive ? Theme.broadcastActive : Theme.scannerIdle)
                    .frame(width: 20, height: 20)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.caption2)
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(isActive ? "Broadcasting" : "Idle")
                    .font(.headline)
                Text(isActive ? "Your device is visible as a beacon" : "Not broadcasting")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { if isActive { animate = true } }
        .onChange(of: isActive) { _, newValue in animate = newValue }
    }
}
