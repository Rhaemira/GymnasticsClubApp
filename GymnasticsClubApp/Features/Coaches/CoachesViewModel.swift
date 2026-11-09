import Foundation
import Combine

@MainActor
final class CoachesViewModel: ObservableObject {
    @Published private(set) var coaches: [Coach] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCoaches() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            coaches = try await APIClient.shared.get(.coaches, as: [Coach].self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addCoach(fullName: String, specialty: String) async -> Bool {
        do {
            try await APIClient.shared.post(.coaches, body: CreateCoachRequest(fullName: fullName, specialty: specialty))
            await loadCoaches()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateCoach(coach: Coach, fullName: String, specialty: String) async -> Bool {
        do {
            try await APIClient.shared.put(.coaches, id: coach.id, body: CreateCoachRequest(fullName: fullName, specialty: specialty))
            await loadCoaches()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteCoach(_ coach: Coach) async {
        do {
            try await APIClient.shared.delete(.coaches, id: coach.id)
            await loadCoaches()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
