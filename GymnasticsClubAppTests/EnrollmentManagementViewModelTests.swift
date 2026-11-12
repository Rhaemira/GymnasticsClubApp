import XCTest
@testable import GymnasticsClubApp

@MainActor
private final class EnrollmentStubClient: APIClientProtocol {
    var responses: [Endpoint: Any] = [:]
    var failReads = false
    var failNextReadAfterPost = false
    var failPosts = false
    var failDeletes = false
    private(set) var postCount = 0
    private(set) var deleteCount = 0

    func login(_ body: LoginRequest) async throws -> LoginResponse { throw NetworkError.unknown }
    func logout() async throws { throw NetworkError.unknown }

    func get<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        if failReads { throw NetworkError.offline }
        guard let value = responses[endpoint] as? T else { throw NetworkError.unknown }
        return value
    }

    func post<T: Encodable>(_ endpoint: Endpoint, body: T) async throws {
        postCount += 1
        if failPosts { throw NetworkError.serverError(409, "Enrollment conflict.") }
        if failNextReadAfterPost { failReads = true }
    }

    func put<T: Encodable>(_ endpoint: Endpoint, id: UUID, body: T) async throws {
        throw NetworkError.unknown
    }

    func delete(_ endpoint: Endpoint, id: UUID) async throws {
        deleteCount += 1
        if failDeletes { throw NetworkError.offline }
    }
}

@MainActor
final class EnrollmentManagementViewModelTests: XCTestCase {
    private func fixture() -> (EnrollmentStubClient, Athlete, GymClass, Enrollment) {
        let athlete = Athlete(id: UUID(), fullName: "Taylor Gymnast", age: 14, level: "Beginner")
        let gymClass = GymClass(
            id: UUID(),
            name: "Floor",
            capacity: 2,
            coach: CoachReference(id: UUID(), fullName: "Coach Name")
        )
        let enrollment = Enrollment(
            id: UUID(),
            athlete: AttendanceAthlete(id: athlete.id, fullName: athlete.fullName),
            gymClass: AttendanceClass(id: gymClass.id, name: gymClass.name)
        )
        let client = EnrollmentStubClient()
        client.responses[.enrollments] = [enrollment]
        client.responses[.athletes] = [athlete]
        client.responses[.classes] = [gymClass]
        return (client, athlete, gymClass, enrollment)
    }

    func testLoadPublishesAllThreeCollectionsAsOneSnapshot() async {
        let (client, athlete, gymClass, enrollment) = fixture()
        let viewModel = EnrollmentManagementViewModel(client: client)

        await viewModel.load()

        XCTAssertEqual(viewModel.enrollments.map(\.id), [enrollment.id])
        XCTAssertEqual(viewModel.athletes.map(\.id), [athlete.id])
        XCTAssertEqual(viewModel.classes.map(\.id), [gymClass.id])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFailedRefreshPreservesThePreviousConsistentSnapshot() async {
        let (client, athlete, gymClass, enrollment) = fixture()
        let viewModel = EnrollmentManagementViewModel(client: client)
        await viewModel.load()
        client.responses[.enrollments] = []
        client.responses[.athletes] = []
        client.responses[.classes] = []
        client.failReads = true

        await viewModel.load()

        XCTAssertEqual(viewModel.enrollments.map(\.id), [enrollment.id])
        XCTAssertEqual(viewModel.athletes.map(\.id), [athlete.id])
        XCTAssertEqual(viewModel.classes.map(\.id), [gymClass.id])
        XCTAssertEqual(viewModel.errorMessage, NetworkError.offline.localizedDescription)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSuccessfulEnrollmentRemainsSuccessfulWhenFollowUpRefreshFails() async {
        let (client, athlete, gymClass, enrollment) = fixture()
        let viewModel = EnrollmentManagementViewModel(client: client)
        await viewModel.load()
        client.failNextReadAfterPost = true

        let created = await viewModel.enroll(athleteID: athlete.id, classID: gymClass.id)

        XCTAssertTrue(created, "The server accepted the enrollment even though the refresh failed.")
        XCTAssertEqual(client.postCount, 1)
        XCTAssertEqual(viewModel.enrollments.map(\.id), [enrollment.id], "Do not publish a partial refresh.")
        XCTAssertEqual(viewModel.errorMessage, NetworkError.offline.localizedDescription)
    }

    func testConfirmedRemovalIsReflectedEvenWhenRefreshFails() async {
        let (client, _, _, enrollment) = fixture()
        let viewModel = EnrollmentManagementViewModel(client: client)
        await viewModel.load()
        client.failReads = true

        await viewModel.remove(enrollment)

        XCTAssertEqual(client.deleteCount, 1)
        XCTAssertTrue(viewModel.enrollments.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, NetworkError.offline.localizedDescription)
    }

    func testFailedRemovalDoesNotOptimisticallyRemoveEnrollment() async {
        let (client, _, _, enrollment) = fixture()
        let viewModel = EnrollmentManagementViewModel(client: client)
        await viewModel.load()
        client.failDeletes = true

        await viewModel.remove(enrollment)

        XCTAssertEqual(viewModel.enrollments.map(\.id), [enrollment.id])
        XCTAssertEqual(viewModel.errorMessage, NetworkError.offline.localizedDescription)
    }
}
