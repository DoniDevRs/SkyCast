import Foundation

struct WeatherResponseDTO: Decodable {
    let current: CurrentDTO
    let hourly: HourlyDTO
    let daily: DailyDTO
}

struct CurrentDTO: Decodable {
    let temperature2m: Double
    let apparentTemperature: Double
    let weathercode: Int
    let windspeed10m: Double
    let relativeHumidity2m: Int
    let precipitation: Double

    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case weathercode
        case windspeed10m = "windspeed_10m"
        case relativeHumidity2m = "relative_humidity_2m"
        case precipitation
    }
}

struct HourlyDTO: Decodable {
    let time: [String]
    let temperature2m: [Double]
    let weathercode: [Int]
    let precipitationProbability: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weathercode
        case precipitationProbability = "precipitation_probability"
    }
}

struct DailyDTO: Decodable {
    let time: [String]
    let weathercode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationSum: [Double]
    let uvIndexMax: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weathercode
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case uvIndexMax = "uv_index_max"
    }
}
