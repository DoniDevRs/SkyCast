import Foundation

@Observable
final class AQViewModel {
    private let aqRepository: AQRepository

    var airQuality: AQModel?
    var isLoading: Bool = false
    var errorMessage: String?

    init(aqRepository: AQRepository = AQRepositoryImpl()) {
        self.aqRepository = aqRepository
    }

    func loadAirQuality(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil

        do {
            let dto = try await aqRepository.fetchAirQuality(
                latitude: latitude,
                longitude: longitude
            )

            let model = AQMapper.map(
                dto: dto,
                locationName: "Nearby Station"
            )

            await MainActor.run {
                self.airQuality = model
                self.isLoading = false
            }

        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func refresh(latitude: Double, longitude: Double) async {
        await loadAirQuality(latitude: latitude, longitude: longitude)
    }
}
