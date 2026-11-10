//
//  CoachFormView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct CoachFormView: View {

    let title: String
    let buttonTitle: String

    var coach: Coach?

    let onSave: (String, String) async -> String?

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var fullName = ""

    @State
    private var specialty = ""

    @State
    private var saving = false

    @State
    private var validationMessage: String?

    var body: some View {

        NavigationStack {

            ZStack {

                AppBackground(
                    color: FeatureColors.coaches
                )

                ScrollView {

                    VStack(spacing: 28) {

                        hero

                        fields

                        saveButton

                    }

                    .padding()

                }

            }

            .navigationTitle(title)

            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

            }

            .onAppear {

                guard let coach else { return }

                fullName = coach.fullName
                specialty = coach.specialty

            }

        }

    }

    private var hero: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.coaches.opacity(0.18)
                    )

                    .frame(width: 110, height: 110)

                Image(systemName: "person.3.fill")

                    .font(.system(size: 52))

                    .foregroundStyle(
                        FeatureColors.coaches.gradient
                    )

            }

            Text(title)

                .font(
                    .system(
                        size: 32,
                        weight: .bold,
                        design: .rounded
                    )
                )

        }

    }

    private var fields: some View {

        VStack(spacing: 20) {

            GlassTextField(

                title: "Coach Name",

                text: $fullName,

                icon: "person.fill",

                color: FeatureColors.coaches

            )

            GlassTextField(

                title: "Specialty",

                text: $specialty,

                icon: "star.fill",

                color: FeatureColors.coaches

            )

        }

    }

    @ViewBuilder
    private var saveButton: some View {

        Button {

            guard !saving else { return }
            if let message = GymnasticsFormValidation.coach(fullName: fullName, specialty: specialty) {
                validationMessage = message
                return
            }

            Task {

                saving = true

                let saveError = await onSave(

                    fullName,

                    specialty

                )

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

                Text(buttonTitle)

                    .font(.headline)

            }

            .foregroundStyle(.white)

            .frame(maxWidth: .infinity)

            .padding()

            .background(

                LinearGradient(

                    colors: [

                        FeatureColors.coaches,

                        .mint

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
