import XCTest
@testable import SkyCast

final class AQRepositoryTests: XCTestCase {
    private var sut: AQRepositoryImpl!
    private var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        let httpClient = HTTPClientImpl(session: mockSession)
        sut = AQRepositoryImpl(httpClient: httpClient)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func test_fetchAirQuality_success_returnsDTO() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Self.validAirQualityJSON)
        }
        
        let dto = try await sut.fetchAirQuality(
            latitude: -23.5,
            longitude: -46.6
        )
        
        XCTAssertFalse(dto.hourly.pm25.isEmpty)
        XCTAssertFalse(dto.hourly.pm10.isEmpty)
    }
    
    func test_fetchAirQuality_buildsCorrectURL() async throws {
        var capturedRequest: URLRequest?
        
        MockURLProtocol.requestHandler = { request in
            if capturedRequest == nil {
                capturedRequest = request
            }
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Self.validAirQualityJSON)
        }
        
        _ = try? await sut.fetchAirQuality(
            latitude: -23.5,
            longitude: -46.6
        )
        
        let urlString = capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("air-quality-api.open-meteo.com"))
        XCTAssertTrue(urlString.contains("latitude=-23.5"))
        XCTAssertTrue(urlString.contains("longitude=-46.6"))
        XCTAssertTrue(urlString.contains("pm2_5"))
        XCTAssertTrue(urlString.contains("pm10"))
    }
    
    func test_fetchAirQuality_serverError_throwsAPIError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 503,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        do {
            _ = try await sut.fetchAirQuality(
                latitude: -23.5,
                longitude: -46.6
            )
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 503)
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Expected APIError, got \(error)")
        }
    }
    
    func test_fetchAirQuality_invalidJSON_throwsDecodingFailed() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, "invalid".data(using: .utf8)!)
        }
        
        do {
            _ = try await sut.fetchAirQuality(
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
    
    // MARK: - AQMapper Tests
    
    func test_aqMapper_mapsCorrectly() throws {
        let dto = try JSONDecoder().decode(
            AQResponseDTO.self,
            from: Self.validAirQualityJSON
        )
        
        let model = AQMapper.map(dto: dto, locationName: "São Paulo")
        
        XCTAssertEqual(model.locationName, "São Paulo")
        XCTAssertFalse(model.measurements.isEmpty)
        XCTAssertGreaterThan(model.overallAQI, 0)
    }
    
    func test_aqMapper_pm25ToAQI_goodRange() {
        let aqi = AQMapper.pm25ToAQI(8.0)
        XCTAssertTrue(aqi <= 50)
    }
    
    func test_aqMapper_pm25ToAQI_moderateRange() {
        let aqi = AQMapper.pm25ToAQI(20.0)
        XCTAssertTrue(aqi > 50 && aqi <= 100)
    }
    
    func test_aqMapper_pm10ToAQI_goodRange() {
        let aqi = AQMapper.pm10ToAQI(30.0)
        XCTAssertTrue(aqi <= 50)
    }
    
    // MARK: - Mock JSON
    
    private static let validAirQualityJSON: Data = """
    {
        "hourly": {
            "time": ["2024-01-01T00:00", "2024-01-01T01:00"],
            "pm10": [24.0, 22.0],
            "pm2_5": [12.0, 11.0],
            "nitrogen_dioxide": [38.0, 35.0],
            "ozone": [61.0, 58.0]
        }
    }
    """.data(using: .utf8)!
}
