import Foundation

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(baseURL: URL? = nil, session: URLSession = .shared) {
        let configured = baseURL ?? (Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String).flatMap(URL.init(string:))
            ?? URL(string: "http://127.0.0.1:8080")!
        self.baseURL = configured
        self.session = session

        self.encoder = Self.makeJSONEncoder()
        self.decoder = Self.makeJSONDecoder()
    }

    func login(_ body: LoginRequest) async throws -> LoginResponse {
        try await send(path: "auth/login", method: .post, body: body, authenticated: false)
    }

    func logout() async throws {
        let _: EmptyResponse = try await send(path: "auth/logout", method: .post, authenticated: true)
    }

    func get<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        try await send(path: endpoint.path, method: .get, authenticated: true)
    }

    func post<T: Encodable>(_ endpoint: Endpoint, body: T) async throws {
        let _: EmptyResponse = try await send(path: endpoint.path, method: .post, body: body, authenticated: true)
    }

    func put<T: Encodable>(_ endpoint: Endpoint, id: UUID, body: T) async throws {
        let _: EmptyResponse = try await send(path: endpoint.path + "/" + id.uuidString, method: .put, body: body, authenticated: true)
    }

    func delete(_ endpoint: Endpoint, id: UUID) async throws {
        let _: EmptyResponse = try await send(path: endpoint.path + "/" + id.uuidString, method: .delete, authenticated: true)
    }

    private func send<Response: Decodable, Body: Encodable>(
        path: String,
        method: HTTPMethod,
        body: Body? = nil,
        authenticated: Bool
    ) async throws -> Response {
        var request = try makeRequest(path: path, method: method, authenticated: authenticated)
        if let body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return try await execute(request, authenticated: authenticated)
    }

    private func send<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        authenticated: Bool
    ) async throws -> Response {
        let request = try makeRequest(path: path, method: method, authenticated: authenticated)
        return try await execute(request, authenticated: authenticated)
    }

    /// One response path for requests with and without JSON bodies.
    private func execute<Response: Decodable>(
        _ request: URLRequest,
        authenticated: Bool
    ) async throws -> Response {
        let (data, response) = try await perform(request)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 && authenticated {
                KeychainTokenStore.delete()
                await MainActor.run { AuthSession.shared.sessionExpired() }
            }
            let serverMessage = try? decoder.decode(ServerErrorResponse.self, from: data).reason
            throw NetworkError.serverError(http.statusCode, serverMessage)
        }

        if data.isEmpty, let emptyResponse = EmptyResponse() as? Response {
            return emptyResponse
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw NetworkError.requestTimedOut
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .cannotFindHost:
                throw NetworkError.offline
            default:
                throw NetworkError.transportFailure(error.localizedDescription)
            }
        } catch {
            throw NetworkError.transportFailure(error.localizedDescription)
        }
    }

    static func makeJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    static func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = fractional.date(from: value) { return date }
            let standard = ISO8601DateFormatter()
            standard.formatOptions = [.withInternetDateTime]
            if let date = standard.date(from: value) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO-8601 timestamp: \(value)")
        }
        return decoder
    }

    private func makeRequest(path: String, method: HTTPMethod, authenticated: Bool) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else { throw NetworkError.invalidURL }
        try APIURLPolicy.validate(url, environment: Bundle.main.object(forInfoDictionaryKey: "APP_ENVIRONMENT") as? String ?? "development")
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if authenticated {
            guard let token = KeychainTokenStore.read() else { throw NetworkError.authenticationRequired }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

private struct EmptyResponse: Decodable {}
private struct ServerErrorResponse: Decodable {
    let reason: String?
}


enum APIURLPolicy {
    static func validate(_ url: URL, environment: String) throws {
        guard let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = url.host, !host.isEmpty else {
            throw NetworkError.invalidURL
        }
        if environment.lowercased() == "production" && scheme != "https" {
            throw NetworkError.invalidURL
        }
    }
}
