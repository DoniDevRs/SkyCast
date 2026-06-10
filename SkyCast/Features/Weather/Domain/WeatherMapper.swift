import Foundation

enum WeatherMapper {
    static func map(
        dto: WeatherResponseDTO,
        cityName: String,
        latitude: Double,
        longitude: Double
    ) -> WeatherModel {
        let current = mapCurrent(dto.current)
        let hourly = mapHourly(dto.hourly)
        let daily = mapDaily(dto.daily)

        return WeatherModel(
            cityName: cityName,
            latitude: latitude,
            longitude: longitude,
            current: current,
            hourly: hourly,
            daily: daily
        )
    }

    private static func mapCurrent(_ dto: CurrentDTO) -> CurrentWeather {
        CurrentWeather(
            temperature: dto.temperature2m,
            apparentTemperature: dto.apparentTemperature,
            weatherCode: dto.weathercode,
            windSpeed: dto.windspeed10m,
            humidity: dto.relativeHumidity2m,
            precipitation: dto.precipitation,
            condition: WeatherCondition.from(code: dto.weathercode)
        )
    }

    private static func mapHourly(_ dto: HourlyDTO) -> [HourlyWeather] {
        guard dto.time.count == dto.temperature2m.count,
              dto.time.count == dto.weathercode.count,
              dto.time.count == dto.precipitationProbability.count
        else { return [] }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone.current
        
        return dto.time.enumerated().compactMap { index, timeString in
            guard let date = formatter.date(from: timeString) else { return nil }
            let code = dto.weathercode[index]
            return HourlyWeather(
                time: date,
                temperature: dto.temperature2m[index],
                weatherCode: code,
                precipitationProbability: dto.precipitationProbability[index],
                condition: WeatherCondition.from(code: code)
            )
        }
    }

    private static func mapDaily(_ dto: DailyDTO) -> [DailyWeather] {
        guard dto.time.count == dto.weathercode.count,
              dto.time.count == dto.temperature2mMax.count,
              dto.time.count == dto.temperature2mMin.count
        else { return [] }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return dto.time.enumerated().compactMap { index, timeString in
            guard let date = formatter.date(from: timeString) else { return nil }
            let code = dto.weathercode[index]
            return DailyWeather(
                time: date,
                weatherCode: code,
                maxTemperature: dto.temperature2mMax[index],
                minTemperature: dto.temperature2mMin[index],
                precipitationSum: dto.precipitationSum[index],
                uvIndexMax: dto.uvIndexMax[index],
                condition: WeatherCondition.from(code: code)
            )
        }
    }
}
