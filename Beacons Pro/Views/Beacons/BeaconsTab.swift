import SwiftUI
import SwiftData

struct BeaconsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedBeacon.dateAdded, order: .reverse) private var allBeacons: [SavedBeacon]
    @Query(sort: \BeaconGroup.dateCreated) private var groups: [BeaconGroup]
    @State private var viewModel: BeaconFleetViewModel?
    @State private var searchText = ""
    @State private var showAddBeacon = false
    @State private var showGroupManagement = false

    private var ungroupedBeacons: [SavedBeacon] {
        let filtered = allBeacons.filter { $0.group == nil }
        if searchText.isEmpty { return filtered }
        return filtered.filter { matches($0) }
    }

    private func groupBeacons(_ group: BeaconGroup) -> [SavedBeacon] {
        let beacons = group.beacons
        if searchText.isEmpty { return beacons }
        return beacons.filter { matches($0) }
    }

    private func matches(_ beacon: SavedBeacon) -> Bool {
        beacon.displayName.localizedCaseInsensitiveContains(searchText) ||
        beacon.uuid.uuidString.localizedCaseInsensitiveContains(searchText)
    }

    var body: some View {
        Group {
            if allBeacons.isEmpty {
                EmptyStateView(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "No Saved Beacons",
                    subtitle: "Save beacons from the Scanner tab or add one manually."
                )
            } else {
                beaconList
            }
        }
        .navigationTitle("Beacons")
        .searchable(text: $searchText, prompt: "Search beacons")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showAddBeacon = true
                    } label: {
                        Label("Add Beacon", systemImage: "plus")
                    }
                    Button {
                        showGroupManagement = true
                    } label: {
                        Label("Manage Groups", systemImage: "folder.badge.gearshape")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddBeacon) {
            AddBeaconSheet()
        }
        .sheet(isPresented: $showGroupManagement) {
            GroupManagementSheet()
        }
        .navigationDestination(for: SavedBeacon.self) { beacon in
            BeaconDetailView(beacon: beacon)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = BeaconFleetViewModel(modelContext: modelContext)
            }
        }
    }

    private var beaconList: some View {
        List {
            let ungrouped = ungroupedBeacons
            if !ungrouped.isEmpty {
                Section("Ungrouped") {
                    ForEach(ungrouped) { beacon in
                        NavigationLink(value: beacon) {
                            BeaconCardView(beacon: beacon)
                        }
                        .beaconContextMenu(beacon: beacon, groups: groups, modelContext: modelContext)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(ungrouped[index])
                        }
                        try? modelContext.save()
                    }
                }
            }

            ForEach(groups) { group in
                let beacons = groupBeacons(group)
                if !beacons.isEmpty {
                    Section {
                        ForEach(beacons) { beacon in
                            NavigationLink(value: beacon) {
                                BeaconCardView(beacon: beacon)
                            }
                            .beaconContextMenu(beacon: beacon, groups: groups, modelContext: modelContext)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(beacons[index])
                            }
                            try? modelContext.save()
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: group.iconName)
                                .foregroundStyle(Color(hex: group.colorHex))
                            Text(group.name)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
