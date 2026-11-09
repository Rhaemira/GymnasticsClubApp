//
//  ClassDetailView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/14/26.
//


import SwiftUI

struct ClassDetailView: View {

    let gymClass: GymClass

    var body: some View {

        ZStack {

            AppBackground(
                color: FeatureColors.classes
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

        .navigationTitle("Class")

        .navigationBarTitleDisplayMode(.inline)

    }

    private var header: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.classes.opacity(0.18)
                    )

                    .frame(width: 120, height: 120)

                Image(systemName: "figure.flexibility")

                    .font(.system(size: 54))

                    .foregroundStyle(
                        FeatureColors.classes.gradient
                    )

            }

            VStack(spacing: 6) {

                Text(gymClass.name)

                    .font(

                        .system(

                            size: 34,

                            weight: .bold,

                            design: .rounded

                        )

                    )

                    .multilineTextAlignment(.center)

                Text("Gymnastics Class")

                    .foregroundStyle(.secondary)

            }

        }

    }

    private var infoCards: some View {

        VStack(spacing: 18) {

            DetailCard(

                title: "Coach",

                value: gymClass.coach.fullName,

                symbol: "person.fill",

                color: FeatureColors.classes

            )

            DetailCard(

                title: "Capacity",

                value: "\(gymClass.capacity) Athletes",

                symbol: "person.2.fill",

                color: FeatureColors.classes

            )

        }

    }

}

#Preview {

    NavigationStack {

        ClassDetailView(

            gymClass: GymClass(

                id: UUID(),

                name: "Targaryen 101",

                capacity: 20,

                coach: CoachReference(

                    id: UUID(),

                    fullName: "Daenerys Targaryen"

                )

            )

        )

    }

}
