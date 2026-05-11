import SwiftUI
import Charts

struct RSSIChartView: View {
    let dataPoints: [(date: Date, rssi: Int)]

    var body: some View {
        if dataPoints.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                Text("No signal data yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 200)
        } else {
            Chart(dataPoints, id: \.date) { point in
                LineMark(
                    x: .value("Time", point.date),
                    y: .value("RSSI", point.rssi)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Theme.accentColor)

                AreaMark(
                    x: .value("Time", point.date),
                    y: .value("RSSI", point.rssi)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.accentColor.opacity(0.2), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartYScale(domain: -100 ... -20)
            .chartYAxis {
                AxisMarks(values: [-100, -80, -60, -40, -20]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            Text("\(intVal)")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .frame(height: 200)
        }
    }
}
