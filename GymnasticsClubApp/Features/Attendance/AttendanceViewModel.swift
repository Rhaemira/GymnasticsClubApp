import Foundation
import Combine

@MainActor
final class AttendanceViewModel: ObservableObject {
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
            async let records = APIClient.shared.get(.attendance, as: [Attendance].self)
            async let athleteRows = APIClient.shared.get(.athletes, as: [Athlete].self)
            async let classRows = APIClient.shared.get(.classes, as: [GymClass].self)
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
            try await APIClient.shared.post(.attendance, body: CreateAttendanceRequest(athleteID: athleteID, classID: classID, attendedOn: attendedOn))
            await loadData()
            return nil
        } catch { errorMessage = error.localizedDescription; return error.localizedDescription }
    }

    func updateAttendance(attendance: Attendance, athleteID: UUID, classID: UUID, attendedOn: Date) async -> String? {
        do {
            try await APIClient.shared.put(.attendance, id: attendance.id, body: CreateAttendanceRequest(athleteID: athleteID, classID: classID, attendedOn: attendedOn))
            await loadData()
            return nil
        } catch { errorMessage = error.localizedDescription; return error.localizedDescription }
    }

    func deleteAttendance(_ attendance: Attendance) async {
        do {
            try await APIClient.shared.delete(.attendance, id: attendance.id)
            await loadData()
        } catch { errorMessage = error.localizedDescription }
    }
}
