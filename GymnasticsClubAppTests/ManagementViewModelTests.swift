import XCTest
@testable import GymnasticsClubApp

@MainActor
private final class ManagementStubClient: APIClientProtocol {
    var responses: [Endpoint: Any] = [:]
    var failingReads: Set<Endpoint> = []
    var failDeletes = false
    private(set) var deleted: [(Endpoint, UUID)] = []

    func login(_ body: LoginRequest) async throws -> LoginResponse { throw NetworkError.unknown }
    func logout() async throws { throw NetworkError.unknown }

    func get<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        if failingReads.contains(endpoint) { throw NetworkError.offline }
        guard let value = responses[endpoint] as? T else { throw NetworkError.unknown }
        return value
    }

    func post<T: Encodable>(_ endpoint: Endpoint, body: T) async throws {
        throw NetworkError.unknown
    }

    func put<T: Encodable>(_ endpoint: Endpoint, id: UUID, body: T) async throws {
        throw NetworkError.unknown
    }

    func delete(_ endpoint: Endpoint, id: UUID) async throws {
        if failDeletes { throw NetworkError.offline }
        deleted.append((endpoint, id))
    }
}

@MainActor
final class ManagementViewModelTests: XCTestCase {
    private func athleteFixture() -> Athlete {
        Athlete(id: UUID(), fullName: "Taylor Gymnast", age: 14, level: "Beginner")
    }

    private func coachFixture() -> Coach {
        Coach(id: UUID(), fullName: "Coach Name", specialty: "Artistic")
    }

    private func classFixture(coach: Coach) -> GymClass {
        GymClass(
            id: UUID(),
            name: "Floor",
            capacity: 12,
            coach: CoachReference(id: coach.id, fullName: coach.fullName)
        )
    }

    private func attendanceFixture(athlete: Athlete, gymClass: GymClass) -> Attendance {
        Attendance(
            id: UUID(),
            athlete: AttendanceAthlete(id: athlete.id, fullName: athlete.fullName),
            gymClass: AttendanceClass(id: gymClass.id, name: gymClass.name),
            attendedOn: .now
        )
    }

    func testAttendanceRefreshPublishesAllReferenceDataAtomically() async {
        let athlete = athleteFixture()
        let coach = coachFixture()
        let gymClass = classFixture(coach: coach)
        let original = attendanceFixture(athlete: athlete, gymClass: gymClass)
        let client = ManagementStubClient()
        client.responses[.attendance] = [original]
        client.responses[.athletes] = [athlete]
        client.responses[.classes] = [gymClass]
        let viewModel = AttendanceViewModel(client: client)
        await viewModel.loadData()

        let newerRecord = attendanceFixture(athlete: athlete, gymClass: gymClass)
        client.responses[.attendance] = [newerRecord]
        client.responses[.athletes] = []
        client.failingReads = [.classes]

        await viewModel.loadData()

        XCTAssertEqual(viewModel.attendance.map(\.id), [original.id])
        XCTAssertEqual(viewModel.athletes.map(\.id), [athlete.id])
        XCTAssertEqual(viewModel.classes.map(\.id), [gymClass.id])
        XCTAssertEqual(viewModel.errorMessage, NetworkError.offline.localizedDescription)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testClassRefreshDoesNotPublishClassesWithoutMatchingCoachSnapshot() async {
        let coach = coachFixture()
        let originalClass = classFixture(coach: coach)
        let client = ManagementStubClient()
        client.responses[.classes] = [originalClass]
        client.responses[.coaches] = [coach]
        let viewModel = ClassesViewModel(client: client)
        await viewModel.loadClasses()

        let newerClass = GymClass(
            id: UUID(),
            name: "Beam",
            capacity: 8,
            coach: CoachReference(id: coach.id, fullName: coach.fullName)
        )
        client.responses[.classes] = [newerClass]
        client.responses[.coaches] = []
        client.failingReads = [.coaches]

        await viewModel.loadClasses()

        XCTAssertEqual(viewModel.classes.map(\.id), [originalClass.id])
        XCTAssertEqual(viewModel.coaches.map(\.id), [coach.id])
        XCTAssertEqual(viewModel.errorMessage, NetworkError.offline.localizedDescription)
    }

    func testConfirmedDeletesUpdateVisibleListsWhenRefreshFails() async {
        let athlete = athleteFixture()
        let coach = coachFixture()
        let gymClass = classFixture(coach: coach)
        let attendance = attendanceFixture(athlete: athlete, gymClass: gymClass)

        let athleteClient = ManagementStubClient()
        athleteClient.responses[.athletes] = [athlete]
        let athleteVM = AthletesViewModel(client: athleteClient)
        await athleteVM.loadAthletes()
        athleteClient.failingReads = [.athletes]
        await athleteVM.deleteAthlete(athlete)
        XCTAssertTrue(athleteVM.athletes.isEmpty)
        XCTAssertEqual(athleteClient.deleted.count, 1)

        let coachClient = ManagementStubClient()
        coachClient.responses[.coaches] = [coach]
        let coachVM = CoachesViewModel(client: coachClient)
        await coachVM.loadCoaches()
        coachClient.failingReads = [.coaches]
        await coachVM.deleteCoach(coach)
        XCTAssertTrue(coachVM.coaches.isEmpty)
        XCTAssertEqual(coachClient.deleted.count, 1)

        let classClient = ManagementStubClient()
        classClient.responses[.classes] = [gymClass]
        classClient.responses[.coaches] = [coach]
        let classVM = ClassesViewModel(client: classClient)
        await classVM.loadClasses()
        classClient.failingReads = [.classes]
        await classVM.deleteClass(gymClass)
        XCTAssertTrue(classVM.classes.isEmpty)
        XCTAssertEqual(classClient.deleted.count, 1)

        let attendanceClient = ManagementStubClient()
        attendanceClient.responses[.attendance] = [attendance]
        attendanceClient.responses[.athletes] = [athlete]
        attendanceClient.responses[.classes] = [gymClass]
        let attendanceVM = AttendanceViewModel(client: attendanceClient)
        await attendanceVM.loadData()
        attendanceClient.failingReads = [.attendance]
        await attendanceVM.deleteAttendance(attendance)
        XCTAssertTrue(attendanceVM.attendance.isEmpty)
        XCTAssertEqual(attendanceClient.deleted.count, 1)
    }

    func testFailedDeleteDoesNotRemoveTheRecordOptimistically() async {
        let athlete = athleteFixture()
        let client = ManagementStubClient()
        client.responses[.athletes] = [athlete]
        let viewModel = AthletesViewModel(client: client)
        await viewModel.loadAthletes()
        client.failDeletes = true

        await viewModel.deleteAthlete(athlete)

        XCTAssertEqual(viewModel.athletes.map(\.id), [athlete.id])
        XCTAssertEqual(viewModel.errorMessage, NetworkError.offline.localizedDescription)
        XCTAssertTrue(client.deleted.isEmpty)
    }
}
