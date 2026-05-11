import SwiftUI
import SwiftData

extension View {
    func beaconContextMenu(beacon: SavedBeacon, groups: [BeaconGroup], modelContext: ModelContext) -> some View {
        self.contextMenu {
            Button {
                UIPasteboard.general.string = beacon.uuid.uuidString
                HapticsService.tap()
            } label: {
                Label("Copy UUID", systemImage: "doc.on.doc")
            }

            Button {
                var details = "UUID: \(beacon.uuid.uuidString)"
                if let major = beacon.major { details += "\nMajor: \(major)" }
                if let minor = beacon.minor { details += "\nMinor: \(minor)" }
                if !beacon.customName.isEmpty { details += "\nName: \(beacon.customName)" }
                UIPasteboard.general.string = details
                HapticsService.tap()
            } label: {
                Label("Copy Details", systemImage: "doc.on.clipboard")
            }

            Divider()

            Button {
                beacon.isFavorite.toggle()
                try? modelContext.save()
            } label: {
                Label(
                    beacon.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: beacon.isFavorite ? "star.slash" : "star"
                )
            }

            if !groups.isEmpty {
                Menu {
                    Button {
                        beacon.group = nil
                        try? modelContext.save()
                    } label: {
                        Label("No Group", systemImage: "xmark")
                    }

                    ForEach(groups) { group in
                        Button {
                            beacon.group = group
                            try? modelContext.save()
                        } label: {
                            Label(group.name, systemImage: group.iconName)
                        }
                    }
                } label: {
                    Label("Move to Group", systemImage: "folder")
                }
            }

            Divider()

            Button(role: .destructive) {
                modelContext.delete(beacon)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
