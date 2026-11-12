//
//  AthleteFormView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct AthleteFormView: View {

    let title: String
    let buttonTitle: String

    var athlete: Athlete?

    let onSave: (String, Int, String) async -> String?

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var fullName = ""

    @State
    private var age = ""

    @State
    private var level = "Beginner"

    @State
    private var saving = false

    @State
    private var validationMessage: String?

    private let levels = [
        "Beginner",
        "Intermediate",
        "Advanced",
        "Elite"
    ]

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 28) {

                    hero

                    fields

                    saveButton

                }

                .padding()

            }

            .background(

                AppBackground(
                    color: FeatureColors.athletes
                )

            )

            .navigationBarTitleDisplayMode(.inline)

            .navigationTitle(title)

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

            }

            .onAppear {

                guard let athlete else { return }

                fullName = athlete.fullName
                age = "\(athlete.age)"
                level = athlete.level

            }

        }

    }

    private var hero: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.athletes.opacity(0.15)
                    )

                    .frame(width: 110, height: 110)

                Image(systemName: "figure.gymnastics")

                    .font(.system(size: 54))

                    .foregroundStyle(
                        FeatureColors.athletes.gradient
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

        .padding(.top)

    }

    private var fields: some View {

        VStack(spacing: 22) {

            GlassTextField(

                title: "Full Name",

                text: $fullName,

                icon: "person.fill",

                color: FeatureColors.athletes

            )

            GlassTextField(

                title: "Age",

                text: $age,

                icon: "birthday.cake.fill",

                color: FeatureColors.athletes,

                type: .numeric

            )

            VStack(alignment: .leading, spacing: 12) {

                Text("Level")

                    .font(.headline)

                Picker("", selection: $level) {

                    ForEach(levels, id: \.self) {

                        Text($0)

                    }

                }

                .pickerStyle(.segmented)

            }

            .padding()

            .background(.ultraThinMaterial)

            .clipShape(

                RoundedRectangle(cornerRadius: 22)

            )

        }

    }

    @ViewBuilder
    private var saveButton: some View {

        Button {

            guard !saving else { return }
            guard let ageValue = Int(age) else {
                validationMessage = "Enter a valid age between 1 and 120."
                return
            }
            if let message = GymnasticsFormValidation.athlete(fullName: fullName, age: ageValue) {
                validationMessage = message
                return
            }

            Task {

                saving = true

                let saveError = await onSave(

                    fullName,

                    ageValue,

                    level

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

                        FeatureColors.athletes,

                        .cyan

                    ],

                    startPoint: .leading,

                    endPoint: .trailing

                )

            )

            .clipShape(

                RoundedRectangle(cornerRadius: 18)

            )

        }

        .disabled(saving)
        if let validationMessage { Text(validationMessage).font(.footnote).foregroundStyle(.red) }
    }

}
