//
//  AthleteRow.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import SwiftUI

struct AthleteRow: View {

    let athlete: Athlete

    var body: some View {

        HStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.athletes.opacity(0.15)
                    )

                    .frame(width: 64, height: 64)

                Image(systemName: "figure.gymnastics")

                    .font(.system(size: 28))

                    .foregroundStyle(
                        FeatureColors.athletes.gradient
                    )

            }

            VStack(alignment: .leading, spacing: 8) {

                Text(athlete.fullName)

                    .font(.title3.bold())

                HStack {

                    Label(

                        "\(athlete.age)",

                        systemImage: "calendar"

                    )

                    Spacer()

                    LevelBadge(level: athlete.level)

                }

                .font(.subheadline)

                .foregroundStyle(.secondary)

            }

            Spacer()

            Image(systemName: "chevron.right")

                .foregroundStyle(.tertiary)

        }

        .padding(22)

        .background(.ultraThinMaterial)

        .overlay(

            RoundedRectangle(cornerRadius: 24)

                .stroke(

                    FeatureColors.athletes.opacity(0.12),

                    lineWidth: 1

                )

        )

        .clipShape(

            RoundedRectangle(

                cornerRadius: 24,

                style: .continuous

            )

        )

        .shadow(

            color: FeatureColors.athletes.opacity(0.08),

            radius: 10,

            y: 6

        )

    }

}
