import Foundation
import Combine

@MainActor
final class AttendanceViewModel: ObservableObject {
    private let client: any APIClientProtocol
    private var loadGeneration = 0

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var attendance: [Attendance] = []
    @Published private(set) var athletes: [Athlete] = []
    @Published private(set) var classes: [GymClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Publish attendance and its Picker reference data as one consistent snapshot.
    /// This prevents an edit sheet from seeing an attendance ID before the
    /// corresponding athlete/class Picker tags have loaded.
    func loadData() async {
        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true
        errorMessage = nil
        defer {
            if generation == loadGeneration {
                isLoading = false
            }
        }

        do {
            async let records = client.get(.attendance, as: [Attendance].self)
            async let athleteRows = client.get(.athletes, as: [Athlete].self)
            async let classRows = client.get(.classes, as: [GymClass].self)
            let (newAttendance, newAthletes, newClasses) = try await (
                records,
                athleteRows,
                classRows
            )

            guard generation == loadGeneration else { return }
            attendance = newAttendance
            athletes = newAthletes
            classes = newClasses
        } catch is CancellationError {
            return
        } catch {
            guard generation == loadGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }

    func addAttendance(athleteID: UUID, classID: UUID, attendedOn: Date) async -> String? {
        do {
            try await client.post(
                .attendance,
                body: CreateAttendanceRequest(
                    athleteID: athleteID,
                    classID: classID,
                    attendedOn: attendedOn
                )
            )
            await loadData()
            return nil
        } catch is CancellationError {
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func updateAttendance(
        attendance: Attendance,
        athleteID: UUID,
        classID: UUID,
        attendedOn: Date
    ) async -> String? {
        do {
            try await client.put(
                .attendance,
                id: attendance.id,
                body: CreateAttendanceRequest(
                    athleteID: athleteID,
                    classID: classID,
                    attendedOn: attendedOn
                )
            )
            await loadData()
            return nil
        } catch is CancellationError {
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func deleteAttendance(_ record: Attendance) async {
        do {
            try await client.delete(.attendance, id: record.id)
            // The server confirmed deletion. Reflect it immediately even if
            // the subsequent refresh cannot reach the server.
            attendance.removeAll { $0.id == record.id }
            await loadData()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
