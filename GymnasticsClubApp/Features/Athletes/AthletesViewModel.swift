//
//  AthletesViewModel.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import Foundation
import Combine

@MainActor
final class AthletesViewModel: ObservableObject {

    @Published private(set) var athletes: [Athlete] = []

    @Published var isLoading = false

    @Published var errorMessage: String?

    func loadAthletes() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            athletes = try await APIClient.shared.get(
                .athletes,
                as: [Athlete].self
            )

        } catch {

            errorMessage = error.localizedDescription

        }

    }
    
    func addAthlete(
        fullName: String,
        age: Int,
        level: String
    ) async {

        let request = CreateAthleteRequest(
            fullName: fullName,
            age: age,
            level: level
        )

        do {

            try await APIClient.shared.post(
                .athletes,
                body: request
            )

            await loadAthletes()

        } catch {

            errorMessage = error.localizedDescription

        }

    }
    
    func updateAthlete(
        athlete: Athlete,
        fullName: String,
        age: Int,
        level: String
    ) async {

        let request = CreateAthleteRequest(
            fullName: fullName,
            age: age,
            level: level
        )

        do {

            try await APIClient.shared.put(
                .athletes,
                id: athlete.id,
                body: request
            )

            await loadAthletes()

        } catch {

            errorMessage = error.localizedDescription

        }

    }
    
    func deleteAthlete(_ athlete: Athlete) async {

        do {

            try await APIClient.shared.delete(
                .athletes,
                id: athlete.id
            )

            await loadAthletes()

        } catch {

            errorMessage = error.localizedDescription

        }

    }

}
