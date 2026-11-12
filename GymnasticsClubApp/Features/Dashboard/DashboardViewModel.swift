//
//  DashboardViewModel.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    private let client: any APIClientProtocol

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }


    @Published private(set) var stats: DashboardStats?
    @Published private(set) var attendance: [Attendance] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadDashboard() async {

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {

            let fetchedStats = try await client.get(.reports, as: DashboardStats.self)
            let fetchedAttendance = try await client.get(.attendance, as: [Attendance].self)

            stats      = fetchedStats
            attendance = fetchedAttendance

        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }

    }

}
