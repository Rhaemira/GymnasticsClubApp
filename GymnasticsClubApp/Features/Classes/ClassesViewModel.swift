import Foundation
import Combine

@MainActor
final class ClassesViewModel: ObservableObject {
    private let client: any APIClientProtocol

    init(client: any APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    @Published private(set) var classes: [GymClass] = []
    @Published private(set) var coaches: [Coach] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadClasses() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let classRows = client.get(.classes, as: [GymClass].self)
            async let coachRows = client.get(.coaches, as: [Coach].self)
            classes = try await classRows
            coaches = try await coachRows
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addClass(name: String, capacity: Int, coachID: UUID) async -> String? {
        do {
            try await client.post(.classes, body: CreateClassRequest(name: name, capacity: capacity, coachID: coachID))
            await loadClasses()
            return nil
        } catch { errorMessage = error.localizedDescription; return error.localizedDescription }
    }

    func updateClass(gymClass: GymClass, name: String, capacity: Int, coachID: UUID) async -> String? {
        do {
            try await client.put(.classes, id: gymClass.id, body: CreateClassRequest(name: name, capacity: capacity, coachID: coachID))
            await loadClasses()
            return nil
        } catch { errorMessage = error.localizedDescription; return error.localizedDescription }
    }

    func deleteClass(_ gymClass: GymClass) async {
        do {
            try await client.delete(.classes, id: gymClass.id)
            await loadClasses()
        } catch { errorMessage = error.localizedDescription }
    }
}
