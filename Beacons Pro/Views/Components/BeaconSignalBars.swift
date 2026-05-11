import SwiftUI

struct BeaconSignalBars: View {
    let rssi: Int
    private let barCount = 4

    private var filledBars: Int {
        switch rssi {
        case -50...0: 4
        case -65 ..< -50: 3
        case -80 ..< -65: 2
        case -95 ..< -80: 1
        default: 0
        }
    }

    private var signalColor: Color {
        Theme.rssiColor(for: rssi)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(index < filledBars ? signalColor : Color.gray.opacity(0.3))
                    .frame(width: 4, height: CGFloat(6 + index * 4))
            }
        }
        .frame(height: 20)
    }
}
