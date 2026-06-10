import Foundation

struct SavedCity: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    
    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}
