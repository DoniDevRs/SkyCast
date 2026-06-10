import WidgetKit
import SwiftUI

struct SkyCastProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        completion(WeatherEntry.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        Task {
            let entry = await fetchWeatherEntry()
            let nextUpdate = Calendar.current.date(
                byAdding: .minute,
                value: 30,
                to: Date()
            ) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchWeatherEntry() async -> WeatherEntry {
        guard let savedData = UserDefaults(suiteName: "group.com.donidevrs.skycast")?
            .data(forKey: "selected_city"),
              let city = try? JSONDecoder().decode(SavedCity.self, from: savedData)
        else {
            return WeatherEntry.placeholder
        }

        do {
            let httpClient = HTTPClientImpl()
            let repository = WeatherRepositoryImpl(httpClient: httpClient)
            let dto = try await repository.fetchWeather(
                latitude: city.latitude,
                longitude: city.longitude
            )

            let model = WeatherMapper.map(
                dto: dto,
                cityName: city.name,
                latitude: city.latitude,
                longitude: city.longitude
            )

            let hourlyData = Array(model.hourly.prefix(5)).map { hour in
                HourlyWidgetData(
                    time: hour.time,
                    temperature: Int(hour.temperature),
                    condition: hour.condition
                )
            }

            return WeatherEntry(
                date: Date(),
                cityName: model.cityName,
                temperature: Int(model.current.temperature),
                condition: model.current.condition,
                highTemp: Int(model.daily.first?.maxTemperature ?? 0),
                lowTemp: Int(model.daily.first?.minTemperature ?? 0),
                hourly: hourlyData
            )

        } catch {
            return WeatherEntry.placeholder
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: WeatherEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a2a4a"), Color(hex: "0d1525")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(entry.cityName.uppercased())
                    .foregroundStyle(.white.opacity(0.5))
                    .font(.system(size: 8, weight: .semibold))
                    .tracking(0.5)
                    .lineLimit(1)

                Spacer()

                Image(systemName: entry.condition.sfSymbol)
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolRenderingMode(.multicolor)

                Spacer()

                Text("\(entry.temperature)°")
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .thin))
                    .kerning(-1)

                Text("H:\(entry.highTemp)° L:\(entry.lowTemp)°")
                    .foregroundStyle(.white.opacity(0.4))
                    .font(.system(size: 8))
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: WeatherEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.cityName.uppercased())
                .foregroundStyle(.white.opacity(0.5))
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.5)
                .padding(.bottom, 2)
            
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(entry.temperature)°")
                    .foregroundStyle(.white)
                    .font(.system(size: 36, weight: .thin))
                    .kerning(-2)
                
                Image(systemName: entry.condition.sfSymbol)
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolRenderingMode(.multicolor)
                    .padding(.bottom, 6)
            }
            
            Text(entry.condition.description)
                .foregroundStyle(.white.opacity(0.5))
                .font(.system(size: 10))
            
            Text("H:\(entry.highTemp)° L:\(entry.lowTemp)°")
                .foregroundStyle(.white.opacity(0.3))
                .font(.system(size: 9))
                .padding(.bottom, 4)
            
            Divider()
                .background(.white.opacity(0.1))
                .padding(.bottom, 4)
            
            HStack(spacing: 0) {
                ForEach(entry.hourly, id: \.time) { hour in
                    VStack(spacing: 3) {
                        Text(hour.time.toHourString())
                            .foregroundStyle(.white.opacity(0.3))
                            .font(.system(size: 8))
                        
                        Image(systemName: hour.condition.sfSymbol)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.8))
                            .symbolRenderingMode(.multicolor)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
}

// MARK: - Widget Configuration

@main
struct SkyCastWidget: Widget {
    let kind: String = "SkyCastWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SkyCastProvider()) { entry in
            widgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(hex: "1a2a4a"), Color(hex: "0d1525")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("SkyCast")
        .description("Current weather at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }

    @ViewBuilder
    private func widgetView(entry: WeatherEntry) -> some View {
        GeometryReader { geo in
            if geo.size.width > 160 {
                MediumWidgetView(entry: entry)
            } else {
                SmallWidgetView(entry: entry)
            }
        }
    }
}
