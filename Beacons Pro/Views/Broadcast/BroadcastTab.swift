import SwiftUI
import SwiftData

struct BroadcastTab: View {
    @Environment(BeaconBroadcasterService.self) private var broadcasterService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BroadcastProfile.dateCreated, order: .reverse) private var profiles: [BroadcastProfile]
    @State private var viewModel: BroadcastViewModel?

    var body: some View {
        Group {
            if let viewModel {
                BroadcastContent(viewModel: viewModel, profiles: profiles)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Broadcast")
        .onAppear {
            if viewModel == nil {
                viewModel = BroadcastViewModel(broadcasterService: broadcasterService, modelContext: modelContext)
            }
        }
    }
}

private struct BroadcastContent: View {
    @Bindable var viewModel: BroadcastViewModel
    let profiles: [BroadcastProfile]

    var body: some View {
        Form {
            Section {
                BroadcastStatusView(isActive: viewModel.isBroadcasting)
                if viewModel.isBroadcasting {
                    Button("Stop Broadcasting", role: .destructive) {
                        viewModel.stopBroadcasting()
                    }
                }
            }

            if !viewModel.isBroadcasting {
                Section("Quick Broadcast") {
                    TextField("UUID", text: $viewModel.quickUUID)
                        .font(.system(.body, design: .monospaced))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    HStack {
                        TextField("Major", text: $viewModel.quickMajor)
                            .keyboardType(.numberPad)
                        TextField("Minor", text: $viewModel.quickMinor)
                            .keyboardType(.numberPad)
                    }

                    Button {
                        viewModel.generateRandomUUID()
                    } label: {
                        Label("Generate Random UUID", systemImage: "dice")
                    }

                    Button {
                        viewModel.startQuickBroadcast()
                    } label: {
                        Label("Start Broadcasting", systemImage: "play.fill")
                    }
                    .disabled(viewModel.quickUUID.isEmpty)
                }
            }

            Section {
                if profiles.isEmpty {
                    Text("No saved profiles")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(profiles) { profile in
                        BroadcastProfileRow(
                            profile: profile,
                            isActive: viewModel.activeProfile?.persistentModelID == profile.persistentModelID && viewModel.isBroadcasting,
                            onStart: {
                                if viewModel.isBroadcasting && viewModel.activeProfile?.persistentModelID == profile.persistentModelID {
                                    viewModel.stopBroadcasting()
                                } else {
                                    viewModel.startBroadcasting(profile: profile)
                                }
                            }
                        )
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteProfile(profile)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                Text("Saved Profiles")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showProfileEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showProfileEditor) {
            BroadcastProfileSheet { uuid, major, minor, name in
                viewModel.saveProfile(uuid: uuid, major: major, minor: minor, name: name)
            }
        }
        .alert("Invalid UUID", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text("Please enter a valid UUID format.")
        }
    }
}
