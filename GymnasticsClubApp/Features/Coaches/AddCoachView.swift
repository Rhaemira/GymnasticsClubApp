//
//  AddCoachView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct AddCoachView: View {

    @Environment(\.dismiss)
    private var dismiss

    let onSave: (String, String) async -> Void

    @State
    private var fullName = ""

    @State
    private var specialty = ""

    @State
    private var isSaving = false

    private var canSave: Bool {

        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !specialty.trimmingCharacters(in: .whitespaces).isEmpty

    }

    var body: some View {

        NavigationStack {

            Form {

                Section("Information") {

                    TextField(
                        "Full Name",
                        text: $fullName
                    )

                    TextField(
                        "Specialty",
                        text: $specialty
                    )

                }

            }
            .navigationTitle("New Coach")
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Save") {

                        Task {

                            isSaving = true

                            await onSave(
                                fullName,
                                specialty
                            )

                            isSaving = false

                            dismiss()

                        }

                    }
                    .bold()
                    .disabled(!canSave || isSaving)

                }

            }

        }

    }

}