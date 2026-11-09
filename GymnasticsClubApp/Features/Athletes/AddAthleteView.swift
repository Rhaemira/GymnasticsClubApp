//
//  AddAthleteView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct AddAthleteView: View {

    @Environment(\.dismiss)
    private var dismiss

    let onSave: (String, Int, String) async -> Void

    @State
    private var fullName = ""

    @State
    private var age = ""

    @State
    private var level = "Beginner"

    @State
    private var isSaving = false

    private let levels = [
        "Beginner",
        "Intermediate",
        "Advanced",
        "Elite"
    ]
    
    private var canSave: Bool {

        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(age) != nil

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
                        "Age",
                        text: $age
                    )
                    .keyboardType(.numberPad)

                    Picker("Level", selection: $level) {

                        ForEach(levels, id: \.self) { level in

                            Text(level)

                        }

                    }

                }

            }
            .navigationTitle("New Athlete")
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Cancel") {
                        dismiss()
                    }

                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Save") {

                        guard
                            let athleteAge = Int(age),
                            !fullName.isEmpty
                        else {
                            return
                        }

                        Task {

                            isSaving = true

                            await onSave(
                                fullName,
                                athleteAge,
                                level
                            )

                            isSaving = false

                            dismiss()

                        }

                    }
                    .disabled(!canSave || isSaving)
                    .bold()

                }

            }

        }

    }

}
