import Foundation
import Combine

@MainActor
final class AthletesViewModel: ObservableObject {
    @Published private(set) var athletes: [Athlete] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadAthletes() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            athletes = try await APIClient.shared.get(.athletes, as: [Athlete].self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addAthlete(fullName: String, age: Int, level: String) async -> Bool {
        do {
            try await APIClient.shared.post(.athletes, body: CreateAthleteRequest(fullName: fullName, age: age, level: level))
            await loadAthletes()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateAthlete(athlete: Athlete, fullName: String, age: Int, level: String) async -> Bool {
        do {
            try await APIClient.shared.put(.athletes, id: athlete.id, body: CreateAthleteRequest(fullName: fullName, age: age, level: level))
            await loadAthletes()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteAthlete(_ athlete: Athlete) async {
        do {
            try await APIClient.shared.delete(.athletes, id: athlete.id)
            await loadAthletes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
