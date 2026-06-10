import Foundation
import SwiftUI

struct AQModel {
    let locationName: String
    let updatedAt: Date
    let measurements: [AQMeasurement]
    let overallAQI: Int
    let category: AQCategory
}

struct AQMeasurement {
    let parameter: AQParameter
    let value: Double
    let unit: String
}

enum AQParameter: String {
    case pm25 = "pm25"
    case pm10 = "pm10"
    case no2 = "no2"
    case o3 = "o3"

    var displayName: String {
        switch self {
        case .pm25: return "PM2.5"
        case .pm10: return "PM10"
        case .no2: return "NO₂"
        case .o3: return "O₃"
        }
    }

    var unit: String {
        return "μg/m³"
    }
}

enum AQCategory {
    case good
    case moderate
    case unhealthyForSensitive
    case unhealthy
    case veryUnhealthy
    case hazardous

    var label: String {
        switch self {
        case .good: return "Good"
        case .moderate: return "Moderate"
        case .unhealthyForSensitive: return "Unhealthy for Sensitive Groups"
        case .unhealthy: return "Unhealthy"
        case .veryUnhealthy: return "Very Unhealthy"
        case .hazardous: return "Hazardous"
        }
    }

    var recommendation: String {
        switch self {
        case .good:
            return "Air quality is satisfactory. Enjoy outdoor activities without restrictions."
        case .moderate:
            return "Air quality is acceptable. Unusually sensitive people should consider reducing prolonged outdoor exertion."
        case .unhealthyForSensitive:
            return "Members of sensitive groups may experience health effects. The general public is less likely to be affected."
        case .unhealthy:
            return "Everyone may begin to experience health effects. Sensitive groups should avoid prolonged outdoor exertion."
        case .veryUnhealthy:
            return "Health alert: everyone may experience more serious health effects. Avoid prolonged outdoor exertion."
        case .hazardous:
            return "Health warning of emergency conditions. Everyone is more likely to be affected. Stay indoors."
        }
    }

    var color: Color {
        switch self {
        case .good: return Color(hex: "4ade80")
        case .moderate: return Color(hex: "facc15")
        case .unhealthyForSensitive: return Color(hex: "fb923c")
        case .unhealthy: return Color(hex: "ef4444")
        case .veryUnhealthy: return Color(hex: "a855f7")
        case .hazardous: return Color(hex: "7f1d1d")
        }
    }

    var gaugePosition: Double {
        switch self {
        case .good: return 0.1
        case .moderate: return 0.28
        case .unhealthyForSensitive: return 0.45
        case .unhealthy: return 0.62
        case .veryUnhealthy: return 0.78
        case .hazardous: return 0.95
        }
    }

    static func from(aqi: Int) -> AQCategory {
        switch aqi {
        case 0...50: return .good
        case 51...100: return .moderate
        case 101...150: return .unhealthyForSensitive
        case 151...200: return .unhealthy
        case 201...300: return .veryUnhealthy
        default: return .hazardous
        }
    }
}
