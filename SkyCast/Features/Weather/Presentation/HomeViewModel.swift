import Foundation
import CoreLocation

@Observable
final class HomeViewModel {
    private let weatherRepository: WeatherRepository
    private let locationService: LocationService

    var weather: WeatherModel?
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedCity: SavedCity?

    init(
        weatherRepository: WeatherRepository = WeatherRepositoryImpl(),
        locationService: LocationService = LocationServiceImpl()
    ) {
        self.weatherRepository = weatherRepository
        self.locationService = locationService
        loadSavedCity()
    }

    func loadWeather() async {
        isLoading = true
        errorMessage = nil

        do {
            let location = try await resolveLocation()
            let cityName = await resolveCityName(from: location)

            let dto = try await weatherRepository.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )

            let model = WeatherMapper.map(
                dto: dto,
                cityName: cityName,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )

            await MainActor.run {
                self.weather = model
                self.isLoading = false
            }

        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func refresh() async {
        await loadWeather()
    }

    func updateCity(_ city: SavedCity?) {
        selectedCity = city
        saveCity(city)
    }

    // MARK: - Private

    private func resolveLocation() async throws -> CLLocation {
        if let city = selectedCity {
            return CLLocation(
                latitude: city.latitude,
                longitude: city.longitude
            )
        }

        if locationService.authorizationStatus == .notDetermined {
            locationService.requestAuthorization()
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        return try await locationService.requestLocation()
    }

    private func resolveCityName(from location: CLLocation) async -> String {
        if let city = selectedCity {
            return city.name
        }

        return await withCheckedContinuation { continuation in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                let name = placemarks?.first?.locality ?? "Unknown"
                continuation.resume(returning: name)
            }
        }
    }

    private let appGroupDefaults = UserDefaults(suiteName: "group.com.donidevrs.skycast")
    
    private func loadSavedCity() {
        guard let data = appGroupDefaults?.data(forKey: "selected_city"),
              let city = try? JSONDecoder().decode(SavedCity.self, from: data)
        else { return }
        selectedCity = city
    }
    
    private func saveCity(_ city: SavedCity?) {
        guard let city = city,
              let data = try? JSONEncoder().encode(city)
        else {
            appGroupDefaults?.removeObject(forKey: "selected_city")
            return
        }
        appGroupDefaults?.set(data, forKey: "selected_city")
    }
}


