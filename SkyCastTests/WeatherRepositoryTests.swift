import XCTest
@testable import SkyCast

final class WeatherRepositoryTests: XCTestCase {
    private var sut: WeatherRepositoryImpl!
    private var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        let httpClient = HTTPClientImpl(session: mockSession)
        sut = WeatherRepositoryImpl(httpClient: httpClient)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        sut = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func test_fetchWeather_success_returnsDTO() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Self.validWeatherJSON)
        }

        let dto = try await sut.fetchWeather(
            latitude: -23.5,
            longitude: -46.6
        )

        XCTAssertEqual(dto.current.temperature2m, 24.0)
        XCTAssertEqual(dto.current.weathercode, 1)
        XCTAssertEqual(dto.current.relativeHumidity2m, 68)
    }

    func test_fetchWeather_buildsCorrectURL() async throws {
        var capturedRequest: URLRequest?

        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Self.validWeatherJSON)
        }

        _ = try? await sut.fetchWeather(
            latitude: -23.5,
            longitude: -46.6
        )

        let urlString = capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("api.open-meteo.com"))
        XCTAssertTrue(urlString.contains("latitude=-23.5"))
        XCTAssertTrue(urlString.contains("longitude=-46.6"))
        XCTAssertTrue(urlString.contains("current="))
        XCTAssertTrue(urlString.contains("hourly="))
        XCTAssertTrue(urlString.contains("daily="))
    }

    // MARK: - Error Tests

    func test_fetchWeather_serverError_throwsAPIError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            _ = try await sut.fetchWeather(
                latitude: -23.5,
                longitude: -46.6
            )
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Expected APIError, got \(error)")
        }
    }

    func test_fetchWeather_invalidJSON_throwsDecodingFailed() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let invalidData = "invalid json".data(using: .utf8)!
            return (response, invalidData)
        }

        do {
            _ = try await sut.fetchWeather(
                latitude: -23.5,
                longitude: -46.6
            )
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .decodingFailed = error {
                // success
            } else {
                XCTFail("Expected decodingFailed, got \(error)")
            }
        } catch {
            XCTFail("Expected APIError, got \(error)")
        }
    }

    // MARK: - Mock JSON

    private static let validWeatherJSON: Data = """
    {
        "current": {
            "temperature_2m": 24.0,
            "apparent_temperature": 22.0,
            "weathercode": 1,
            "windspeed_10m": 14.0,
            "relative_humidity_2m": 68,
            "precipitation": 3.0
        },
        "hourly": {
            "time": ["2024-01-01T12:00", "2024-01-01T13:00"],
            "temperature_2m": [24.0, 25.0],
            "weathercode": [1, 2],
            "precipitation_probability": [20, 40]
        },
        "daily": {
            "time": ["2024-01-01", "2024-01-02"],
            "weathercode": [1, 3],
            "temperature_2m_max": [28.0, 26.0],
            "temperature_2m_min": [19.0, 17.0],
            "precipitation_sum": [3.0, 0.0],
            "uv_index_max": [8.0, 6.0]
        }
    }
    """.data(using: .utf8)!
}
