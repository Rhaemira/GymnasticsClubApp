import Foundation
import Combine

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let expiresAt: Date
    let user: AuthenticatedUser
}

struct AuthenticatedUser: Decodable {
    let id: UUID
    let email: String
}

@MainActor
final class AuthSession: ObservableObject {
    static let shared = AuthSession()
    @Published private(set) var isAuthenticated = KeychainTokenStore.read() != nil
    @Published private(set) var user: AuthenticatedUser?
    @Published var errorMessage: String?

    private init() {}

    func signIn(email: String, password: String) async -> Bool {
        do {
            let response: LoginResponse = try await APIClient.shared.login(
                LoginRequest(email: email, password: password)
            )
            try KeychainTokenStore.save(response.token)
            user = response.user
            isAuthenticated = true
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func restore() async {
        guard isAuthenticated else { return }
        do {
            user = try await APIClient.shared.get(.currentUser, as: AuthenticatedUser.self)
        } catch {
            KeychainTokenStore.delete()
            isAuthenticated = false
            user = nil
        }
    }

    func signOut() async {
        try? await APIClient.shared.logout()
        KeychainTokenStore.delete()
        isAuthenticated = false
        user = nil
    }

    func sessionExpired() {
        KeychainTokenStore.delete()
        isAuthenticated = false
        user = nil
        errorMessage = "Your session expired. Please sign in again."
    }
}
