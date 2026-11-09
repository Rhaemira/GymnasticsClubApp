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
    private var selectedAthlete: Athlete?

    @State
    private var selectedClass: GymClass?

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
                        selection: $selectedAthlete
                    ) {

                        Text("Select Athlete")
                            .tag(nil as Athlete?)

                        ForEach(athletes) { athlete in

                            Text(athlete.fullName)
                                .tag(athlete as Athlete?)

                        }

                    }

                }

                Section("Class") {

                    Picker(
                        "Class",
                        selection: $selectedClass
                    ) {

                        Text("Select Class")
                            .tag(nil as GymClass?)

                        ForEach(classes) { gymClass in

                            Text(gymClass.name)
                                .tag(gymClass as GymClass?)

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
                        selectedAthlete == nil ||
                        selectedClass == nil ||
                        isSaving
                    )

                }

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

    AddAttendanceView(

        athletes: [],

        classes: []

    ) { _, _, _ in }

}
