import SwiftUI
import Charts

struct DailyForecastView: View {
    let daily: [DailyWeather]

    private var temperatureRange: ClosedRange<Double> {
        let allTemps = daily.flatMap { [$0.minTemperature, $0.maxTemperature] }
        let min = allTemps.min() ?? 0
        let max = allTemps.max() ?? 40
        return min...max
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader

            VStack(spacing: 0) {
                ForEach(Array(daily.enumerated()), id: \.offset) { index, item in
                    dayRow(item: item, isLast: index == daily.count - 1)
                }
            }
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
            Image(systemName: "calendar")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
            Text("7-Day Forecast")
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 10, weight: .medium))
                .tracking(1)
        }
    }

    // MARK: - Day Row

    private func dayRow(item: DailyWeather, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                dayName(item.time)

                Image(systemName: item.condition.sfSymbol)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolRenderingMode(.multicolor)
                    .frame(width: 20)

                precipitationLabel(item.precipitationSum)

                Spacer()

                temperatureRange(item: item)
            }
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .background(.white.opacity(0.08))
            }
        }
    }

    // MARK: - Day Name

    private func dayName(_ date: Date) -> some View {
        Group {
            if date.isToday {
                Text("Today")
            } else if date.isTomorrow {
                Text("Tomorrow")
            } else {
                Text(date.toDayNameString())
            }
        }
        .foregroundStyle(.white.opacity(0.8))
        .font(.system(size: 13, weight: .medium))
        .frame(width: 64, alignment: .leading)
    }

    // MARK: - Precipitation

    private func precipitationLabel(_ sum: Double) -> some View {
        Group {
            if sum > 0.5 {
                Text(String(format: "%.1fmm", sum))
                    .foregroundStyle(Color(hex: "7DB8F7"))
                    .font(.system(size: 10))
            } else {
                Text("")
                    .font(.system(size: 10))
            }
        }
        .frame(width: 36, alignment: .trailing)
    }

    // MARK: - Temperature Range

    private func temperatureRange(item: DailyWeather) -> some View {
        HStack(spacing: 6) {
            Text("\(Int(item.minTemperature))°")
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 12))
                .frame(width: 28, alignment: .trailing)

            rangeBar(item: item)
                .frame(width: 60, height: 4)

            Text("\(Int(item.maxTemperature))°")
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 28, alignment: .leading)
        }
    }

    private func rangeBar(item: DailyWeather) -> some View {
        GeometryReader { geo in
            let range = temperatureRange
            let totalRange = range.upperBound - range.lowerBound
            guard totalRange > 0 else {
                return AnyView(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.1))
                )
            }

            let startFraction = (item.minTemperature - range.lowerBound) / totalRange
            let widthFraction = (item.maxTemperature - item.minTemperature) / totalRange

            return AnyView(
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: barColors(item: item),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * widthFraction)
                        .offset(x: geo.size.width * startFraction)
                }
            )
        }
    }

    private func barColors(item: DailyWeather) -> [Color] {
        switch item.maxTemperature {
        case ..<10:
            return [Color(hex: "60a5fa"), Color(hex: "818cf8")]
        case 10..<20:
            return [Color(hex: "60a5fa"), Color(hex: "34d399")]
        case 20..<30:
            return [Color(hex: "fbbf24"), Color(hex: "f97316")]
        default:
            return [Color(hex: "f97316"), Color(hex: "ef4444")]
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "1a2a4a").ignoresSafeArea()
        DailyForecastView(daily: [])
            .padding()
    }
}
