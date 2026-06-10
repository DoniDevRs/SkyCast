import WidgetKit
import SwiftUI

struct WeatherEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: Int
    let condition: WeatherCondition
    let highTemp: Int
    let lowTemp: Int
    let hourly: [HourlyWidgetData]
}

struct HourlyWidgetData {
    let time: Date
    let temperature: Int
    let condition: WeatherCondition
}

extension WeatherEntry {
    static var placeholder: WeatherEntry {
        WeatherEntry(
            date: Date(),
            cityName: "São Paulo",
            temperature: 24,
            condition: WeatherCondition(
                description: "Partly Cloudy",
                sfSymbol: "cloud.sun.fill"
            ),
            highTemp: 28,
            lowTemp: 19,
            hourly: (0..<5).map { i in
                HourlyWidgetData(
                    time: Date().addingTimeInterval(Double(i) * 3600),
                    temperature: 24 + i,
                    condition: WeatherCondition(
                        description: "Partly Cloudy",
                        sfSymbol: "cloud.sun.fill"
                    )
                )
            }
        )
    }
}
