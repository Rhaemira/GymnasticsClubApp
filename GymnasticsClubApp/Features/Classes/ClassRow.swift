//
//  ClassRow.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/14/26.
//


import SwiftUI

struct ClassRow: View {

    let gymClass: GymClass

    @State
    private var appeared = false

    var body: some View {

        HStack(spacing: 18) {

            ZStack {

                Circle()
                    .fill(
                        FeatureColors.classes.opacity(0.18)
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "figure.flexibility")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        FeatureColors.classes.gradient
                    )

            }

            VStack(alignment: .leading, spacing: 10) {

                Text(gymClass.name)
                    .font(
                        .system(
                            size: 21,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                HStack(spacing: 16) {

                    Label(
                        "\(gymClass.capacity) Athletes",
                        systemImage: "person.2.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Label(
                        "\(gymClass.capacity)",
                        systemImage: "person.2.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(FeatureColors.classes)

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

            RoundedRectangle(
                cornerRadius: 24
            )

            .stroke(
                FeatureColors.classes.opacity(0.15),
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

        .scaleEffect(
            appeared ? 1 : 0.94
        )

        .opacity(
            appeared ? 1 : 0
        )

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

    ClassRow(

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
