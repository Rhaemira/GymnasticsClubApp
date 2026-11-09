//
//  CoachRow.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct CoachRow: View {

    let coach: Coach

    @State
    private var appeared = false

    var body: some View {

        HStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.coaches.opacity(0.18)
                    )

                    .frame(width: 64, height: 64)

                Image(systemName: "person.3.fill")

                    .font(.system(size: 28))

                    .foregroundStyle(
                        FeatureColors.coaches.gradient
                    )

            }

            VStack(alignment: .leading, spacing: 8) {

                Text(coach.fullName)

                    .font(
                        .system(
                            size: 21,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                HStack(spacing: 8) {

                    Image(systemName: "star.fill")

                        .font(.caption)

                        .foregroundStyle(.yellow)

                    Text(coach.specialty)

                        .font(.subheadline)

                        .foregroundStyle(.secondary)

                }

            }

            Spacer()

            Image(systemName: "chevron.right")

                .font(.headline)

                .foregroundStyle(.tertiary)

        }

        .padding(22)

        .background(.ultraThinMaterial)

        .overlay {

            RoundedRectangle(cornerRadius: 24)

                .stroke(

                    FeatureColors.coaches.opacity(0.15),

                    lineWidth: 1

                )

        }

        .clipShape(

            RoundedRectangle(

                cornerRadius: 24,

                style: .continuous

            )

        )

        .shadow(

            color: .black.opacity(0.06),

            radius: 12,

            y: 6

        )

        .scaleEffect(appeared ? 1 : 0.94)

        .opacity(appeared ? 1 : 0)

        .animation(

            .spring(

                response: 0.55,

                dampingFraction: 0.82

            ),

            value: appeared

        )

        .onAppear {

            appeared = true

        }

    }

}

#Preview {

    CoachRow(

        coach: Coach(

            id: UUID(),

            fullName: "Daenerys Targaryen",

            specialty: "Floor Exercise"

        )

    )

}
