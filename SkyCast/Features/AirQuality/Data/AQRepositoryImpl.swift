import Foundation

final class AQRepositoryImpl: AQRepository {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient = HTTPClientImpl()) {
        self.httpClient = httpClient
    }
    
    func fetchAirQuality(
        latitude: Double,
        longitude: Double
    ) async throws -> AQResponseDTO {
        let url = try URLBuilder(baseURL: "https://air-quality-api.open-meteo.com/v1/air-quality")
            .addParameter("latitude", value: String(latitude))
            .addParameter("longitude", value: String(longitude))
            .addParameter("hourly", value: "pm10,pm2_5,nitrogen_dioxide,ozone")
            .addParameter("forecast_days", value: "1")
            .build()
        
        return try await httpClient.get(url: url, responseType: AQResponseDTO.self)
    }
}
