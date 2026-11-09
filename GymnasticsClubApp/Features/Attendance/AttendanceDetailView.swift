//
//  AttendanceDetailView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct AttendanceDetailView: View {

    let attendance: Attendance

    var body: some View {

        ZStack {

            AppBackground(
                color: FeatureColors.attendance
            )

            ScrollView {

                VStack(spacing: 30) {

                    header

                    infoCards

                    Spacer(minLength: 40)

                }

                .padding()

            }

        }

        .navigationTitle("Attendance")

        .navigationBarTitleDisplayMode(.inline)

    }

    private var header: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.attendance.opacity(0.18)
                    )

                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")

                    .font(.system(size: 56))

                    .foregroundStyle(
                        FeatureColors.attendance.gradient
                    )

            }

            Text("Attendance Record")

                .font(

                    .system(

                        size: 34,

                        weight: .bold,

                        design: .rounded

                    )

                )

        }

    }

    private var infoCards: some View {

        VStack(spacing: 18) {

            DetailCard(

                title: "Athlete",

                value: attendance.athlete.fullName,

                symbol: "figure.gymnastics",

                color: FeatureColors.attendance

            )

            DetailCard(

                title: "Class",

                value: attendance.gymClass.name,

                symbol: "figure.flexibility",

                color: FeatureColors.attendance

            )

            DetailCard(

                title: "Date",

                value: attendance.attendedOn.formatted(

                    date: .complete,

                    time: .shortened

                ),

                symbol: "calendar",

                color: FeatureColors.attendance

            )

        }

    }

}

#Preview {

    NavigationStack {

        AttendanceDetailView(

            attendance: Attendance(

                id: UUID(),

                athlete: AttendanceAthlete(

                    id: UUID(),

                    fullName: "Arya Stark"

                ),

                gymClass: AttendanceClass(

                    id: UUID(),

                    name: "Sword Training"

                ),

                attendedOn: .now

            )

        )

    }

}
