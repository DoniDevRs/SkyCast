import Foundation
import CoreLocation

final class LocationServiceImpl: NSObject, LocationService {
    private let manager: CLLocationManager
    private var continuation: CheckedContinuation<CLLocation, Error>?

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
}

extension LocationServiceImpl: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        continuation?.resume(returning: location)
        continuation = nil
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                continuation?.resume(throwing: LocationError.denied)
            case .locationUnknown:
                continuation?.resume(throwing: LocationError.unknown)
            default:
                continuation?.resume(throwing: LocationError.unknown)
            }
        } else {
            continuation?.resume(throwing: LocationError.unknown)
        }
        continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied {
            continuation?.resume(throwing: LocationError.denied)
            continuation = nil
        }
    }
}
