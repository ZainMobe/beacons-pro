import SwiftUI

struct RadarPulseView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(Theme.accentColor.opacity(0.3), lineWidth: 2)
                    .scaleEffect(animate ? 2.5 : 0.5)
                    .opacity(animate ? 0 : 0.8)
                    .animation(
                        .easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.6),
                        value: animate
                    )
            }

            Circle()
                .fill(Theme.accentColor)
                .frame(width: 16, height: 16)
                .shadow(color: Theme.accentColor.opacity(0.5), radius: 8)

            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                .font(.system(size: 24))
                .foregroundStyle(Theme.accentColor)
                .offset(y: -50)
                .opacity(animate ? 1 : 0.5)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
        }
        .frame(width: 200, height: 200)
        .onAppear { animate = true }
    }
}
