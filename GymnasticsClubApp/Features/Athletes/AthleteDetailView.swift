//
//  AthleteDetailView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct AthleteDetailView: View {

    let athlete: Athlete

    var body: some View {

        ScrollView {

            VStack(spacing: 28) {

                heroSection

                infoCard

            }

            .padding()

        }

        .background(

            AppBackground(
                color: FeatureColors.athletes
            )

        )
        .navigationBarTitleDisplayMode(.inline)

    }

    private var heroSection: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.athletes.opacity(0.15)
                    )

                    .frame(width: 120, height: 120)

                Image(systemName: "figure.gymnastics")

                    .font(.system(size: 60))

                    .foregroundStyle(
                        FeatureColors.athletes.gradient
                    )

            }

            Text(athlete.fullName)

                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .rounded
                    )
                )

            LevelBadge(level: athlete.level)

        }

        .frame(maxWidth: .infinity)

        .padding(.vertical,30)

        .background(

            LinearGradient(

                colors: [

                    FeatureColors.athletes.opacity(0.20),

                    .clear

                ],

                startPoint: .top,

                endPoint: .bottom

            )

        )

        .clipShape(

            RoundedRectangle(cornerRadius: 30)

        )

    }

    private var infoCard: some View {

        VStack(spacing: 20) {

            DetailRow(

                title: "Age",

                value: "\(athlete.age)",

                icon: "calendar",

                color: .blue

            )

            Divider()

            DetailRow(

                title: "Level",

                value: athlete.level,

                icon: "star.fill",

                color: .orange

            )

        }

        .padding(24)

        .background(.ultraThinMaterial)

        .clipShape(

            RoundedRectangle(cornerRadius: 24)

        )

        .overlay(

            RoundedRectangle(cornerRadius: 24)

                .stroke(
                    FeatureColors.athletes.opacity(0.15)
                )

        )

    }

}

#Preview {

    NavigationStack {

        AthleteDetailView(

            athlete: Athlete(

                id: UUID(),

                fullName: "Daenerys Targaryen",

                age: 21,

                level: "Advanced"

            )

        )

    }

}
