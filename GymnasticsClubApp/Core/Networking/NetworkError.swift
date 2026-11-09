import Foundation
import Security

enum NetworkError: LocalizedError {
    case invalidURL, invalidResponse
    case serverError(Int, String?)
    case decodingError, encodingError
    case keychainFailure(OSStatus)
    case authenticationRequired
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API URL is invalid."
        case .invalidResponse: return "The server returned an invalid response."
        case .serverError(let code, let message): return message ?? "The server returned HTTP \(code)."
        case .decodingError: return "The server response could not be read."
        case .encodingError: return "The request could not be encoded."
        case .keychainFailure(let status): return "Secure token storage failed (\(status))."
        case .authenticationRequired: return "Your session has expired. Please sign in again."
        case .unknown: return "An unexpected network error occurred."
        }
    }
}
