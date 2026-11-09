//
//  DetailCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct DetailCard: View {

    let title: String
    let value: String
    let symbol: String
    let color: Color

    var body: some View {

        HStack(spacing: 18) {

            Image(systemName: symbol)

                .font(.title2)

                .foregroundStyle(color)

                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {

                Text(title)

                    .font(.caption)

                    .foregroundStyle(.secondary)

                Text(value)

                    .font(.headline)

            }

            Spacer()

        }

        .padding(22)

        .background(.ultraThinMaterial)

        .overlay {

            RoundedRectangle(cornerRadius: 24)

                .stroke(

                    color.opacity(0.15),

                    lineWidth: 1

                )

        }

        .clipShape(

            RoundedRectangle(

                cornerRadius: 24,

                style: .continuous

            )

        )

    }

}

#Preview {

    DetailCard(

        title: "Specialty",

        value: "Floor Exercise",

        symbol: "star.fill",

        color: .green

    )

}