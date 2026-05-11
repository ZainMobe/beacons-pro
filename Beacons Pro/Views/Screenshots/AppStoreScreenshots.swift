#if DEBUG
import SwiftUI
import CoreLocation
import Charts

// MARK: - Screenshot Frame

struct ScreenshotFrame<Content: View>: View {
    let headline: String
    let subheadline: String
    let gradientColors: [Color]
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: geo.size.height * 0.06)

                    Text(headline)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                    Text(subheadline)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    content
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Mock Data

enum MockData {
    static let sampleUUID1 = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
    static let sampleUUID2 = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
    static let sampleUUID3 = UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB0764782A")!

    static let liveBeacons: [LiveBeacon] = [
        LiveBeacon(uuid: sampleUUID1, major: 1, minor: 100, rssi: -42, accuracy: 0.3, proximity: .immediate),
        LiveBeacon(uuid: sampleUUID2, major: 2, minor: 204, rssi: -58, accuracy: 1.8, proximity: .near),
        LiveBeacon(uuid: sampleUUID1, major: 1, minor: 301, rssi: -71, accuracy: 4.2, proximity: .far),
        LiveBeacon(uuid: sampleUUID3, major: 5, minor: 512, rssi: -64, accuracy: 2.1, proximity: .near),
        LiveBeacon(uuid: sampleUUID2, major: 3, minor: 88, rssi: -83, accuracy: 7.5, proximity: .far),
    ]

    static func chartDataPoints() -> [(date: Date, rssi: Int)] {
        let now = Date()
        let baseValues: [Int] = [-55, -52, -58, -48, -53, -45, -50, -42, -47, -55, -60, -52, -48, -44, -50, -53, -47, -42, -45, -50, -55, -48, -43, -46, -51, -49, -44, -47, -52, -50]
        return baseValues.enumerated().map { index, rssi in
            (date: now.addingTimeInterval(Double(-30 + index) * 60), rssi: rssi)
        }
    }
}

// MARK: - Screenshot 1: Scanner Radar

