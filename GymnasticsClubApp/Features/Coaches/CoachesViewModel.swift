import Foundation
import Combine

@MainActor
final class CoachesViewModel: ObservableObject {
    private let client: any APIClientProtocol

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var coaches: [Coach] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCoaches() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            coaches = try await client.get(.coaches, as: [Coach].self)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addCoach(fullName: String, specialty: String) async -> String? {
        do {
            try await client.post(.coaches, body: CreateCoachRequest(fullName: fullName, specialty: specialty))
            await loadCoaches()
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func updateCoach(coach: Coach, fullName: String, specialty: String) async -> String? {
        do {
            try await client.put(.coaches, id: coach.id, body: CreateCoachRequest(fullName: fullName, specialty: specialty))
            await loadCoaches()
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func deleteCoach(_ coach: Coach) async {
        do {
            try await client.delete(.coaches, id: coach.id)
            await loadCoaches()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
