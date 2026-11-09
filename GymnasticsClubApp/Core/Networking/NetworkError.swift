//
//  NetworkError.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import Foundation

enum NetworkError: LocalizedError {

    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case encodingError
    case unknown

    var errorDescription: String? {

        switch self {

        case .invalidURL:
            return "Invalid URL."

        case .invalidResponse:
            return "Invalid server response."

        case .serverError(let code):
            return "Server returned status code \(code)."

        case .decodingError:
            return "Failed to decode server response."

        case .encodingError:
            return "Failed to encode request."

        case .unknown:
            return "An unknown error occurred."
        }
    }
}