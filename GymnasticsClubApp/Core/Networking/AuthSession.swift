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

enum SessionTokenPolicy {
    static func shouldExpire(requestToken: String, currentToken: String?) -> Bool {
        currentToken == requestToken
    }
}

@MainActor
final class AuthSession: ObservableObject {
    static let shared = AuthSession()
    @Published private(set) var isAuthenticated = KeychainTokenStore.read() != nil
    @Published private(set) var isRestoring = KeychainTokenStore.read() != nil
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
        guard isAuthenticated else {
            isRestoring = false
            return
        }

        isRestoring = true
        defer { isRestoring = false }

        do {
            user = try await APIClient.shared.get(.currentUser, as: AuthenticatedUser.self)
            errorMessage = nil
        } catch let error as NetworkError where error.isAuthenticationFailure {
            sessionExpired()
        } catch {
            // A timeout, offline device or 5xx response is not proof that the
            // token is invalid. Preserve the Keychain credential for retry.
            errorMessage = "The club server could not be reached. Your sign-in is saved; check the connection and retry."
        }
    }

    func retryRestore() async {
        await restore()
    }

    func clearError() {
        errorMessage = nil
    }

    func signOut() async {
        var remoteRevocationUnconfirmed = false
        do {
            try await APIClient.shared.logout()
        } catch let error as NetworkError where error.isAuthenticationFailure {
            // The server has already rejected this credential.
        } catch {
            remoteRevocationUnconfirmed = true
        }

        // Always remove the local credential, even when the device is offline.
        KeychainTokenStore.delete()
        isAuthenticated = false
        user = nil
        errorMessage = remoteRevocationUnconfirmed
            ? "Signed out on this device. The server could not confirm token revocation; the token will expire automatically."
            : nil
    }

    func sessionExpired(ifCurrentTokenMatches requestToken: String? = nil) {
        if let requestToken, !SessionTokenPolicy.shouldExpire(requestToken: requestToken, currentToken: KeychainTokenStore.read()) {
            return
        }
        KeychainTokenStore.delete()
        isAuthenticated = false
        user = nil
        errorMessage = "Your session expired. Please sign in again."
    }
}
