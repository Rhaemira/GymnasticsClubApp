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
    private var selectedAthleteID: UUID?

    @State
    private var selectedClassID: UUID?

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

                            selectedAthleteID: $selectedAthleteID,

                            selectedClassID: $selectedClassID,

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

                    selectedAthleteID = attendance.athlete.id

                    selectedClassID = attendance.gymClass.id

                    attendedOn = attendance.attendedOn

                }

            }
            .onChange(of: viewModel.athletes.map(\.id)) { _, ids in
                guard !ids.isEmpty else { return }
                if let selectedAthleteID, ids.contains(selectedAthleteID) { return }
                selectedAthleteID = ids.first
            }
            .onChange(of: viewModel.classes.map(\.id)) { _, ids in
                guard !ids.isEmpty else { return }
                if let selectedClassID, ids.contains(selectedClassID) { return }
                selectedClassID = ids.first
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

            guard !saving else { return }
            if let message = GymnasticsFormValidation.attendance(
                hasAthlete: selectedAthleteID != nil,
                hasClass: selectedClassID != nil,
                attendedOn: attendedOn
            ) {
                validationMessage = message
                return
            }
            guard let athleteID = selectedAthleteID,
                  let classID = selectedClassID,
                  viewModel.athletes.contains(where: { $0.id == athleteID }),
                  viewModel.classes.contains(where: { $0.id == classID }) else {
                validationMessage = "Choose an available athlete and class."
                return
            }

            Task {

                saving = true

                let saveError: String?
                if let attendance {

                    saveError = await viewModel.updateAttendance(

                        attendance: attendance,

                        athleteID: athleteID,

                        classID: classID,

                        attendedOn: attendedOn

                    )

                }

                else {

                    saveError = await viewModel.addAttendance(

                        athleteID: athleteID,

                        classID: classID,

                        attendedOn: attendedOn

                    )

                }

                saving = false
                if let saveError { validationMessage = saveError } else { dismiss() }
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