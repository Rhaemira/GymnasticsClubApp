//
//  ClassesViewModel.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/14/26.
//


import Foundation
import Combine

@MainActor
final class ClassesViewModel: ObservableObject {
    
    @Published
    private(set) var classes: [GymClass] = []
    
    @Published
    private(set) var coaches: [Coach] = []

    @Published
    var isLoading = false

    @Published
    var errorMessage: String?
    
    

    func loadClasses() async {

        isLoading = true
        errorMessage = nil

        defer {

            isLoading = false

        }

        do {

            async let classesRequest = APIClient.shared.get(
                .classes,
                as: [GymClass].self
            )

            async let coachesRequest = APIClient.shared.get(
                .coaches,
                as: [Coach].self
            )

            classes = try await classesRequest
            coaches = try await coachesRequest

        } catch {

            errorMessage = error.localizedDescription

        }

    }

    func addClass(
        name: String,
        capacity: Int,
        coachID: UUID
    ) async {

        let request = CreateClassRequest(
            name: name,
            capacity: capacity,
            coachID: coachID
        )

        do {

            try await APIClient.shared.post(
                .classes,
                body: request
            )

            await loadClasses()

        } catch {

            errorMessage = error.localizedDescription

        }

    }
    
    func updateClass(
        gymClass: GymClass,
        name: String,
        capacity: Int,
        coachID: UUID
    ) async {

        let request = CreateClassRequest(
            name: name,
            capacity: capacity,
            coachID: coachID
        )

        do {

            try await APIClient.shared.put(
                .classes,
                id: gymClass.id,
                body: request
            )

            await loadClasses()

        } catch {

            errorMessage = error.localizedDescription

        }

    }

    func deleteClass(_ gymClass: GymClass) async {

        do {

            try await APIClient.shared.delete(
                .classes,
                id: gymClass.id
            )

            await loadClasses()

        } catch {

            errorMessage = error.localizedDescription

        }

    }

}
