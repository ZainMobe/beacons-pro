import SwiftUI
import SwiftData

struct ScannerTab: View {
    @Environment(BeaconScannerService.self) private var scannerService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ScannerViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ScannerContentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Scanner")
        .onAppear {
            if viewModel == nil {
                viewModel = ScannerViewModel(scannerService: scannerService, modelContext: modelContext)
            }
        }
    }
}

private struct ScannerContentView: View {
    @Bindable var viewModel: ScannerViewModel
    @State private var showRadar = true

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.activeUUIDs.isEmpty {
                uuidChipsBar
            }

            if viewModel.discoveredBeacons.isEmpty {
                Spacer()
                if viewModel.isScanning {
                    VStack(spacing: 20) {
                        RadarPulseView()
                        Text("Scanning for beacons...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    EmptyStateView(
                        icon: "sensor.tag.radiowaves.forward.fill",
                        title: "No Beacons Found",
                        subtitle: "Add a UUID and start scanning to discover nearby beacons."
                    )
                }
                Spacer()
            } else {
                if showRadar {
                    BeaconRadarView(beacons: viewModel.filteredBeacons)
                        .padding(.vertical, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                beaconList
            }

            scanButton
        }
        .sheet(isPresented: $viewModel.showUUIDEntry) {
            UUIDEntrySheet { uuid in
                viewModel.addUUIDAndStartScanning(uuid)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !viewModel.discoveredBeacons.isEmpty {
                    Button {
                        withAnimation { showRadar.toggle() }
                    } label: {
                        Image(systemName: showRadar ? "circle.grid.3x3.fill" : "dot.scope")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showUUIDEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort", selection: $viewModel.sortOrder) {
                        ForEach(ScannerViewModel.SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
    }

    private var uuidChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.activeUUIDs, id: \.self) { uuid in
                    HStack(spacing: 4) {
                        if viewModel.isScanning {
                            PulsingDot(color: .green)
                        }
                        Text(uuid.shortString)
                            .font(.system(.caption, design: .monospaced))
                        Button {
                            viewModel.removeUUID(uuid)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.accentColor.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    private var beaconList: some View {
        List {
            ForEach(viewModel.filteredBeacons) { beacon in
                DiscoveredBeaconRow(
                    beacon: beacon,
                    isSaved: viewModel.isBeaconSaved(beacon),
                    onSave: {
                        _ = viewModel.saveBeacon(beacon)
                    }
                )
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = beacon.beaconUUID.uuidString
                        HapticsService.tap()
                    } label: {
                        Label("Copy UUID", systemImage: "doc.on.doc")
                    }

                    Button {
                        UIPasteboard.general.string = "UUID: \(beacon.beaconUUID.uuidString)\nMajor: \(beacon.major)\nMinor: \(beacon.minor)\nRSSI: \(beacon.rssi) dBm\nDistance: \(String(format: "%.2f", beacon.accuracy))m"
                        HapticsService.tap()
                    } label: {
                        Label("Copy Details", systemImage: "doc.on.clipboard")
                    }

                    if !viewModel.isBeaconSaved(beacon) {
                        Button {
                            _ = viewModel.saveBeacon(beacon)
                        } label: {
                            Label("Save Beacon", systemImage: "square.and.arrow.down")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: "Search beacons")
        .onChange(of: viewModel.discoveredBeacons) {
            viewModel.recordEncounters()
        }
    }

    private var scanButton: some View {
        Button {
            viewModel.toggleScanning()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isScanning ? "stop.fill" : "play.fill")
                Text(viewModel.isScanning ? "Stop Scanning" : "Start Scanning")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(viewModel.isScanning ? .red : Theme.accentColor)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }
}
