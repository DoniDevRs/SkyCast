import Foundation

struct WeatherModel {
    let cityName: String
    let latitude: Double
    let longitude: Double
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}

struct CurrentWeather {
    let temperature: Double
    let apparentTemperature: Double
    let weatherCode: Int
    let windSpeed: Double
    let humidity: Int
    let precipitation: Double
    let condition: WeatherCondition
}

struct HourlyWeather {
    let time: Date
    let temperature: Double
    let weatherCode: Int
    let precipitationProbability: Int
    let condition: WeatherCondition
}

struct DailyWeather {
    let time: Date
    let weatherCode: Int
    let maxTemperature: Double
    let minTemperature: Double
    let precipitationSum: Double
    let uvIndexMax: Double
    let condition: WeatherCondition
}

struct WeatherCondition {
    let description: String
    let sfSymbol: String

    static func from(code: Int) -> WeatherCondition {
        switch code {
        case 0:
            return WeatherCondition(description: "Clear Sky", sfSymbol: "sun.max.fill")
        case 1, 2:
            return WeatherCondition(description: "Partly Cloudy", sfSymbol: "cloud.sun.fill")
        case 3:
            return WeatherCondition(description: "Overcast", sfSymbol: "cloud.fill")
        case 45, 48:
            return WeatherCondition(description: "Foggy", sfSymbol: "cloud.fog.fill")
        case 51, 53, 55:
            return WeatherCondition(description: "Drizzle", sfSymbol: "cloud.drizzle.fill")
        case 61, 63, 65:
            return WeatherCondition(description: "Rain", sfSymbol: "cloud.rain.fill")
        case 71, 73, 75:
            return WeatherCondition(description: "Snow", sfSymbol: "cloud.snow.fill")
        case 77:
            return WeatherCondition(description: "Snow Grains", sfSymbol: "cloud.snow.fill")
        case 80, 81, 82:
            return WeatherCondition(description: "Rain Showers", sfSymbol: "cloud.heavyrain.fill")
        case 85, 86:
            return WeatherCondition(description: "Snow Showers", sfSymbol: "cloud.snow.fill")
        case 95:
            return WeatherCondition(description: "Thunderstorm", sfSymbol: "cloud.bolt.fill")
        case 96, 99:
            return WeatherCondition(description: "Thunderstorm with Hail", sfSymbol: "cloud.bolt.rain.fill")
        default:
            return WeatherCondition(description: "Unknown", sfSymbol: "cloud.fill")
        }
    }
}
