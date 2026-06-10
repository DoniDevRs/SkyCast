import Foundation
import CoreLocation

protocol LocationService {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestLocation() async throws -> CLLocation
    func requestAuthorization()
}

enum LocationError: Error, LocalizedError {
    case denied
    case restricted
    case unknown
    case timeout

    var errorDescription: String? {
        switch self {
        case .denied:
            return "Location access was denied. Please enable it in Settings."
        case .restricted:
            return "Location access is restricted on this device."
        case .timeout:
            return "Location request timed out. Please try again."
        case .unknown:
            return "An unknown location error occurred."
        }
    }
}
