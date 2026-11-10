import XCTest
@testable import GymnasticsClubApp

@MainActor
final class APIContractTests: XCTestCase {
    func testClassCreationUsesBackendSnakeCaseCoachKey() throws {
        let coachID = UUID()
        let request = CreateClassRequest(name: "Floor", capacity: 12, coachID: coachID)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any]
        )

        XCTAssertEqual(json["coach_id"] as? String, coachID.uuidString)
        XCTAssertNil(json["coachID"])
    }

    func testEnrollmentUsesBackendSnakeCaseKeys() throws {
        let athleteID = UUID()
        let classID = UUID()
        let request = CreateEnrollmentRequest(athleteID: athleteID, classID: classID)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any]
        )

        XCTAssertEqual(json["athlete_id"] as? String, athleteID.uuidString)
        XCTAssertEqual(json["class_id"] as? String, classID.uuidString)
    }

    func testDateDecoderAcceptsFractionalAndWholeSecondISO8601() throws {
        struct DatePayload: Decodable { let value: Date }
        let decoder = APIClient.makeJSONDecoder()

        let fractional = Data(#"{"value":"2026-11-10T12:34:56.123Z"}"#.utf8)
        let wholeSeconds = Data(#"{"value":"2026-11-10T12:34:56Z"}"#.utf8)

        let fractionalDate = try decoder.decode(DatePayload.self, from: fractional).value
        let wholeDate = try decoder.decode(DatePayload.self, from: wholeSeconds).value
        XCTAssertEqual(fractionalDate.timeIntervalSince1970, wholeDate.timeIntervalSince1970 + 0.123, accuracy: 0.001)
    }

    func testProductionRequiresHTTPSWhileDevelopmentAllowsLocalHTTP() throws {
        let secureURL = try XCTUnwrap(URL(string: "https://api.example.test"))
        let localURL = try XCTUnwrap(URL(string: "http://127.0.0.1:8080"))

        XCTAssertNoThrow(try APIURLPolicy.validate(secureURL, environment: "production"))
        XCTAssertThrowsError(try APIURLPolicy.validate(localURL, environment: "production"))
        XCTAssertNoThrow(try APIURLPolicy.validate(localURL, environment: "development"))
    }

    func testAPIURLPolicyRejectsUnsupportedSchemesAndMissingHosts() throws {
        let fileURL = try XCTUnwrap(URL(string: "file:///tmp/api"))
        let hostlessURL = try XCTUnwrap(URL(string: "https:///health"))

        XCTAssertThrowsError(try APIURLPolicy.validate(fileURL, environment: "development"))
        XCTAssertThrowsError(try APIURLPolicy.validate(hostlessURL, environment: "development"))
    }

    func testServerErrorsExposeStatusAndUsefulMessage() {
        let error = NetworkError.serverError(409, "This class has reached its capacity.")

        XCTAssertEqual(error.statusCode, 409)
        XCTAssertFalse(error.isAuthenticationFailure)
        XCTAssertEqual(error.errorDescription, "This class has reached its capacity.")
        XCTAssertTrue(NetworkError.serverError(401, nil).isAuthenticationFailure)
    }

    func testEndpointPathsMatchTheBackendContract() {
        XCTAssertEqual(Endpoint.currentUser.path, "auth/me")
        XCTAssertEqual(Endpoint.enrollments.path, "enrollments")
        XCTAssertEqual(Endpoint.reports.path, "reports")
        XCTAssertEqual(Endpoint.analytics.path, "analytics")
    }

    func testAttendanceRequestEncodesTheExpectedFields() throws {
        let request = CreateAttendanceRequest(
            athleteID: UUID(),
            classID: UUID(),
            attendedOn: Date(timeIntervalSince1970: 1_800_000_000)
        )
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: APIClient.makeJSONEncoder().encode(request)) as? [String: Any]
        )

        XCTAssertNotNil(json["athleteID"])
        XCTAssertNotNil(json["classID"])
        XCTAssertNotNil(json["attendedOn"])
    }
}


extension APIContractTests {
    func testAthleteValidationMatchesBackendNameAndAgeLimits() {
        XCTAssertNil(GymnasticsFormValidation.athlete(fullName: "Taylor Gymnast", age: 1))
        XCTAssertNil(GymnasticsFormValidation.athlete(fullName: "Taylor Gymnast", age: 120))
        XCTAssertNotNil(GymnasticsFormValidation.athlete(fullName: "   ", age: 12))
        XCTAssertNotNil(GymnasticsFormValidation.athlete(fullName: "A", age: 12))
        XCTAssertNotNil(GymnasticsFormValidation.athlete(fullName: "Taylor Gymnast", age: 0))
        XCTAssertNotNil(GymnasticsFormValidation.athlete(fullName: "Taylor Gymnast", age: 121))
    }

    func testCoachValidationRequiresBoundedNameAndSpecialty() {
        XCTAssertNil(GymnasticsFormValidation.coach(fullName: "Coach Name", specialty: "Artistic Gymnastics"))
        XCTAssertNotNil(GymnasticsFormValidation.coach(fullName: " ", specialty: "Artistic"))
        XCTAssertNotNil(GymnasticsFormValidation.coach(fullName: "Coach Name", specialty: " "))
        XCTAssertNotNil(GymnasticsFormValidation.coach(fullName: String(repeating: "x", count: 101), specialty: "Artistic"))
    }

    func testClassValidationEnforcesCapacityAndCoachSelection() {
        XCTAssertNil(GymnasticsFormValidation.gymClass(name: "Floor", capacity: 1, hasCoach: true))
        XCTAssertNil(GymnasticsFormValidation.gymClass(name: "Floor", capacity: 500, hasCoach: true))
        XCTAssertNotNil(GymnasticsFormValidation.gymClass(name: " ", capacity: 10, hasCoach: true))
        XCTAssertNotNil(GymnasticsFormValidation.gymClass(name: "Floor", capacity: 0, hasCoach: true))
        XCTAssertNotNil(GymnasticsFormValidation.gymClass(name: "Floor", capacity: 501, hasCoach: true))
        XCTAssertNotNil(GymnasticsFormValidation.gymClass(name: "Floor", capacity: 10, hasCoach: false))
    }

    func testAttendanceValidationRequiresSelectionsAndRejectsFarFutureDates() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        XCTAssertNil(GymnasticsFormValidation.attendance(
            hasAthlete: true,
            hasClass: true,
            attendedOn: now.addingTimeInterval(300),
            now: now
        ))
        XCTAssertNotNil(GymnasticsFormValidation.attendance(
            hasAthlete: false,
            hasClass: true,
            attendedOn: now,
            now: now
        ))
        XCTAssertNotNil(GymnasticsFormValidation.attendance(
            hasAthlete: true,
            hasClass: false,
            attendedOn: now,
            now: now
        ))
        XCTAssertNotNil(GymnasticsFormValidation.attendance(
            hasAthlete: true,
            hasClass: true,
            attendedOn: now.addingTimeInterval(301),
            now: now
        ))
    }
}
