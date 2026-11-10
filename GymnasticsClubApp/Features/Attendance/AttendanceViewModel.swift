import Foundation
import Combine

@MainActor
final class AttendanceViewModel: ObservableObject {
    private let client: any APIClientProtocol

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var attendance: [Attendance] = []
    @Published private(set) var athletes: [Athlete] = []
    @Published private(set) var classes: [GymClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let records = client.get(.attendance, as: [Attendance].self)
            async let athleteRows = client.get(.athletes, as: [Athlete].self)
            async let classRows = client.get(.classes, as: [GymClass].self)
            attendance = try await records
            athletes = try await athleteRows
            classes = try await classRows
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addAttendance(athleteID: UUID, classID: UUID, attendedOn: Date) async -> String? {
        do {
            try await client.post(.attendance, body: CreateAttendanceRequest(athleteID: athleteID, classID: classID, attendedOn: attendedOn))
            await loadData()
            return nil
        } catch { errorMessage = error.localizedDescription; return error.localizedDescription }
    }

    func updateAttendance(attendance: Attendance, athleteID: UUID, classID: UUID, attendedOn: Date) async -> String? {
        do {
            try await client.put(.attendance, id: attendance.id, body: CreateAttendanceRequest(athleteID: athleteID, classID: classID, attendedOn: attendedOn))
            await loadData()
            return nil
        } catch { errorMessage = error.localizedDescription; return error.localizedDescription }
    }

    func deleteAttendance(_ attendance: Attendance) async {
        do {
            try await client.delete(.attendance, id: attendance.id)
            await loadData()
        } catch { errorMessage = error.localizedDescription }
    }
}
