import XCTest
@testable import SkyCast

final class WeatherMapperTests: XCTestCase {

    // MARK: - WeatherCondition Tests

    func test_weatherCondition_clearSky() {
        let condition = WeatherCondition.from(code: 0)
        XCTAssertEqual(condition.description, "Clear Sky")
        XCTAssertEqual(condition.sfSymbol, "sun.max.fill")
    }

    func test_weatherCondition_partlyCloudy() {
        let condition = WeatherCondition.from(code: 1)
        XCTAssertEqual(condition.description, "Partly Cloudy")
        XCTAssertEqual(condition.sfSymbol, "cloud.sun.fill")
    }

    func test_weatherCondition_rain() {
        let condition = WeatherCondition.from(code: 61)
        XCTAssertEqual(condition.description, "Rain")
        XCTAssertEqual(condition.sfSymbol, "cloud.rain.fill")
    }

    func test_weatherCondition_thunderstorm() {
        let condition = WeatherCondition.from(code: 95)
        XCTAssertEqual(condition.description, "Thunderstorm")
        XCTAssertEqual(condition.sfSymbol, "cloud.bolt.fill")
    }

    func test_weatherCondition_unknownCode_returnsDefault() {
        let condition = WeatherCondition.from(code: 999)
        XCTAssertEqual(condition.description, "Unknown")
        XCTAssertEqual(condition.sfSymbol, "cloud.fill")
    }

    // MARK: - WeatherMapper Tests

    func test_mapper_mapsCurrentWeatherCorrectly() {
        let dto = makeWeatherResponseDTO()
        let model = WeatherMapper.map(
            dto: dto,
            cityName: "São Paulo",
            latitude: -23.5,
            longitude: -46.6
        )

        XCTAssertEqual(model.cityName, "São Paulo")
        XCTAssertEqual(model.latitude, -23.5)
        XCTAssertEqual(model.longitude, -46.6)
        XCTAssertEqual(model.current.temperature, 24.0)
        XCTAssertEqual(model.current.apparentTemperature, 22.0)
        XCTAssertEqual(model.current.weatherCode, 1)
        XCTAssertEqual(model.current.windSpeed, 14.0)
        XCTAssertEqual(model.current.humidity, 68)
        XCTAssertEqual(model.current.precipitation, 3.0)
        XCTAssertEqual(model.current.condition.description, "Partly Cloudy")
    }

    func test_mapper_mapsHourlyWeatherCorrectly() {
        let dto = makeWeatherResponseDTO()
        let model = WeatherMapper.map(
            dto: dto,
            cityName: "São Paulo",
            latitude: -23.5,
            longitude: -46.6
        )

        XCTAssertEqual(model.hourly.count, 2)
        XCTAssertEqual(model.hourly[0].temperature, 24.0)
        XCTAssertEqual(model.hourly[0].precipitationProbability, 20)
        XCTAssertEqual(model.hourly[1].temperature, 25.0)
        XCTAssertEqual(model.hourly[1].precipitationProbability, 40)
    }

    func test_mapper_mapsDailyWeatherCorrectly() {
        let dto = makeWeatherResponseDTO()
        let model = WeatherMapper.map(
            dto: dto,
            cityName: "São Paulo",
            latitude: -23.5,
            longitude: -46.6
        )

        XCTAssertEqual(model.daily.count, 2)
        XCTAssertEqual(model.daily[0].maxTemperature, 28.0)
        XCTAssertEqual(model.daily[0].minTemperature, 19.0)
        XCTAssertEqual(model.daily[0].uvIndexMax, 8.0)
    }

    func test_mapper_hourlyMismatchedArrays_returnsEmpty() {
        var dto = makeWeatherResponseDTO()
        dto = WeatherResponseDTO(
            current: dto.current,
            hourly: HourlyDTO(
                time: ["2024-01-01T12:00"],
                temperature2m: [24.0, 25.0],
                weathercode: [1],
                precipitationProbability: [20]
            ),
            daily: dto.daily
        )

        let model = WeatherMapper.map(
            dto: dto,
            cityName: "São Paulo",
            latitude: -23.5,
            longitude: -46.6
        )

        XCTAssertEqual(model.hourly.count, 0)
    }

    // MARK: - Helpers

    private func makeWeatherResponseDTO() -> WeatherResponseDTO {
        WeatherResponseDTO(
            current: CurrentDTO(
                temperature2m: 24.0,
                apparentTemperature: 22.0,
                weathercode: 1,
                windspeed10m: 14.0,
                relativeHumidity2m: 68,
                precipitation: 3.0
            ),
            hourly: HourlyDTO(
                time: [
                    "2024-01-01T12:00",
                    "2024-01-01T13:00"
                ],
                temperature2m: [24.0, 25.0],
                weathercode: [1, 2],
                precipitationProbability: [20, 40]
            ),
            daily: DailyDTO(
                time: [
                    "2024-01-01",
                    "2024-01-02"
                ],
                weathercode: [1, 3],
                temperature2mMax: [28.0, 26.0],
                temperature2mMin: [19.0, 17.0],
                precipitationSum: [3.0, 0.0],
                uvIndexMax: [8.0, 6.0]
            )
        )
    }
}
