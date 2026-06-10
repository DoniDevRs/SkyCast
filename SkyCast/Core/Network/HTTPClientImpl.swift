import Foundation

final class HTTPClientImpl: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(
        url: URL,
        responseType: T.Type
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw APIError.decodingFailed(error)
            }

        } catch let error as APIError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw APIError.noInternet
            case .timedOut:
                throw APIError.timeout
            default:
                throw APIError.unknown(urlError)
            }
        } catch {
            throw APIError.unknown(error)
        }
    }
}
