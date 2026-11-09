import Foundation
import Combine

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published private(set) var analytics: AnalyticsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            analytics = try await APIClient.shared.get(.analytics, as: AnalyticsResponse.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
