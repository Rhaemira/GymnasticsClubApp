import Foundation
import Combine

@MainActor
final class AthletesViewModel: ObservableObject {
    private let client: any APIClientProtocol
    private var loadGeneration = 0

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var athletes: [Athlete] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadAthletes() async {
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
            let rows = try await client.get(.athletes, as: [Athlete].self)
            guard generation == loadGeneration else { return }
            athletes = rows
        } catch is CancellationError {
            return
        } catch {
            guard generation == loadGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }

    func addAthlete(fullName: String, age: Int, level: String) async -> String? {
        do {
            try await client.post(
                .athletes,
                body: CreateAthleteRequest(fullName: fullName, age: age, level: level)
            )
            await loadAthletes()
            return nil
        } catch is CancellationError {
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func updateAthlete(athlete: Athlete, fullName: String, age: Int, level: String) async -> String? {
        do {
            try await client.put(
                .athletes,
                id: athlete.id,
                body: CreateAthleteRequest(fullName: fullName, age: age, level: level)
            )
            await loadAthletes()
            return nil
        } catch is CancellationError {
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func deleteAthlete(_ athlete: Athlete) async {
        do {
            try await client.delete(.athletes, id: athlete.id)
            athletes.removeAll { $0.id == athlete.id }
            await loadAthletes()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
