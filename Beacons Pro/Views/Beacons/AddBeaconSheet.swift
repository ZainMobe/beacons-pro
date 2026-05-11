import SwiftUI
import SwiftData

struct AddBeaconSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var uuidText = ""
    @State private var majorText = ""
    @State private var minorText = ""
    @State private var name = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Beacon Identity") {
                    TextField("UUID", text: $uuidText)
                        .font(.system(.body, design: .monospaced))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                    TextField("Major (optional)", text: $majorText)
                        .keyboardType(.numberPad)
                    TextField("Minor (optional)", text: $minorText)
                        .keyboardType(.numberPad)
                }

                Section("Details") {
                    TextField("Custom Name (optional)", text: $name)
                }

                Section {
                    Button("Generate Random UUID") {
                        uuidText = UUID().uuidString
                    }
                }
            }
            .navigationTitle("Add Beacon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addBeacon() }
                        .bold()
                        .disabled(uuidText.isEmpty)
                }
            }
            .alert("Invalid UUID", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text("Please enter a valid UUID format.")
            }
        }
    }

    private func addBeacon() {
        guard let uuid = UUID(uuidString: uuidText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            showError = true
            return
        }
        let major = UInt16(majorText)
        let minor = UInt16(minorText)
        let beacon = SavedBeacon(uuid: uuid, major: major, minor: minor, customName: name)
        modelContext.insert(beacon)
        try? modelContext.save()
        dismiss()
    }
}
