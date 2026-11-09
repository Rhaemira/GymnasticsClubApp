//
//  AttendanceFormView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct AttendanceFormView: View {

    let athletes: [Athlete]
    let classes: [GymClass]

    @Binding
    var selectedAthlete: Athlete?

    @Binding
    var selectedClass: GymClass?

    @Binding
    var attendedOn: Date

    var body: some View {

        VStack(spacing: 24) {

            VStack(alignment: .leading, spacing: 10) {

                Label(
                    "Athlete",
                    systemImage: "figure.gymnastics"
                )
                .font(.headline)

                Picker(
                    "Athlete",
                    selection: $selectedAthlete
                ) {

                    Text("Select Athlete")
                        .tag(nil as Athlete?)

                    ForEach(athletes) { athlete in

                        Text(athlete.fullName)
                            .tag(Optional(athlete))

                    }

                }

                .pickerStyle(.menu)

                .padding()

                .frame(maxWidth: .infinity)

                .background(.ultraThinMaterial)

                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

            }

            VStack(alignment: .leading, spacing: 10) {

                Label(
                    "Class",
                    systemImage: "figure.flexibility"
                )
                .font(.headline)

                Picker(
                    "Class",
                    selection: $selectedClass
                ) {

                    Text("Select Class")
                        .tag(nil as GymClass?)

                    ForEach(classes) { gymClass in

                        Text(gymClass.name)
                            .tag(Optional(gymClass))

                    }

                }

                .pickerStyle(.menu)

                .padding()

                .frame(maxWidth: .infinity)

                .background(.ultraThinMaterial)

                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

            }

            VStack(alignment: .leading, spacing: 10) {

                Label(
                    "Date",
                    systemImage: "calendar"
                )
                .font(.headline)

                DatePicker(
                    "",
                    selection: $attendedOn,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )

                .labelsHidden()

                .datePickerStyle(.graphical)

                .padding()

                .background(.ultraThinMaterial)

                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

            }

        }

    }

}
