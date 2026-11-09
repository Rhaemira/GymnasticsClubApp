//
//  CoachDetailView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct CoachDetailView: View {

    let coach: Coach

    var body: some View {

        ZStack {

            AppBackground(
                color: FeatureColors.coaches
            )

            ScrollView {

                VStack(spacing: 30) {

                    VStack(spacing: 18) {

                        ZStack {

                            Circle()

                                .fill(
                                    FeatureColors.coaches.opacity(0.18)
                                )

                                .frame(width: 120, height: 120)

                            Image(systemName: "person.3.fill")

                                .font(.system(size: 54))

                                .foregroundStyle(
                                    FeatureColors.coaches.gradient
                                )

                        }

                        VStack(spacing: 6) {

                            Text(coach.fullName)

                                .font(
                                    .system(
                                        size: 34,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )

                                .multilineTextAlignment(.center)

                            Text("Gymnastics Coach")

                                .foregroundStyle(.secondary)

                        }

                    }

                    VStack(spacing: 18) {

                        DetailCard(

                            title: "Specialty",

                            value: coach.specialty,

                            symbol: "star.fill",

                            color: FeatureColors.coaches

                        )

                    }

                    Spacer(minLength: 40)

                }

                .padding()

            }

        }

        .navigationTitle("Coach")

        .navigationBarTitleDisplayMode(.inline)

    }

}

#Preview {

    NavigationStack {

        CoachDetailView(

            coach: Coach(

                id: UUID(),

                fullName: "Daenerys Targaryen",

                specialty: "Floor Exercise"

            )

        )

    }

}
