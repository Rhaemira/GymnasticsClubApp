//
//  AddAttendanceView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct AddAttendanceView: View {

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
    private var selectedAthleteID: UUID?

    @State
    private var selectedClassID: UUID?

    @State
    private var attendedOn = Date()

    @State
    private var isSaving = false

    var body: some View {

        NavigationStack {

            Form {

                Section("Athlete") {

                    Picker(
                        "Athlete",
                        selection: $selectedAthleteID
                    ) {

                        Text("Select Athlete")
                            .tag(nil as UUID?)

                        ForEach(athletes) { athlete in

                            Text(athlete.fullName)
                                .tag(Optional(athlete.id))

                        }

                    }

                }

                Section("Class") {

                    Picker(
                        "Class",
                        selection: $selectedClassID
                    ) {

                        Text("Select Class")
                            .tag(nil as UUID?)

                        ForEach(classes) { gymClass in

                            Text(gymClass.name)
                                .tag(Optional(gymClass.id))

                        }

                    }

                }

                Section("Date") {

                    DatePicker(

                        "Attendance Date",

                        selection: $attendedOn,
                        
                        in: ...Date(),

                        displayedComponents: [.date, .hourAndMinute]

                    )

                }

            }
            .navigationTitle("Attendance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

                ToolbarItem(placement: .confirmationAction) {

                    Button {

                        Task {

                            await save()

                        }

                    } label: {

                        if isSaving {

                            ProgressView()

                        } else {

                            Text("Save")

                        }

                    }
                    .disabled(
                        selectedAthleteID == nil ||
                        selectedClassID == nil ||
                        isSaving
                    )

                }

            }

        }

    }

    private func save() async {

        guard

            let athleteID = selectedAthleteID,

            let classID = selectedClassID

        else {

            return

        }

        isSaving = true

        await onSave(

            athleteID,

            classID,

            attendedOn

        )

        isSaving = false

        dismiss()

    }

}

#Preview {

    AddAttendanceView(

        athletes: [],

        classes: []

    ) { _, _, _ in }

}
