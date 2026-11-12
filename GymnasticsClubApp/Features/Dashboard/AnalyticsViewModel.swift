import Foundation
import Combine

@MainActor
final class AnalyticsViewModel: ObservableObject {
    private let client: any APIClientProtocol

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var analytics: AnalyticsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            analytics = try await client.get(.analytics, as: AnalyticsResponse.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
