import Foundation
import Combine

@MainActor
final class ClassesViewModel: ObservableObject {
    private let client: any APIClientProtocol
    private var loadGeneration = 0

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var classes: [GymClass] = []
    @Published private(set) var coaches: [Coach] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Keep class rows and their coach references in sync across refreshes.
    func loadClasses() async {
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
            async let classRows = client.get(.classes, as: [GymClass].self)
            async let coachRows = client.get(.coaches, as: [Coach].self)
            let (newClasses, newCoaches) = try await (classRows, coachRows)

            guard generation == loadGeneration else { return }
            classes = newClasses
            coaches = newCoaches
        } catch is CancellationError {
            return
        } catch {
            guard generation == loadGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }

    func addClass(name: String, capacity: Int, coachID: UUID) async -> String? {
        do {
            try await client.post(
                .classes,
                body: CreateClassRequest(name: name, capacity: capacity, coachID: coachID)
            )
            await loadClasses()
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func updateClass(gymClass: GymClass, name: String, capacity: Int, coachID: UUID) async -> String? {
        do {
            try await client.put(
                .classes,
                id: gymClass.id,
                body: CreateClassRequest(name: name, capacity: capacity, coachID: coachID)
            )
            await loadClasses()
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func deleteClass(_ gymClass: GymClass) async {
        do {
            try await client.delete(.classes, id: gymClass.id)
            classes.removeAll { $0.id == gymClass.id }
            await loadClasses()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
