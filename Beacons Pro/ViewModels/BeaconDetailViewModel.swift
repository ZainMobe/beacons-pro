import Foundation
import SwiftData
import Observation

@Observable
final class BeaconDetailViewModel {
    var beacon: SavedBeacon
    var chartTimeWindow: TimeWindow = .lastHour
    var encounters: [BeaconEncounter] = []
    var isEditing = false
    var editedName = ""
    var editedNotes = ""

    private let modelContext: ModelContext

    enum TimeWindow: String, CaseIterable {
        case last5Minutes = "5m"
        case last30Minutes = "30m"
        case lastHour = "1h"
        case last24Hours = "24h"
        case all = "All"

        var dateOffset: Date? {
            switch self {
            case .last5Minutes: Calendar.current.date(byAdding: .minute, value: -5, to: .now)
            case .last30Minutes: Calendar.current.date(byAdding: .minute, value: -30, to: .now)
            case .lastHour: Calendar.current.date(byAdding: .hour, value: -1, to: .now)
            case .last24Hours: Calendar.current.date(byAdding: .hour, value: -24, to: .now)
            case .all: nil
            }
        }
    }

    init(beacon: SavedBeacon, modelContext: ModelContext) {
        self.beacon = beacon
        self.modelContext = modelContext
        self.editedName = beacon.customName
        self.editedNotes = beacon.notes
        loadEncounters()
    }

    func loadEncounters() {
        let beaconID = beacon.persistentModelID
        var descriptor = FetchDescriptor<BeaconEncounter>(
            predicate: #Predicate { $0.beacon?.persistentModelID == beaconID },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 500
        encounters = (try? modelContext.fetch(descriptor)) ?? []
    }

    var filteredEncounters: [BeaconEncounter] {
        guard let cutoff = chartTimeWindow.dateOffset else { return encounters }
        return encounters.filter { $0.timestamp >= cutoff }
    }

    var chartDataPoints: [(date: Date, rssi: Int)] {
        filteredEncounters
            .sorted { $0.timestamp < $1.timestamp }
            .map { (date: $0.timestamp, rssi: $0.rssi) }
    }

    var averageRSSI: Double? {
        let points = filteredEncounters
        guard !points.isEmpty else { return nil }
        return Double(points.reduce(0) { $0 + $1.rssi }) / Double(points.count)
    }

    var minRSSI: Int? {
        filteredEncounters.map(\.rssi).min()
    }

    var maxRSSI: Int? {
        filteredEncounters.map(\.rssi).max()
    }

    func saveEdits() {
        beacon.customName = editedName
        beacon.notes = editedNotes
        try? modelContext.save()
    }

    func updateColorTag(_ hex: String) {
        beacon.colorTag = hex
        try? modelContext.save()
    }

    func toggleFavorite() {
        beacon.isFavorite.toggle()
        try? modelContext.save()
    }
}
