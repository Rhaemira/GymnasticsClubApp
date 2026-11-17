import XCTest
@testable import GymnasticsClubApp

private final class APIClientURLProtocolStub: URLProtocol {
    // Tests run serially; URLProtocol invokes its callback outside the main actor.
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

@MainActor
final class APIClientTransportTests: XCTestCase {
    override func tearDown() {
        APIClientURLProtocolStub.handler = nil
        super.tearDown()
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [APIClientURLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    func testAuthenticatedRequestUsesInjectedTokenProvider() async throws {
        var authorizationHeader: String?
        APIClientURLProtocolStub.handler = { request in
            authorizationHeader = request.value(forHTTPHeaderField: "Authorization")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, Data("[]".utf8))
        }

        let client = APIClient(
            baseURL: URL(string: "https://api.example.test/")!,
            session: makeSession(),
            tokenProvider: { "injected-test-token" },
            unauthorizedHandler: { _ in XCTFail("Unexpected unauthorized callback") }
        )

        let athletes = try await client.get(.athletes, as: [Athlete].self)

        XCTAssertTrue(athletes.isEmpty)
        XCTAssertEqual(authorizationHeader, "Bearer injected-test-token")
    }

    func testUnauthorizedResponseUsesInjectedSessionExpiryHandler() async {
        var expiredToken: String?
        APIClientURLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, Data(#"{"reason":"Expired"}"#.utf8))
        }

        let client = APIClient(
            baseURL: URL(string: "https://api.example.test/")!,
            session: makeSession(),
            tokenProvider: { "expired-test-token" },
            unauthorizedHandler: { token in expiredToken = token }
        )

        do {
            let _: [Athlete] = try await client.get(.athletes, as: [Athlete].self)
            XCTFail("Expected the server's 401 response to be surfaced")
        } catch let error as NetworkError {
            XCTAssertTrue(error.isAuthenticationFailure)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(expiredToken, "expired-test-token")
    }
}
