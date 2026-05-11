import SwiftUI
import SwiftData

struct SettingsTab: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("autoRecordEncounters") private var autoRecord = true
    @AppStorage("encounterInterval") private var encounterInterval = 5
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    @State private var showClearConfirm = false
    @State private var showExportJSON = false
    @State private var showExportCSV = false
    @State private var exportedData: Data?
    @State private var exportFileName = ""

    @Query private var beaconCount: [SavedBeacon]
    @Query private var encounterCount: [BeaconEncounter]

    var body: some View {
        Form {
            Section("Scanning") {
                Toggle("Auto-record encounters", isOn: $autoRecord)
                Stepper("Record interval: \(encounterInterval)s", value: $encounterInterval, in: 1...30)
                Toggle("Haptic feedback", isOn: $hapticsEnabled)
            }

            Section("Data") {
                LabeledContent("Saved Beacons", value: "\(beaconCount.count)")
                LabeledContent("Total Encounters", value: "\(encounterCount.count)")

                Button {
                    exportJSON()
                } label: {
                    Label("Export Beacons (JSON)", systemImage: "doc.text")
                }

                Button {
                    exportCSV()
                } label: {
                    Label("Export Encounters (CSV)", systemImage: "tablecells")
                }

                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Label("Clear All Encounter History", systemImage: "trash")
                }
            }

            Section("About") {
                LabeledContent("Version", value: "2.0.0")
                LabeledContent("Build", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1")

                Link(destination: URL(string: "https://www.developerzain.com")!) {
                    Label("Developer Website", systemImage: "globe")
                }

                Link(destination: URL(string: "mailto:zainpk121@icloud.com")!) {
                    Label("Contact", systemImage: "envelope")
                }

                Link(destination: URL(string: "https://www.linkedin.com/in/developer-zain")!) {
                    Label("LinkedIn", systemImage: "person.circle")
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Clear History", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear All Encounters", role: .destructive) {
                clearEncounters()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all encounter history. Saved beacons will not be affected.")
        }
        .sheet(isPresented: $showExportJSON) {
            if let data = exportedData {
                ShareSheet(data: data, fileName: exportFileName)
            }
        }
        .sheet(isPresented: $showExportCSV) {
            if let data = exportedData {
                ShareSheet(data: data, fileName: exportFileName)
            }
        }
    }

    private func exportJSON() {
        do {
            exportedData = try ExportService.exportBeaconsJSON(from: modelContext)
            exportFileName = "beacons_export.json"
            showExportJSON = true
        } catch {
            print("Export failed: \(error)")
        }
    }

    private func exportCSV() {
        do {
            exportedData = try ExportService.exportEncountersCSV(from: modelContext)
            exportFileName = "encounters_export.csv"
            showExportCSV = true
        } catch {
            print("Export failed: \(error)")
        }
    }

    private func clearEncounters() {
        let descriptor = FetchDescriptor<BeaconEncounter>()
        if let encounters = try? modelContext.fetch(descriptor) {
            for encounter in encounters {
                modelContext.delete(encounter)
            }
            try? modelContext.save()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let data: Data
    let fileName: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: tempURL)
        return UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
