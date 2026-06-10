import Foundation

struct URLBuilder {
    private let baseURL: String
    private var queryItems: [URLQueryItem] = []

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func addParameter(_ name: String, value: String) -> URLBuilder {
        var copy = self
        copy.queryItems.append(URLQueryItem(name: name, value: value))
        return copy
    }

    func build() throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        return url
    }
}
