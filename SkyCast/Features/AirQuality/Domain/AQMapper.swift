import Foundation

enum AQMapper {
    static func map(
        dto: AQResponseDTO,
        locationName: String
    ) -> AQModel {
        let measurements = mapMeasurements(dto.hourly)
        let aqi = calculateAQI(from: measurements)
        let category = AQCategory.from(aqi: aqi)
        
        return AQModel(
            locationName: locationName,
            updatedAt: Date(),
            measurements: measurements,
            overallAQI: aqi,
            category: category
        )
    }
    
    static func pm25ToAQI(_ concentration: Double) -> Int {
        switch concentration {
        case 0..<12.1:
            return linearScale(concentration, cLow: 0, cHigh: 12, iLow: 0, iHigh: 50)
        case 12.1..<35.5:
            return linearScale(concentration, cLow: 12.1, cHigh: 35.4, iLow: 51, iHigh: 100)
        case 35.5..<55.5:
            return linearScale(concentration, cLow: 35.5, cHigh: 55.4, iLow: 101, iHigh: 150)
        case 55.5..<150.5:
            return linearScale(concentration, cLow: 55.5, cHigh: 150.4, iLow: 151, iHigh: 200)
        case 150.5..<250.5:
            return linearScale(concentration, cLow: 150.5, cHigh: 250.4, iLow: 201, iHigh: 300)
        default:
            return linearScale(concentration, cLow: 250.5, cHigh: 500.4, iLow: 301, iHigh: 500)
        }
    }
    
    static func pm10ToAQI(_ concentration: Double) -> Int {
        switch concentration {
        case 0..<55:
            return linearScale(concentration, cLow: 0, cHigh: 54, iLow: 0, iHigh: 50)
        case 55..<155:
            return linearScale(concentration, cLow: 55, cHigh: 154, iLow: 51, iHigh: 100)
        case 155..<255:
            return linearScale(concentration, cLow: 155, cHigh: 254, iLow: 101, iHigh: 150)
        case 255..<355:
            return linearScale(concentration, cLow: 255, cHigh: 354, iLow: 151, iHigh: 200)
        case 355..<425:
            return linearScale(concentration, cLow: 355, cHigh: 424, iLow: 201, iHigh: 300)
        default:
            return linearScale(concentration, cLow: 425, cHigh: 604, iLow: 301, iHigh: 500)
        }
    }
    
    private static func mapMeasurements(_ hourly: AQHourlyDTO) -> [AQMeasurement] {
        var measurements: [AQMeasurement] = []
        
        if let pm25Value = hourly.pm25.first(where: { $0 != nil }) ?? nil {
            measurements.append(AQMeasurement(
                parameter: .pm25,
                value: pm25Value,
                unit: "μg/m³"
            ))
        }
        
        if let pm10Value = hourly.pm10.first(where: { $0 != nil }) ?? nil {
            measurements.append(AQMeasurement(
                parameter: .pm10,
                value: pm10Value,
                unit: "μg/m³"
            ))
        }
        
        if let no2Value = hourly.nitrogenDioxide.first(where: { $0 != nil }) ?? nil {
            measurements.append(AQMeasurement(
                parameter: .no2,
                value: no2Value,
                unit: "μg/m³"
            ))
        }
        
        if let ozoneValue = hourly.ozone.first(where: { $0 != nil }) ?? nil {
            measurements.append(AQMeasurement(
                parameter: .o3,
                value: ozoneValue,
                unit: "μg/m³"
            ))
        }
        
        return measurements
    }
    
    private static func calculateAQI(from measurements: [AQMeasurement]) -> Int {
        let pm25 = measurements.first { $0.parameter == .pm25 }?.value ?? 0
        let pm10 = measurements.first { $0.parameter == .pm10 }?.value ?? 0
        
        let aqiFromPM25 = pm25ToAQI(pm25)
        let aqiFromPM10 = pm10ToAQI(pm10)
        
        return max(aqiFromPM25, aqiFromPM10)
    }
    
    private static func linearScale(
        _ concentration: Double,
        cLow: Double,
        cHigh: Double,
        iLow: Int,
        iHigh: Int
    ) -> Int {
        let result = (Double(iHigh - iLow) / (cHigh - cLow)) * (concentration - cLow) + Double(iLow)
        return Int(result.rounded())
    }
}
