import SwiftUI
import Charts

struct HourlyForecastView: View {
    let hourly: [HourlyWeather]

    private var next24Hours: [HourlyWeather] {
        let now = Date()
        return Array(
            hourly
                .filter { $0.time >= now }
                .prefix(24)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader

            hourlyStrip

            temperatureChart
        }
        .padding(14)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Header

    private var sectionHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
            Text("Hourly Forecast")
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 10, weight: .medium))
                .tracking(1)
        }
    }

    // MARK: - Hourly Strip

    private var hourlyStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(next24Hours, id: \.time) { item in
                    hourItem(item: item)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func hourItem(item: HourlyWeather) -> some View {
        let isNow = Calendar.current.isDate(item.time, equalTo: Date(), toGranularity: .hour)

        return VStack(spacing: 6) {
            Text(isNow ? "Now" : item.time.toHourString())
                .foregroundStyle(isNow ? .white : .white.opacity(0.5))
                .font(.system(size: 10, weight: isNow ? .semibold : .regular))

            Image(systemName: item.condition.sfSymbol)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.9))
                .symbolRenderingMode(.multicolor)

            if item.precipitationProbability > 20 {
                Text("\(item.precipitationProbability)%")
                    .foregroundStyle(Color(hex: "7DB8F7"))
                    .font(.system(size: 9))
            } else {
                Text(" ")
                    .font(.system(size: 9))
            }

            Text("\(Int(item.temperature))°")
                .foregroundStyle(.white)
                .font(.system(size: 13, weight: .semibold))
        }
        .frame(width: 44)
        .padding(.vertical, 8)
        .background(isNow ? .white.opacity(0.12) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Temperature Chart

    private var temperatureChart: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Temperature — next 24h")
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 9, weight: .medium))
                .tracking(0.5)

            Chart {
                ForEach(next24Hours, id: \.time) { item in
                    LineMark(
                        x: .value("Time", item.time),
                        y: .value("Temp", item.temperature)
                    )
                    .foregroundStyle(Color(hex: "7DB8F7"))
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Time", item.time),
                        y: .value("Temp", item.temperature)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "7DB8F7").opacity(0.3),
                                Color(hex: "7DB8F7").opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.toHourString())
                                .foregroundStyle(.white.opacity(0.4))
                                .font(.system(size: 9))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let temp = value.as(Double.self) {
                            Text("\(Int(temp))°")
                                .foregroundStyle(.white.opacity(0.4))
                                .font(.system(size: 9))
                        }
                    }
                }
            }
            .frame(height: 80)
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "1a2a4a").ignoresSafeArea()
        HourlyForecastView(hourly: [])
            .padding()
    }
}
