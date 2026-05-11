import SwiftUI

struct UUIDEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (UUID) -> Void

    @State private var uuidText = ""
    @State private var showError = false
    @State private var errorMessage = ""

    private let defaultUUID = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter UUID", text: $uuidText)
                        .font(.system(.body, design: .monospaced))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                } header: {
                    Text("Beacon UUID")
                } footer: {
                    Text("Enter a valid UUID to scan for beacons broadcasting with this identifier.")
                }

                Section {
                    Button {
                        if let clipboard = UIPasteboard.general.string {
                            uuidText = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    } label: {
                        Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                    }

                    Button {
                        uuidText = defaultUUID
                    } label: {
                        Label("Use Sample UUID", systemImage: "wand.and.stars")
                    }

                    Button {
                        uuidText = UUID().uuidString
                    } label: {
                        Label("Generate Random UUID", systemImage: "dice")
                    }
                }

                if uuidText.count == 10, uuidText.allSatisfy(\.isNumber) {
                    Section("10-Digit Conversion") {
                        let converted = String.convertToUUID(uuidText)
                        Text(converted)
                            .font(.system(.caption, design: .monospaced))
                        Button("Use Converted UUID") {
                            uuidText = converted
                        }
                    }
                }
            }
            .navigationTitle("Add UUID")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Scan") { submit() }
                        .bold()
                        .disabled(uuidText.isEmpty)
                }
            }
            .alert("Invalid UUID", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func submit() {
        let trimmed = uuidText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let uuid = UUID(uuidString: trimmed) else {
            errorMessage = "The entered text is not a valid UUID format."
            showError = true
            return
        }
        onAdd(uuid)
        dismiss()
    }
}
