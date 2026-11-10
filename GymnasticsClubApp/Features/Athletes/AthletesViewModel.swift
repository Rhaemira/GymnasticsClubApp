import Foundation
import Combine

@MainActor
final class AthletesViewModel: ObservableObject {
    private let client: any APIClientProtocol

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var athletes: [Athlete] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadAthletes() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            athletes = try await client.get(.athletes, as: [Athlete].self)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addAthlete(fullName: String, age: Int, level: String) async -> String? {
        do {
            try await client.post(.athletes, body: CreateAthleteRequest(fullName: fullName, age: age, level: level))
            await loadAthletes()
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func updateAthlete(athlete: Athlete, fullName: String, age: Int, level: String) async -> String? {
        do {
            try await client.put(.athletes, id: athlete.id, body: CreateAthleteRequest(fullName: fullName, age: age, level: level))
            await loadAthletes()
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func deleteAthlete(_ athlete: Athlete) async {
        do {
            try await client.delete(.athletes, id: athlete.id)
            await loadAthletes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
