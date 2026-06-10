import Foundation

@Observable
final class SettingsViewModel {
    private let userDefaults = UserDefaults.standard

    var temperatureUnit: TemperatureUnit {
        didSet { userDefaults.set(temperatureUnit.rawValue, forKey: Keys.temperatureUnit) }
    }

    var windUnit: WindUnit {
        didSet { userDefaults.set(windUnit.rawValue, forKey: Keys.windUnit) }
    }

    var useAutoLocation: Bool {
        didSet { userDefaults.set(useAutoLocation, forKey: Keys.useAutoLocation) }
    }

    init() {
        let tempRaw = userDefaults.string(forKey: Keys.temperatureUnit) ?? TemperatureUnit.celsius.rawValue
        let windRaw = userDefaults.string(forKey: Keys.windUnit) ?? WindUnit.kmh.rawValue

        self.temperatureUnit = TemperatureUnit(rawValue: tempRaw) ?? .celsius
        self.windUnit = WindUnit(rawValue: windRaw) ?? .kmh
        self.useAutoLocation = userDefaults.bool(forKey: Keys.useAutoLocation)
    }

    func convert(temperature: Double) -> String {
        switch temperatureUnit {
        case .celsius:
            return "\(Int(temperature))°C"
        case .fahrenheit:
            let fahrenheit = (temperature * 9 / 5) + 32
            return "\(Int(fahrenheit))°F"
        }
    }

    func convert(windSpeed: Double) -> String {
        switch windUnit {
        case .kmh:
            return "\(Int(windSpeed)) km/h"
        case .mph:
            let mph = windSpeed * 0.621371
            return "\(Int(mph)) mph"
        case .ms:
            let ms = windSpeed / 3.6
            return String(format: "%.1f m/s", ms)
        }
    }

    private enum Keys {
        static let temperatureUnit = "temperature_unit"
        static let windUnit = "wind_unit"
        static let useAutoLocation = "use_auto_location"
    }
}

enum TemperatureUnit: String, CaseIterable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"

    var label: String {
        switch self {
        case .celsius: return "Celsius (°C)"
        case .fahrenheit: return "Fahrenheit (°F)"
        }
    }
}

enum WindUnit: String, CaseIterable {
    case kmh = "kmh"
    case mph = "mph"
    case ms = "ms"

    var label: String {
        switch self {
        case .kmh: return "km/h"
        case .mph: return "mph"
        case .ms: return "m/s"
        }
    }
}
