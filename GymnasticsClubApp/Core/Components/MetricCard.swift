//
//  MetricCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import SwiftUI

struct MetricCard: View {

    let title: String
    let value: String
    let icon: String

    var body: some View {

        VStack(alignment: .leading) {

            Image(systemName: icon)
                .font(.title2)

            Spacer()

            Text(value)
                .font(AppTypography.hero)

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(.secondary)

        }
        .padding(AppSpacing.large)

        .frame(maxWidth: .infinity)

        .frame(height: 170)

        .background(.regularMaterial)

        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
    }

}
