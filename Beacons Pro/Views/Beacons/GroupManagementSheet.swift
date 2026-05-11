import SwiftUI
import SwiftData

struct GroupManagementSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BeaconGroup.dateCreated) private var groups: [BeaconGroup]

    @State private var newGroupName = ""
    @State private var newGroupColor = "#34C759"
    @State private var newGroupIcon = "folder.fill"

    private let iconOptions = [
        "folder.fill", "building.2", "car.fill", "house.fill",
        "tag.fill", "mappin", "cube.fill", "shippingbox.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Create Group") {
                    TextField("Group Name", text: $newGroupName)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.subheadline)
                        ColorTagPicker(selectedHex: $newGroupColor)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(icon == newGroupIcon ? Color(hex: newGroupColor) : .secondary)
                                    .padding(8)
                                    .background(icon == newGroupIcon ? Color(hex: newGroupColor).opacity(0.15) : .clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture { newGroupIcon = icon }
                            }
                        }
                    }

                    Button("Add Group") {
                        guard !newGroupName.isEmpty else { return }
                        let group = BeaconGroup(name: newGroupName, colorHex: newGroupColor, iconName: newGroupIcon)
                        modelContext.insert(group)
                        try? modelContext.save()
                        newGroupName = ""
                        HapticsService.tap()
                    }
                    .disabled(newGroupName.isEmpty)
                }

                if !groups.isEmpty {
                    Section("Existing Groups") {
                        ForEach(groups) { group in
                            HStack {
                                Image(systemName: group.iconName)
                                    .foregroundStyle(Color(hex: group.colorHex))
                                Text(group.name)
                                Spacer()
                                Text("\(group.beacons.count) beacons")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(groups[index])
                            }
                            try? modelContext.save()
                        }
                    }
                }
            }
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
