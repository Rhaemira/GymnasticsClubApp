//
//  ClassFormView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct ClassFormView: View {

    let title: String
    let buttonTitle: String

    var gymClass: GymClass? = nil

    let coaches: [Coach]

    let onSave: (String, Coach, Int) async -> String?

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var name = ""

    @State
    private var capacity = ""

    @State
    private var selectedCoach: Coach?

    @State
    private var saving = false

    @State
    private var validationMessage: String?

    var body: some View {

        NavigationStack {

            ZStack {

                AppBackground(
                    color: FeatureColors.classes
                )

                ScrollView {

                    VStack(spacing: 30) {

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

                if let gymClass {

                    name = gymClass.name
                    capacity = "\(gymClass.capacity)"

                    selectedCoach = coaches.first {

                        $0.id == gymClass.coach.id

                    }

                }

                else {

                    selectedCoach = coaches.first

                }

            }

        }

    }

    private var hero: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.classes.opacity(0.18)
                    )

                    .frame(width: 110, height: 110)

                Image(systemName: "figure.flexibility")

                    .font(.system(size: 52))

                    .foregroundStyle(
                        FeatureColors.classes.gradient
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

                title: "Class Name",

                text: $name,

                icon: "figure.flexibility",

                color: FeatureColors.classes

            )

            GlassTextField(

                title: "Capacity",

                text: $capacity,

                icon: "person.2.fill",

                color: FeatureColors.classes,

                type: .numeric

            )

            VStack(alignment: .leading, spacing: 8) {

                Text("Coach")

                    .font(.headline)

                Picker(
                    "Coach",
                    selection: $selectedCoach
                ) {

                    ForEach(coaches) { coach in

                        Text(coach.fullName)

                            .tag(Optional(coach))

                    }

                }

                .pickerStyle(.menu)

                .padding()

                .frame(maxWidth: .infinity)

                .background(.ultraThinMaterial)

                .clipShape(

                    RoundedRectangle(
                        cornerRadius: 18
                    )

                )

            }

        }

    }

    @ViewBuilder
    private var saveButton: some View {

        Button {

            guard

                let coach = selectedCoach,

                let cap = Int(capacity),
                cap > 0,
                !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

            else {
                validationMessage = "Enter a class name, select a coach, and use a positive capacity."
                return
            }

            Task {

                saving = true

                let saveError = await onSave(
                    name,
                    coach,
                    cap
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

                        FeatureColors.classes,

                        .yellow

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
