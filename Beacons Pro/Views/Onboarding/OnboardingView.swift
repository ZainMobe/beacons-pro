import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                OnboardingPage(
                    icon: "sensor.tag.radiowaves.forward.fill",
                    iconColor: .blue,
                    title: "Discover Beacons",
                    subtitle: "Scan for nearby iBeacon devices in real-time. See signal strength, proximity, and distance data as it updates live.",
                    detail: "Perfect for developers testing beacon integrations and deployments."
                )
                .tag(0)

                OnboardingPage(
                    icon: "chart.xyaxis.line",
                    iconColor: .green,
                    title: "Analyze Signals",
                    subtitle: "Track RSSI signal history with interactive charts. Monitor beacon performance over time with detailed encounter logs.",
                    detail: "Export your data as JSON or CSV for further analysis."
                )
                .tag(1)

                OnboardingPage(
                    icon: "dot.radiowaves.left.and.right",
                    iconColor: .orange,
                    title: "Broadcast & Manage",
                    subtitle: "Turn your device into a beacon transmitter. Organize your beacons into groups and manage your entire fleet.",
                    detail: "Save broadcast profiles for quick testing."
                )
                .tag(2)

                PermissionsPage(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            VStack(spacing: 16) {
                PageIndicator(currentPage: currentPage, pageCount: 4)

                if currentPage < 3 {
                    Button {
                        withAnimation { currentPage += 1 }
                    } label: {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 32)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}

private struct OnboardingPage: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let detail: String

    @State private var animate = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(animate ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)

                Image(systemName: icon)
                    .font(.system(size: 56))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.title.bold())

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text(detail)
                .font(.callout)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .onAppear { animate = true }
    }
}

private struct PermissionsPage: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(BeaconScannerService.self) private var scannerService
    @Environment(BeaconBroadcasterService.self) private var broadcasterService

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Permissions")
                .font(.title.bold())

            Text("Beacons Pro needs Location and Bluetooth access to scan for and broadcast as beacons.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                PermissionRow(
                    icon: "location.fill",
                    title: "Location",
                    subtitle: "Required to range for nearby beacons",
                    isGranted: scannerService.authorizationStatus == .authorizedWhenInUse || scannerService.authorizationStatus == .authorizedAlways
                )

                PermissionRow(
                    icon: "bluetooth",
                    title: "Bluetooth",
                    subtitle: "Required to broadcast as a beacon",
                    isGranted: broadcasterService.bluetoothState == .poweredOn
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                scannerService.requestAuthorization()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            Button("Skip") {
                hasCompletedOnboarding = true
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isGranted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: isGranted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isGranted ? .green : .secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }
}
