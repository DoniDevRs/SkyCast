import Foundation
import CoreLocation

final class WeatherRepositoryImpl: WeatherRepository {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient = HTTPClientImpl()) {
        self.httpClient = httpClient
    }

    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> WeatherResponseDTO {
        let url = try URLBuilder(baseURL: "https://api.open-meteo.com/v1/forecast")
            .addParameter("latitude", value: String(latitude))
            .addParameter("longitude", value: String(longitude))
            .addParameter("current", value: "temperature_2m,apparent_temperature,weathercode,windspeed_10m,relative_humidity_2m,precipitation")
            .addParameter("hourly", value: "temperature_2m,weathercode,precipitation_probability")
            .addParameter("daily", value: "weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum,uv_index_max")
            .addParameter("timezone", value: "auto")
            .addParameter("forecast_days", value: "7")
            .build()

        return try await httpClient.get(url: url, responseType: WeatherResponseDTO.self)
    }
}
