import SwiftUI

struct ColorTagPicker: View {
    @Binding var selectedHex: String

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Theme.tagColors, id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 28, height: 28)
                    .overlay {
                        if hex == selectedHex {
                            Circle()
                                .strokeBorder(.white, lineWidth: 2)
                                .frame(width: 22, height: 22)
                        }
                    }
                    .onTapGesture {
                        selectedHex = hex
                        HapticsService.tap()
                    }
            }
        }
    }
}
