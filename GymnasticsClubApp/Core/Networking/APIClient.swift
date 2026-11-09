//
//  APIClient.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//

import Foundation

final class APIClient {

    static let shared = APIClient()

    private init() {}

    private let baseURL = URL(string: "http://127.0.0.1:8080")!

    // MARK: - JSON

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        // .iso8601 only handles "2026-07-19T14:30:00Z" — it chokes on
        // fractional seconds ("...00.000Z") which most backends emit.
        // This custom strategy tries three formats in order so we handle
        // whatever the server sends without silently falling back to epoch.
        let withFractional: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            f.timeZone = TimeZone(secondsFromGMT: 0)
            return f
        }()

        let withoutFractional: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            f.timeZone = TimeZone(secondsFromGMT: 0)
            return f
        }()

        let dateOnly: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "yyyy-MM-dd"
            f.timeZone = TimeZone(secondsFromGMT: 0)
            return f
        }()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string    = try container.decode(String.self)

            if let date = withFractional.date(from: string)    { return date }
            if let date = withoutFractional.date(from: string) { return date }
            if let date = dateOnly.date(from: string)          { return date }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot parse date: \(string)"
            )
        }

        return decoder
    }()

}

// MARK: - Requests

extension APIClient {

    func get<T: Decodable>(
        _ endpoint: Endpoint,
        as type: T.Type
    ) async throws -> T {

        let url = baseURL.appendingPathComponent(endpoint.path)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw NetworkError.serverError(response.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }

    }

    func post<T: Encodable>(
        _ endpoint: Endpoint,
        body: T
    ) async throws {

        let url = baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw NetworkError.encodingError
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw NetworkError.serverError(response.statusCode)
        }

    }

    func put<T: Encodable>(
        _ endpoint: Endpoint,
        id: UUID,
        body: T
    ) async throws {

        let url = baseURL
            .appendingPathComponent(endpoint.path)
            .appendingPathComponent(id.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw NetworkError.encodingError
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw NetworkError.serverError(response.statusCode)
        }

    }

    func delete(
        _ endpoint: Endpoint,
        id: UUID
    ) async throws {

        let url = baseURL
            .appendingPathComponent(endpoint.path)
            .appendingPathComponent(id.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw NetworkError.serverError(response.statusCode)
        }

    }

}