struct Screenshot_ScannerRadar: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Real-Time Beacon Radar",
            subheadline: "Visualize beacon distances on an interactive radar display",
            gradientColors: [Color(red: 0.1, green: 0.1, blue: 0.35), Color(red: 0.05, green: 0.25, blue: 0.55)]
        ) {
            VStack(spacing: 0) {
                // Nav bar
                MockNavBar(title: "Scanner", leadingIcon: "dot.scope", trailingIcons: ["plus", "arrow.up.arrow.down"])

                // UUID chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        UUIDChip(text: "E2C56DB5", isActive: true)
                        UUIDChip(text: "B9407F30", isActive: true)
                        UUIDChip(text: "FDA50693", isActive: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground).opacity(0.95))

                // Radar
                BeaconRadarView(beacons: MockData.liveBeacons)
                    .padding(.vertical, 12)

                // Beacon list peek
                VStack(spacing: 0) {
                    ForEach(MockData.liveBeacons.prefix(3)) { beacon in
                        DiscoveredBeaconRow(beacon: beacon, isSaved: beacon.minor == 100, onSave: {})
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                        if beacon.id != MockData.liveBeacons[2].id {
                            Divider().padding(.leading, 16)
                        }
                    }
                }

                Spacer()

                // Scan button
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                    Text("Stop Scanning")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Screenshot 2: Discovered Beacons List

struct Screenshot_BeaconList: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Live Signal Monitoring",
            subheadline: "RSSI, proximity, and distance data updated in real-time",
            gradientColors: [Color(red: 0.0, green: 0.3, blue: 0.2), Color(red: 0.0, green: 0.5, blue: 0.35)]
        ) {
            VStack(spacing: 0) {
                MockNavBar(title: "Scanner", leadingIcon: "circle.grid.3x3.fill", trailingIcons: ["plus", "arrow.up.arrow.down"])

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        UUIDChip(text: "E2C56DB5", isActive: true)
                        UUIDChip(text: "B9407F30", isActive: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground).opacity(0.95))

                VStack(spacing: 0) {
                    ForEach(MockData.liveBeacons) { beacon in
                        DiscoveredBeaconRow(
                            beacon: beacon,
                            isSaved: beacon.minor == 100 || beacon.minor == 204,
                            onSave: {}
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        Divider().padding(.leading, 16)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                    Text("Stop Scanning")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Screenshot 3: Fleet Management

struct Screenshot_FleetManagement: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Manage Your Fleet",
            subheadline: "Organize beacons with groups, color tags, and notes",
            gradientColors: [Color(red: 0.35, green: 0.1, blue: 0.45), Color(red: 0.55, green: 0.15, blue: 0.55)]
        ) {
            VStack(spacing: 0) {
                MockNavBar(title: "Beacons", trailingIcons: ["plus"])

                List {
                    Section("Office Lobby") {
                        MockBeaconCard(name: "Main Entrance", uuid: "E2C56DB5", major: 1, minor: 100, color: "#34C759", lastSeen: "2m ago", encounters: 847, isFavorite: true, groupName: "Office Lobby", groupIcon: "building.2", groupColor: "#007AFF")
                        MockBeaconCard(name: "Reception Desk", uuid: "E2C56DB5", major: 1, minor: 101, color: "#007AFF", lastSeen: "5m ago", encounters: 623, isFavorite: false, groupName: "Office Lobby", groupIcon: "building.2", groupColor: "#007AFF")
                    }

                    Section("Warehouse") {
                        MockBeaconCard(name: "Dock A", uuid: "B9407F30", major: 2, minor: 204, color: "#FF9500", lastSeen: "1h ago", encounters: 1204, isFavorite: true, groupName: "Warehouse", groupIcon: "shippingbox", groupColor: "#FF9500")
                        MockBeaconCard(name: "Dock B", uuid: "B9407F30", major: 2, minor: 205, color: "#FF9500", lastSeen: "3h ago", encounters: 956, isFavorite: false, groupName: "Warehouse", groupIcon: "shippingbox", groupColor: "#FF9500")
                    }

                    Section("Ungrouped") {
                        MockBeaconCard(name: "Test Beacon", uuid: "FDA50693", major: 5, minor: 512, color: "#AF52DE", lastSeen: "Just now", encounters: 42, isFavorite: false, groupName: nil, groupIcon: nil, groupColor: nil)
                        MockBeaconCard(name: "Conference Room", uuid: "FDA50693", major: 5, minor: 513, color: "#FF2D55", lastSeen: "12m ago", encounters: 318, isFavorite: true, groupName: nil, groupIcon: nil, groupColor: nil)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Screenshot 4: Signal Analytics

struct Screenshot_SignalAnalytics: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Signal Analytics",
            subheadline: "Track RSSI history with interactive charts",
            gradientColors: [Color(red: 0.0, green: 0.2, blue: 0.5), Color(red: 0.1, green: 0.4, blue: 0.7)]
        ) {
            VStack(spacing: 0) {
                MockNavBar(title: "Main Entrance", isDetail: true, trailingIcons: ["star.fill"])

                List {
                    Section("Identity") {
                        LabeledContent("UUID") {
                            Text("E2C56DB5-DFFB-...")
                                .font(.system(.caption, design: .monospaced))
                        }
                        LabeledContent("Major", value: "1")
                        LabeledContent("Minor", value: "100")
                        LabeledContent("Added", value: "May 8, 2026")
                        LabeledContent("Last Seen", value: "2 min ago")
                    }

                    Section("Signal History") {
                        Picker("Time Window", selection: .constant("30m")) {
                            Text("5m").tag("5m")
                            Text("30m").tag("30m")
                            Text("1h").tag("1h")
                            Text("24h").tag("24h")
                            Text("All").tag("All")
                        }
                        .pickerStyle(.segmented)

                        RSSIChartView(dataPoints: MockData.chartDataPoints())

                        HStack {
                            VStack(spacing: 2) {
                                Text("Avg")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text("-49 dBm")
                                    .font(.system(.caption, design: .monospaced).bold())
                            }
                            Spacer()
                            VStack(spacing: 2) {
                                Text("Min")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text("-60 dBm")
                                    .font(.system(.caption, design: .monospaced).bold())
                            }
                            Spacer()
                            VStack(spacing: 2) {
                                Text("Max")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text("-42 dBm")
                                    .font(.system(.caption, design: .monospaced).bold())
                            }
                        }
                    }

                    Section("Recent Encounters (847)") {
                        ForEach(0..<5, id: \.self) { i in
                            let rssiValues = [-42, -48, -55, -44, -51]
                            let proximities: [CLProximity] = [.immediate, .immediate, .near, .immediate, .near]
                            let times = ["10:42", "10:37", "10:32", "10:27", "10:22"]
                            HStack {
                                Text(times[i])
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                BeaconSignalBars(rssi: rssiValues[i])
                                Text("\(rssiValues[i]) dBm")
                                    .font(.system(.caption2, design: .monospaced))
                                    .frame(width: 60, alignment: .trailing)
                                ProximityBadge(proximity: proximities[i])
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Screenshot 5: Broadcasting

struct Screenshot_Broadcast: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Broadcast as a Beacon",
            subheadline: "Turn your iPhone into an iBeacon transmitter",
            gradientColors: [Color(red: 0.55, green: 0.25, blue: 0.0), Color(red: 0.7, green: 0.4, blue: 0.05)]
        ) {
            VStack(spacing: 0) {
                MockNavBar(title: "Broadcast", trailingIcons: ["plus"])

                Form {
                    Section {
                        BroadcastStatusView(isActive: true)
                        Button("Stop Broadcasting", role: .destructive) {}
                    }

                    Section("Saved Profiles") {
                        MockProfileRow(name: "Office Test", uuid: "E2C56DB5", major: 1, minor: 100, isActive: true, lastUsed: "Just now")
                        MockProfileRow(name: "Warehouse Deploy", uuid: "B9407F30", major: 2, minor: 204, isActive: false, lastUsed: "Yesterday")
                        MockProfileRow(name: "Demo Profile", uuid: "FDA50693", major: 5, minor: 512, isActive: false, lastUsed: "May 5")
                        MockProfileRow(name: "Client Beacon", uuid: "A1B2C3D4", major: 10, minor: 1, isActive: false, lastUsed: "Apr 28")
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Screenshot 6: Onboarding

struct Screenshot_Onboarding: View {
    @State private var animate = false

    var body: some View {
        ScreenshotFrame(
            headline: "Welcome to Beacons Pro",
            subheadline: "The ultimate iBeacon developer tool",
            gradientColors: [Color(red: 0.05, green: 0.15, blue: 0.4), Color(red: 0.15, green: 0.35, blue: 0.65)]
        ) {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 140, height: 140)

                        Image(systemName: "sensor.tag.radiowaves.forward.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.blue)
                    }

                    Text("Discover Beacons")
                        .font(.title.bold())

                    Text("Scan for nearby iBeacon devices in real-time. See signal strength, proximity, and distance data as it updates live.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Text("Perfect for developers testing beacon integrations and deployments.")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer()

                    HStack(spacing: 8) {
                        Capsule().fill(.blue).frame(width: 24, height: 8)
                        Capsule().fill(.gray.opacity(0.3)).frame(width: 8, height: 8)
                        Capsule().fill(.gray.opacity(0.3)).frame(width: 8, height: 8)
                        Capsule().fill(.gray.opacity(0.3)).frame(width: 8, height: 8)
                    }

                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Screenshot 7: Settings & Export

struct Screenshot_Settings: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Export & Configure",
            subheadline: "Export data as JSON or CSV, customize your workflow",
            gradientColors: [Color(red: 0.2, green: 0.2, blue: 0.25), Color(red: 0.35, green: 0.35, blue: 0.4)]
        ) {
            VStack(spacing: 0) {
                MockNavBar(title: "Settings")

                Form {
                    Section("Scanning") {
                        HStack {
                            Text("Auto-record encounters")
                            Spacer()
                            Toggle("", isOn: .constant(true)).labelsHidden()
                        }
                        HStack {
                            Text("Record interval: 5s")
                            Spacer()
                            Stepper("", value: .constant(5), in: 1...30).labelsHidden()
                        }
                        HStack {
                            Text("Haptic feedback")
                            Spacer()
                            Toggle("", isOn: .constant(true)).labelsHidden()
                        }
                    }

                    Section("Data") {
                        LabeledContent("Saved Beacons", value: "12")
                        LabeledContent("Total Encounters", value: "4,291")

                        Label("Export Beacons (JSON)", systemImage: "doc.text")
                            .foregroundStyle(.blue)
                        Label("Export Encounters (CSV)", systemImage: "tablecells")
                            .foregroundStyle(.blue)
                    }

                    Section("About") {
                        LabeledContent("Version", value: "2.0.0")
                        LabeledContent("Build", value: "1")
                        Label("Developer Website", systemImage: "globe")
                            .foregroundStyle(.blue)
                        Label("Contact", systemImage: "envelope")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Screenshot 8: Dark Mode Scanner

struct Screenshot_DarkModeRadar: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Beautiful Dark Mode",
            subheadline: "Fully optimized for dark environments",
            gradientColors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color(red: 0.12, green: 0.12, blue: 0.25)]
        ) {
            VStack(spacing: 0) {
                MockNavBar(title: "Scanner", leadingIcon: "dot.scope", trailingIcons: ["plus", "arrow.up.arrow.down"])

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        UUIDChip(text: "E2C56DB5", isActive: true)
                        UUIDChip(text: "B9407F30", isActive: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground).opacity(0.95))

                BeaconRadarView(beacons: Array(MockData.liveBeacons.prefix(4)))
                    .padding(.vertical, 12)

                VStack(spacing: 0) {
                    ForEach(MockData.liveBeacons.prefix(2)) { beacon in
                        DiscoveredBeaconRow(beacon: beacon, isSaved: true, onSave: {})
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                        Divider().padding(.leading, 16)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                    Text("Stop Scanning")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
        }
    }
}

// MARK: - Helper Views

private struct MockNavBar: View {
    let title: String
    var isDetail: Bool = false
    var leadingIcon: String? = nil
    var trailingIcons: [String] = []

    var body: some View {
        HStack {
            if isDetail {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.blue)
                    .font(.body.weight(.semibold))
            }
            if let leading = leadingIcon {
                Image(systemName: leading)
                    .foregroundStyle(.blue)
            }
            Spacer()
            Text(title)
                .font(.headline)
            Spacer()
            HStack(spacing: 16) {
                ForEach(trailingIcons, id: \.self) { icon in
                    Image(systemName: icon)
                        .foregroundStyle(icon == "star.fill" ? .yellow : .blue)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.95))
    }
}

private struct UUIDChip: View {
    let text: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            if isActive {
                PulsingDot(color: .green)
            }
            Text(text)
                .font(.system(.caption, design: .monospaced))
            Image(systemName: "xmark")
                .font(.caption2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.accentColor.opacity(0.1))
        .clipShape(Capsule())
    }
}

private struct MockBeaconCard: View {
    let name: String
    let uuid: String
    let major: UInt16
    let minor: UInt16
    let color: String
    let lastSeen: String
    let encounters: Int
    let isFavorite: Bool
    let groupName: String?
    let groupIcon: String?
    let groupColor: String?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }

                Text("\(uuid)-DFFB-48D2-B060-D0F5A71096E0")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("M:\(major)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("m:\(minor)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let groupName, let groupIcon, let groupColor {
                        Label(groupName, systemImage: groupIcon)
                            .font(.caption2)
                            .foregroundStyle(Color(hex: groupColor))
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(lastSeen)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(encounters) encounters")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct MockProfileRow: View {
    let name: String
    let uuid: String
    let major: UInt16
    let minor: UInt16
    let isActive: Bool
    let lastUsed: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if isActive {
                        PulsingDot(color: .orange)
                    }
                    Text(name)
                        .font(.headline)
                }

                Text("\(uuid)-DFFB-48D2-...")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text("M:\(major)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("m:\(minor)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(lastUsed)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Button {} label: {
                Image(systemName: isActive ? "stop.fill" : "play.fill")
                    .foregroundStyle(isActive ? .red : .blue)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - iPad Screenshots

struct Screenshot_iPad_ScannerRadar: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Real-Time Beacon Radar",
            subheadline: "Visualize beacon distances on a stunning radar display",
            gradientColors: [Color(red: 0.1, green: 0.1, blue: 0.35), Color(red: 0.05, green: 0.25, blue: 0.55)]
        ) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    MockNavBar(title: "Scanner", leadingIcon: "dot.scope", trailingIcons: ["plus", "arrow.up.arrow.down"])

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            UUIDChip(text: "E2C56DB5", isActive: true)
                            UUIDChip(text: "B9407F30", isActive: true)
                            UUIDChip(text: "FDA50693", isActive: true)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    BeaconRadarView(beacons: MockData.liveBeacons)
                        .padding(.vertical, 20)
                        .scaleEffect(1.3)

                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop Scanning")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack(spacing: 0) {
                    Text("Discovered Beacons")
                        .font(.headline)
                        .padding()

                    ForEach(MockData.liveBeacons) { beacon in
                        DiscoveredBeaconRow(beacon: beacon, isSaved: beacon.minor == 100, onSave: {})
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        Divider().padding(.leading, 16)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
        }
    }
}

struct Screenshot_iPad_Analytics: View {
    var body: some View {
        ScreenshotFrame(
            headline: "Fleet Analytics & Signal History",
            subheadline: "Monitor your entire beacon deployment at a glance",
            gradientColors: [Color(red: 0.0, green: 0.2, blue: 0.5), Color(red: 0.1, green: 0.4, blue: 0.7)]
        ) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    MockNavBar(title: "Beacons", trailingIcons: ["plus"])

                    List {
                        Section("Office Lobby") {
                            MockBeaconCard(name: "Main Entrance", uuid: "E2C56DB5", major: 1, minor: 100, color: "#34C759", lastSeen: "2m ago", encounters: 847, isFavorite: true, groupName: "Office Lobby", groupIcon: "building.2", groupColor: "#007AFF")
                            MockBeaconCard(name: "Reception Desk", uuid: "E2C56DB5", major: 1, minor: 101, color: "#007AFF", lastSeen: "5m ago", encounters: 623, isFavorite: false, groupName: "Office Lobby", groupIcon: "building.2", groupColor: "#007AFF")
                        }
                        Section("Warehouse") {
                            MockBeaconCard(name: "Dock A", uuid: "B9407F30", major: 2, minor: 204, color: "#FF9500", lastSeen: "1h ago", encounters: 1204, isFavorite: true, groupName: "Warehouse", groupIcon: "shippingbox", groupColor: "#FF9500")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack(spacing: 0) {
                    MockNavBar(title: "Main Entrance", isDetail: true, trailingIcons: ["star.fill"])

                    List {
                        Section("Signal History") {
                            Picker("", selection: .constant("30m")) {
                                Text("5m").tag("5m")
                                Text("30m").tag("30m")
                                Text("1h").tag("1h")
                                Text("24h").tag("24h")
                                Text("All").tag("All")
                            }
                            .pickerStyle(.segmented)

                            RSSIChartView(dataPoints: MockData.chartDataPoints())

                            HStack {
                                VStack(spacing: 2) {
                                    Text("Avg").font(.caption2).foregroundStyle(.secondary)
                                    Text("-49 dBm").font(.system(.caption, design: .monospaced).bold())
                                }
                                Spacer()
                                VStack(spacing: 2) {
                                    Text("Min").font(.caption2).foregroundStyle(.secondary)
                                    Text("-60 dBm").font(.system(.caption, design: .monospaced).bold())
                                }
                                Spacer()
                                VStack(spacing: 2) {
                                    Text("Max").font(.caption2).foregroundStyle(.secondary)
                                    Text("-42 dBm").font(.system(.caption, design: .monospaced).bold())
                                }
                            }
                        }

                        Section("Recent Encounters (847)") {
                            ForEach(0..<5, id: \.self) { i in
                                let rssi = [-42, -48, -55, -44, -51]
                                let prox: [CLProximity] = [.immediate, .immediate, .near, .immediate, .near]
                                let times = ["10:42", "10:37", "10:32", "10:27", "10:22"]
                                HStack {
                                    Text(times[i]).font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                                    Spacer()
                                    BeaconSignalBars(rssi: rssi[i])
                                    Text("\(rssi[i]) dBm").font(.system(.caption2, design: .monospaced)).frame(width: 60, alignment: .trailing)
                                    ProximityBadge(proximity: prox[i])
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Previews (iPhone 6.7")

#Preview("1 - Scanner Radar", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_ScannerRadar()
}

#Preview("2 - Beacon List", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_BeaconList()
}

#Preview("3 - Fleet Management", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_FleetManagement()
}

#Preview("4 - Signal Analytics", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_SignalAnalytics()
}

#Preview("5 - Broadcast", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_Broadcast()
}

#Preview("6 - Onboarding", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_Onboarding()
}

#Preview("7 - Settings", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_Settings()
}

#Preview("8 - Dark Mode", traits: .fixedLayout(width: 430, height: 932)) {
    Screenshot_DarkModeRadar()
        .environment(\.colorScheme, .dark)
}

// iPad Previews (12.9")
#Preview("iPad 1 - Scanner", traits: .fixedLayout(width: 1024, height: 1366)) {
    Screenshot_iPad_ScannerRadar()
}

#Preview("iPad 2 - Analytics", traits: .fixedLayout(width: 1024, height: 1366)) {
    Screenshot_iPad_Analytics()
}

#endif
