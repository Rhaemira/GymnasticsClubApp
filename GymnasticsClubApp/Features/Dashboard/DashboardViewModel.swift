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

    @Published private(set) var stats: DashboardStats?
    @Published private(set) var attendance: [Attendance] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadDashboard() async {

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {

            let fetchedStats = try await APIClient.shared.get(.reports, as: DashboardStats.self)
            let fetchedAttendance = try await APIClient.shared.get(.attendance, as: [Attendance].self)

            stats      = fetchedStats
            attendance = fetchedAttendance

        } catch {

            errorMessage = error.localizedDescription

        }

    }

}
