//
//  AttendanceEditorView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct AttendanceEditorView: View {

    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject
    var viewModel: AttendanceViewModel

    var attendance: Attendance?

    @State
    private var selectedAthlete: Athlete?

    @State
    private var selectedClass: GymClass?

    @State
    private var attendedOn = Date()

    @State
    private var saving = false

    @State
    private var validationMessage: String?

    var body: some View {

        NavigationStack {

            ZStack {

                AppBackground(
                    color: FeatureColors.attendance
                )

                ScrollView {

                    VStack(spacing: 28) {

                        hero

                        AttendanceFormView(

                            athletes: viewModel.athletes,

                            classes: viewModel.classes,

                            selectedAthlete: $selectedAthlete,

                            selectedClass: $selectedClass,

                            attendedOn: $attendedOn

                        )
                        .scrollContentBackground(.hidden)
                        .background(.clear)

                        saveButton

                    }

                    .padding()

                }

            }

            .navigationTitle(

                attendance == nil ?

                "New Attendance"

                :

                "Edit Attendance"

            )

            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

            }

            .onAppear {

                if let attendance {

                    selectedAthlete = viewModel.athletes.first {

                        $0.id == attendance.athlete.id

                    }

                    selectedClass = viewModel.classes.first {

                        $0.id == attendance.gymClass.id

                    }

                    attendedOn = attendance.attendedOn

                }

            }

        }

    }

    private var hero: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.attendance.opacity(0.18)
                    )

                    .frame(width: 110,height:110)

                Image(systemName: "checkmark.circle.fill")

                    .font(.system(size: 52))

                    .foregroundStyle(
                        FeatureColors.attendance.gradient
                    )

            }

            Text(

                attendance == nil ?

                "Record Attendance"

                :

                "Update Attendance"

            )

            .font(

                .system(

                    size: 32,

                    weight: .bold,

                    design: .rounded

                )

            )

        }

    }

    @ViewBuilder
    private var saveButton: some View {

        Button {

            guard

                let athlete = selectedAthlete,

                let gymClass = selectedClass

            else {

                return

            }

            Task {

                saving = true

                let succeeded: Bool
                if let attendance {

                    succeeded = await viewModel.updateAttendance(

                        attendance: attendance,

                        athleteID: athlete.id,

                        classID: gymClass.id,

                        attendedOn: attendedOn

                    )

                }

                else {

                    succeeded = await viewModel.addAttendance(

                        athleteID: athlete.id,

                        classID: gymClass.id,

                        attendedOn: attendedOn

                    )

                }

                saving = false
                if succeeded { dismiss() }
                else { validationMessage = viewModel.errorMessage ?? "Could not save attendance." }
            }

        } label: {

            HStack {

                if saving {

                    ProgressView()

                }

                else {

                    Image(systemName: "checkmark.circle.fill")

                }

                Text("Save")

                    .font(.headline)

            }

            .foregroundStyle(.white)

            .frame(maxWidth: .infinity)

            .padding()

            .background(

                LinearGradient(

                    colors: [

                        FeatureColors.attendance,

                        .purple.opacity(0.65)

                    ],

                    startPoint: .leading,

                    endPoint: .trailing

                )

            )

            .clipShape(

                RoundedRectangle(

                    cornerRadius: 18

                )

            )

        }

        .disabled(saving)
        if let validationMessage { Text(validationMessage).font(.footnote).foregroundStyle(.red) }
    }

}