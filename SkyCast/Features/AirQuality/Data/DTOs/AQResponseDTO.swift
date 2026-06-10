import Foundation

struct AQResponseDTO: Decodable {
    let hourly: AQHourlyDTO
}

struct AQHourlyDTO: Decodable {
    let time: [String]
    let pm10: [Double?]
    let pm25: [Double?]
    let nitrogenDioxide: [Double?]
    let ozone: [Double?]
    
    enum CodingKeys: String, CodingKey {
        case time
        case pm10
        case pm25 = "pm2_5"
        case nitrogenDioxide = "nitrogen_dioxide"
        case ozone
    }
}
