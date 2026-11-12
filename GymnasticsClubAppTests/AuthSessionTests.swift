import XCTest
@testable import GymnasticsClubApp

@MainActor
private final class SessionStubClient: APIClientProtocol {
    var loginResponse: LoginResponse?
    var loginError: Error?
    var currentUser: AuthenticatedUser?
    var currentUserError: Error?
    var logoutError: Error?
    private(set) var loginCount = 0
    private(set) var currentUserCount = 0
    private(set) var logoutCount = 0

    func login(_ body: LoginRequest) async throws -> LoginResponse {
        loginCount += 1
        if let loginError { throw loginError }
        guard let loginResponse else { throw NetworkError.unknown }
        return loginResponse
    }

    func logout() async throws {
        logoutCount += 1
        if let logoutError { throw logoutError }
    }

    func get<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        currentUserCount += 1
        if let currentUserError { throw currentUserError }
        guard endpoint == .currentUser, let currentUser = currentUser as? T else {
            throw NetworkError.unknown
        }
        return currentUser
    }

    func post<T: Encodable>(_ endpoint: Endpoint, body: T) async throws {
        throw NetworkError.unknown
    }

    func put<T: Encodable>(_ endpoint: Endpoint, id: UUID, body: T) async throws {
        throw NetworkError.unknown
    }

    func delete(_ endpoint: Endpoint, id: UUID) async throws {
        throw NetworkError.unknown
    }
}

@MainActor
private final class MemoryTokenStore {
    var token: String?
    var deleteCount = 0

    func read() -> String? { token }
    func save(_ value: String) throws { token = value }
    func delete() {
        token = nil
        deleteCount += 1
    }
}

@MainActor
final class AuthSessionTests: XCTestCase {
    private func makeSession(
        client: SessionStubClient,
        store: MemoryTokenStore
    ) -> AuthSession {
        AuthSession(
            client: client,
            tokenReader: { store.read() },
            tokenWriter: { try store.save($0) },
            tokenDeleter: { store.delete() }
        )
    }

    func testRestoreSuccessPublishesTheAuthenticatedUser() async {
        let store = MemoryTokenStore()
        store.token = "saved-token"
        let client = SessionStubClient()
        let expectedUser = AuthenticatedUser(id: UUID(), email: "admin@example.test")
        client.currentUser = expectedUser
        let session = makeSession(client: client, store: store)

        await session.restore()

        XCTAssertTrue(session.isAuthenticated)
        XCTAssertFalse(session.isRestoring)
        XCTAssertEqual(session.user?.id, expectedUser.id)
        XCTAssertNil(session.errorMessage)
        XCTAssertEqual(client.currentUserCount, 1)
        XCTAssertEqual(store.token, "saved-token")
    }

    func testRestoreOfflinePreservesTheCredentialForRetry() async {
        let store = MemoryTokenStore()
        store.token = "saved-token"
        let client = SessionStubClient()
        client.currentUserError = NetworkError.offline
        let session = makeSession(client: client, store: store)

        await session.restore()

        XCTAssertTrue(session.isAuthenticated)
        XCTAssertFalse(session.isRestoring)
        XCTAssertEqual(store.token, "saved-token")
        XCTAssertNotNil(session.errorMessage)
        XCTAssertEqual(store.deleteCount, 0)
    }

    func testRestoreUnauthorizedExpiresTheCredential() async {
        let store = MemoryTokenStore()
        store.token = "expired-token"
        let client = SessionStubClient()
        client.currentUserError = NetworkError.serverError(401, "Expired")
        let session = makeSession(client: client, store: store)

        await session.restore()

        XCTAssertFalse(session.isAuthenticated)
        XCTAssertFalse(session.isRestoring)
        XCTAssertNil(store.token)
        XCTAssertEqual(store.deleteCount, 1)
        XCTAssertEqual(session.errorMessage, "Your session expired. Please sign in again.")
    }

    func testSignInPersistsTokenOnlyAfterSuccessfulAuthentication() async {
        let store = MemoryTokenStore()
        let client = SessionStubClient()
        let user = AuthenticatedUser(id: UUID(), email: "admin@example.test")
        client.loginResponse = LoginResponse(
            token: "new-token",
            expiresAt: Date().addingTimeInterval(3600),
            user: user
        )
        let session = makeSession(client: client, store: store)

        let signedIn = await session.signIn(email: user.email, password: "correct-password")

        XCTAssertTrue(signedIn)
        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.user?.id, user.id)
        XCTAssertEqual(store.token, "new-token")
        XCTAssertNil(session.errorMessage)
    }

    func testOfflineSignOutAlwaysClearsLocalCredentialAndExplainsRemoteUncertainty() async {
        let store = MemoryTokenStore()
        store.token = "saved-token"
        let client = SessionStubClient()
        client.logoutError = NetworkError.offline
        let session = makeSession(client: client, store: store)

        await session.signOut()

        XCTAssertFalse(session.isAuthenticated)
        XCTAssertFalse(session.isRestoring)
        XCTAssertNil(store.token)
        XCTAssertNil(session.user)
        XCTAssertEqual(store.deleteCount, 1)
        XCTAssertTrue(session.errorMessage?.contains("could not confirm token revocation") == true)
    }

    func testUnauthorizedSignOutIsTreatedAsAlreadyRejectedCredential() async {
        let store = MemoryTokenStore()
        store.token = "expired-token"
        let client = SessionStubClient()
        client.logoutError = NetworkError.serverError(401, nil)
        let session = makeSession(client: client, store: store)

        await session.signOut()

        XCTAssertFalse(session.isAuthenticated)
        XCTAssertNil(store.token)
        XCTAssertNil(session.errorMessage)
    }

    func testLateUnauthorizedResponseCannotClearAReplacementCredential() {
        let store = MemoryTokenStore()
        store.token = "new-token"
        let session = makeSession(client: SessionStubClient(), store: store)

        session.sessionExpired(ifCurrentTokenMatches: "old-token")

        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(store.token, "new-token")
        XCTAssertEqual(store.deleteCount, 0)
    }
}
