import SwiftUI

struct BroadcastProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (UUID, UInt16, UInt16, String) -> Void

    @State private var name = ""
    @State private var uuidText = UUID().uuidString
    @State private var majorText = "0"
    @State private var minorText = "0"
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Profile Name", text: $name)
                }

                Section("Beacon Identity") {
                    TextField("UUID", text: $uuidText)
                        .font(.system(.body, design: .monospaced))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                    Button("Generate Random UUID") {
                        uuidText = UUID().uuidString
                    }
                }

                Section("Values") {
                    TextField("Major (0-65535)", text: $majorText)
                        .keyboardType(.numberPad)
                    TextField("Minor (0-65535)", text: $minorText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(name.isEmpty || uuidText.isEmpty)
                }
            }
            .alert("Invalid UUID", isPresented: $showError) {
                Button("OK") {}
            }
        }
    }

    private func save() {
        guard let uuid = UUID(uuidString: uuidText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            showError = true
            return
        }
        let major = UInt16(majorText) ?? 0
        let minor = UInt16(minorText) ?? 0
        onSave(uuid, major, minor, name)
        dismiss()
    }
}
