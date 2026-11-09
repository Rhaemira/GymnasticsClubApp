//
//  AttendanceViewModel.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import Foundation
import Combine

@MainActor
final class AttendanceViewModel: ObservableObject {

    @Published
    private(set) var attendance: [Attendance] = []

    @Published
    private(set) var athletes: [Athlete] = []

    @Published
    private(set) var classes: [GymClass] = []

    @Published
    var isLoading = false

    @Published
    var errorMessage: String?

    func loadData() async {

        isLoading = true
        errorMessage = nil

        defer {

            isLoading = false

        }

        do {

            async let attendanceRequest =
                APIClient.shared.get(
                    .attendance,
                    as: [Attendance].self
                )

            async let athletesRequest =
                APIClient.shared.get(
                    .athletes,
                    as: [Athlete].self
                )

            async let classesRequest =
                APIClient.shared.get(
                    .classes,
                    as: [GymClass].self
                )

            attendance = try await attendanceRequest

            athletes = try await athletesRequest

            classes = try await classesRequest

        } catch {

            errorMessage = error.localizedDescription

        }

    }

    func addAttendance(
        athleteID: UUID,
        classID: UUID,
        attendedOn: Date
    ) async {

        let request = CreateAttendanceRequest(

            athleteID: athleteID,

            classID: classID,

            attendedOn: attendedOn

        )

        do {

            try await APIClient.shared.post(
                .attendance,
                body: request
            )

            await loadData()

        } catch {

            errorMessage = error.localizedDescription

        }

    }
    
    func updateAttendance(
        attendance: Attendance,
        athleteID: UUID,
        classID: UUID,
        attendedOn: Date
    ) async {

        let request = CreateAttendanceRequest(

            athleteID: athleteID,

            classID: classID,

            attendedOn: attendedOn

        )

        do {

            try await APIClient.shared.put(

                .attendance,

                id: attendance.id,

                body: request

            )

            await loadData()

        } catch {

            errorMessage = error.localizedDescription

        }

    }
    
    func deleteAttendance(
        _ attendance: Attendance
    ) async {

        do {

            try await APIClient.shared.delete(
                .attendance,
                id: attendance.id
            )

            await loadData()

        } catch {

            errorMessage = error.localizedDescription

        }

    }

}


