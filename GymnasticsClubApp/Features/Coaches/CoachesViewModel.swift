//
//  CoachesViewModel.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import Foundation
import Combine

@MainActor
final class CoachesViewModel: ObservableObject {

    @Published
    private(set) var coaches: [Coach] = []

    @Published
    var isLoading = false

    @Published
    var errorMessage: String?

    func loadCoaches() async {

        isLoading = true
        errorMessage = nil

        defer {

            isLoading = false

        }

        do {

            coaches = try await APIClient.shared.get(
                .coaches,
                as: [Coach].self
            )

        } catch {

            errorMessage = error.localizedDescription
            return false
        }

    }

    func addCoach(
        fullName: String,
        specialty: String
    ) async {

        let request = CreateCoachRequest(
            fullName: fullName,
            specialty: specialty
        )

        do {

            try await APIClient.shared.post(
                .coaches,
                body: request
            )

            await loadCoaches()

        } catch {

            errorMessage = error.localizedDescription

        }

    }

    func deleteCoach(_ coach: Coach) async {

        do {

            try await APIClient.shared.delete(
                .coaches,
                id: coach.id
            )

            await loadCoaches()

        } catch {

            errorMessage = error.localizedDescription

        }

    }
    
    func updateCoach(
        coach: Coach,
        fullName: String,
        specialty: String
    ) async {

        let request = CreateCoachRequest(
            fullName: fullName,
            specialty: specialty
        )

        do {

            try await APIClient.shared.put(
                .coaches,
                id: coach.id,
                body: request
            )

            await loadCoaches()

        } catch {

            errorMessage = error.localizedDescription

        }

    }

}
