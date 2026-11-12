import XCTest
@testable import GymnasticsClubApp

@MainActor
private final class StubAPIClient: APIClientProtocol {
    enum StubError: LocalizedError {
        case requestRejected
        case missingResponse

        var errorDescription: String? {
            switch self {
            case .requestRejected: return "The test server rejected the request."
            case .missingResponse: return "The test has no configured response."
            }
        }
    }

    var shouldFailRequests = false
    var responses: [Endpoint: Any] = [:]
    private(set) var postCount = 0

    func login(_ body: LoginRequest) async throws -> LoginResponse {
        throw StubError.missingResponse
    }

    func logout() async throws {
        if shouldFailRequests { throw StubError.requestRejected }
    }

    func get<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        if shouldFailRequests { throw StubError.requestRejected }
        guard let response = responses[endpoint] as? T else {
            throw StubError.missingResponse
        }
        return response
    }

    func post<T: Encodable>(_ endpoint: Endpoint, body: T) async throws {
        if shouldFailRequests { throw StubError.requestRejected }
        postCount += 1
    }

    func put<T: Encodable>(_ endpoint: Endpoint, id: UUID, body: T) async throws {
        if shouldFailRequests { throw StubError.requestRejected }
    }

    func delete(_ endpoint: Endpoint, id: UUID) async throws {
        if shouldFailRequests { throw StubError.requestRejected }
    }
}

@MainActor
final class ViewModelNetworkingTests: XCTestCase {
    func testAthleteCreateSuccessRefreshesThePublishedList() async {
        let athlete = Athlete(id: UUID(), fullName: "Taylor Gymnast", age: 14, level: "Beginner")
        let client = StubAPIClient()
        client.responses[.athletes] = [athlete]
        let viewModel = AthletesViewModel(client: client)

        let error = await viewModel.addAthlete(
            fullName: athlete.fullName,
            age: athlete.age,
            level: athlete.level
        )

        XCTAssertNil(error)
        XCTAssertEqual(client.postCount, 1)
        XCTAssertEqual(viewModel.athletes, [athlete])
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testAthleteCreateFailureReturnsServerErrorAndKeepsExistingData() async {
        let existing = Athlete(id: UUID(), fullName: "Existing Athlete", age: 12, level: "Advanced")
        let client = StubAPIClient()
        client.responses[.athletes] = [existing]
        let viewModel = AthletesViewModel(client: client)
        await viewModel.loadAthletes()
        client.shouldFailRequests = true

        let error = await viewModel.addAthlete(
            fullName: "Another Athlete",
            age: 13,
            level: "Beginner"
        )

        XCTAssertEqual(error, StubAPIClient.StubError.requestRejected.localizedDescription)
        XCTAssertEqual(viewModel.errorMessage, error)
        XCTAssertEqual(viewModel.athletes, [existing])
        XCTAssertEqual(client.postCount, 0)
    }
}


extension ViewModelNetworkingTests {
    func testEnrollmentFailurePreservesCapacityDataAndReturnsFailure() async {
        let athleteID = UUID()
        let classID = UUID()
        let athlete = Athlete(id: athleteID, fullName: "Taylor Gymnast", age: 14, level: "Beginner")
        let gymClass = GymClass(
            id: classID,
            name: "Floor",
            capacity: 1,
            coach: CoachReference(id: UUID(), fullName: "Coach Name")
        )
        let enrollment = Enrollment(
            id: UUID(),
            athlete: AttendanceAthlete(id: athleteID, fullName: athlete.fullName),
            gymClass: AttendanceClass(id: classID, name: gymClass.name)
        )

        let client = StubAPIClient()
        client.responses[.enrollments] = [enrollment]
        client.responses[.athletes] = [athlete]
        client.responses[.classes] = [gymClass]
        let viewModel = EnrollmentManagementViewModel(client: client)
        await viewModel.load()
        client.shouldFailRequests = true

        let created = await viewModel.enroll(athleteID: UUID(), classID: classID)

        XCTAssertFalse(created)
        XCTAssertEqual(viewModel.count(for: classID), 1)
        XCTAssertEqual(viewModel.enrollments.map(\.id), [enrollment.id])
        XCTAssertEqual(viewModel.errorMessage, StubAPIClient.StubError.requestRejected.localizedDescription)
    }
}
