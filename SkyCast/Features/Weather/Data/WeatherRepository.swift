import Foundation
import CoreLocation

protocol WeatherRepository {
    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> WeatherResponseDTO
}
