import Foundation

/// Injectable transport surface for view models. Production uses APIClient;
/// tests can exercise success/failure transitions without replacing the real
/// networking implementation used by the application.
@MainActor
protocol APIClientProtocol: AnyObject {
    func login(_ body: LoginRequest) async throws -> LoginResponse
    func logout() async throws
    func get<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    func post<T: Encodable>(_ endpoint: Endpoint, body: T) async throws
    func put<T: Encodable>(_ endpoint: Endpoint, id: UUID, body: T) async throws
    func delete(_ endpoint: Endpoint, id: UUID) async throws
}
