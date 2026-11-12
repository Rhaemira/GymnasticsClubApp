import Foundation

struct Enrollment: Codable, Identifiable {
    let id: UUID
    let athlete: AttendanceAthlete
    let gymClass: AttendanceClass
}

struct CreateEnrollmentRequest: Encodable {
    let athleteID: UUID
    let classID: UUID
    enum CodingKeys: String, CodingKey {
        case athleteID = "athlete_id"
        case classID = "class_id"
    }
}
