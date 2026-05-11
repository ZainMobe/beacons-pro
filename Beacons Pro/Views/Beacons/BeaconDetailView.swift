import SwiftUI
import SwiftData

struct BeaconDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: BeaconDetailViewModel?
    let beacon: SavedBeacon

    var body: some View {
        Group {
            if let viewModel {
                BeaconDetailContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(beacon.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = BeaconDetailViewModel(beacon: beacon, modelContext: modelContext)
            }
        }
    }
}

private struct BeaconDetailContent: View {
    @Bindable var viewModel: BeaconDetailViewModel

    var body: some View {
        List {
            identitySection
            metadataSection
            signalSection
            encounterSection
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.beacon.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(viewModel.beacon.isFavorite ? .yellow : .secondary)
                }
            }
        }
    }

    private var identitySection: some View {
        Section("Identity") {
            LabeledContent("UUID") {
                Text(viewModel.beacon.uuid.uuidString)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
            if let major = viewModel.beacon.major {
                LabeledContent("Major", value: "\(major)")
            }
            if let minor = viewModel.beacon.minor {
                LabeledContent("Minor", value: "\(minor)")
            }
            LabeledContent("Added", value: viewModel.beacon.dateAdded.mediumDateTimeString)
            if let lastSeen = viewModel.beacon.lastSeenDate {
                LabeledContent("Last Seen", value: lastSeen.relativeString)
            }
        }
    }

    private var metadataSection: some View {
        Section("Details") {
            TextField("Name", text: $viewModel.editedName)
                .onSubmit { viewModel.saveEdits() }
            TextField("Notes", text: $viewModel.editedNotes, axis: .vertical)
                .lineLimit(3...6)
                .onSubmit { viewModel.saveEdits() }

            VStack(alignment: .leading, spacing: 8) {
                Text("Color Tag")
                    .font(.subheadline)
                ColorTagPicker(selectedHex: Binding(
                    get: { viewModel.beacon.colorTag },
                    set: { viewModel.updateColorTag($0) }
                ))
            }
        }
    }

    private var signalSection: some View {
        Section {
            Picker("Time Window", selection: $viewModel.chartTimeWindow) {
                ForEach(BeaconDetailViewModel.TimeWindow.allCases, id: \.self) { window in
                    Text(window.rawValue).tag(window)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.chartTimeWindow) {
                viewModel.loadEncounters()
            }

            RSSIChartView(dataPoints: viewModel.chartDataPoints)

            if let avg = viewModel.averageRSSI,
               let min = viewModel.minRSSI,
               let max = viewModel.maxRSSI {
                HStack {
                    StatBadge(title: "Avg", value: "\(Int(avg)) dBm")
                    Spacer()
                    StatBadge(title: "Min", value: "\(min) dBm")
                    Spacer()
                    StatBadge(title: "Max", value: "\(max) dBm")
                }
            }
        } header: {
            Text("Signal History")
        }
    }

    private var encounterSection: some View {
        Section {
            if viewModel.filteredEncounters.isEmpty {
                Text("No encounters recorded")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.filteredEncounters.prefix(50)) { encounter in
                    HStack {
                        Text(encounter.timestamp.shortTimeString)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                        BeaconSignalBars(rssi: encounter.rssi)
                        Text("\(encounter.rssi) dBm")
                            .font(.system(.caption2, design: .monospaced))
                            .frame(width: 60, alignment: .trailing)
                        ProximityBadge(proximity: .init(rawValue: encounter.proximity) ?? .unknown)
                    }
                }
            }
        } header: {
            Text("Recent Encounters (\(viewModel.filteredEncounters.count))")
        }
    }
}

private struct StatBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.caption, design: .monospaced).bold())
        }
    }
}
