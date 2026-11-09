//
//  EditAttendanceView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct EditAttendanceView: View {

    let attendance: Attendance

    let athletes: [Athlete]

    let classes: [GymClass]

    let onSave: (
        UUID,
        UUID,
        Date
    ) async -> Void

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var selectedAthlete: Athlete?

    @State
    private var selectedClass: GymClass?

    @State
    private var attendedOn = Date()

    @State
    private var isSaving = false

    var body: some View {

        NavigationStack {

            AttendanceFormView(

                athletes: athletes,

                classes: classes,

                selectedAthlete: $selectedAthlete,

                selectedClass: $selectedClass,

                attendedOn: $attendedOn

            )
            .navigationTitle("Edit Attendance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button("Save") {

                        Task {

                            await save()

                        }

                    }
                    .disabled(
                        selectedAthlete == nil ||
                        selectedClass == nil ||
                        isSaving
                    )

                }

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

            }

        }
        .onAppear {

            attendedOn = attendance.attendedOn

            selectedAthlete = athletes.first {

                $0.id == attendance.athlete.id

            }

            selectedClass = classes.first {

                $0.id == attendance.gymClass.id

            }

        }

    }

    private func save() async {

        guard

            let athlete = selectedAthlete,

            let gymClass = selectedClass

        else {

            return

        }

        isSaving = true

        await onSave(

            athlete.id,

            gymClass.id,

            attendedOn

        )

        isSaving = false

        dismiss()

    }

}

#Preview {

    Text("Preview")

}