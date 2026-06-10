import Foundation

protocol AQRepository {
    func fetchAirQuality(
        latitude: Double,
        longitude: Double
    ) async throws -> AQResponseDTO
}
