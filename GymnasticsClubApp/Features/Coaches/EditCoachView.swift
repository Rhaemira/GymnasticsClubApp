//
//  EditCoachView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct EditCoachView: View {

    let coach: Coach

    let onSave: (String, String) async -> Void

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var fullName: String

    @State
    private var specialty: String

    init(
        coach: Coach,
        onSave: @escaping (String, String) async -> Void
    ) {

        self.coach = coach
        self.onSave = onSave

        _fullName = State(initialValue: coach.fullName)
        _specialty = State(initialValue: coach.specialty)

    }

    var body: some View {

        NavigationStack {

            Form {

                TextField(
                    "Full Name",
                    text: $fullName
                )

                TextField(
                    "Specialty",
                    text: $specialty
                )

            }

            .navigationTitle("Edit Coach")

            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

                ToolbarItem(placement: .confirmationAction) {

                    Button("Save") {

                        Task {

                            await onSave(
                                fullName,
                                specialty
                            )

                            dismiss()

                        }

                    }
                    .disabled(
                        fullName.isEmpty ||
                        specialty.isEmpty
                    )

                }

            }

        }

    }

}