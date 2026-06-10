import Foundation
import CoreLocation

@Observable
final class SearchViewModel {
    var query: String = ""
    var results: [SavedCity] = []
    var recentSearches: [SavedCity] = []
    var isSearching: Bool = false
    var errorMessage: String?

    private let userDefaults = UserDefaults.standard
    private let recentSearchesKey = "recent_searches"
    private var searchTask: Task<Void, Never>?

    init() {
        loadRecentSearches()
    }

    func onQueryChanged() {
        searchTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            isSearching = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)

            guard !Task.isCancelled else { return }

            await searchCities(query: query)
        }
    }

    func selectCity(_ city: SavedCity) {
        saveToRecent(city)
    }

    func removeRecent(_ city: SavedCity) {
        recentSearches.removeAll { $0.id == city.id }
        saveRecentSearches()
    }

    // MARK: - Search

    private func searchCities(query: String) async {
        await MainActor.run { isSearching = true }

        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.geocodeAddressString(query)

            let cities = placemarks.compactMap { placemark -> SavedCity? in
                guard
                    let name = placemark.locality ?? placemark.name,
                    let country = placemark.country,
                    let location = placemark.location
                else { return nil }

                return SavedCity(
                    name: name,
                    country: country,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }

            await MainActor.run {
                self.results = cities
                self.isSearching = false
            }

        } catch {
            await MainActor.run {
                self.results = []
                self.isSearching = false
            }
        }
    }

    // MARK: - Recent Searches

    private func loadRecentSearches() {
        guard let data = userDefaults.data(forKey: recentSearchesKey),
              let cities = try? JSONDecoder().decode([SavedCity].self, from: data)
        else { return }
        recentSearches = cities
    }

    private func saveToRecent(_ city: SavedCity) {
        recentSearches.removeAll { $0.name == city.name && $0.country == city.country }
        recentSearches.insert(city, at: 0)
        if recentSearches.count > 5 {
            recentSearches = Array(recentSearches.prefix(5))
        }
        saveRecentSearches()
    }

    private func saveRecentSearches() {
        guard let data = try? JSONEncoder().encode(recentSearches) else { return }
        userDefaults.set(data, forKey: recentSearchesKey)
    }
}
