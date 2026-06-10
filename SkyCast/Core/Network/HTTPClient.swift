import Foundation

protocol HTTPClient {
    func get<T: Decodable>(
        url: URL,
        responseType: T.Type
    ) async throws -> T
}
