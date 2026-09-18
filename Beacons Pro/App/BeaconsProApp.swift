import SwiftUI
import SwiftData

@main
struct BeaconsProApp: App {
    @State private var scannerService = BeaconScannerService()
    @State private var broadcasterService = BeaconBroadcasterService()
    @State private var reviewPromptService = ReviewPromptService()

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: SavedBeacon.self, BeaconEncounter.self, BeaconGroup.self, BroadcastProfile.self)
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .reviewPromptHost()
                .environment(scannerService)
                .environment(broadcasterService)
                .environment(reviewPromptService)
                .task {
                    try? ExportService.purgeOldEncounters(olderThan: 30, from: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
