//
//  FeatureHeader.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct FeatureHeader: View {

    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {

        HStack(alignment: .center, spacing: 18) {

            ZStack {

                Circle()

                    .fill(color.opacity(0.18))

                    .frame(width: 72, height: 72)

                Image(systemName: icon)

                    .font(.system(size: 34))

                    .foregroundStyle(color.gradient)

            }

            VStack(alignment: .leading, spacing: 6) {

                Text(title)
                    .font(
                        .system(
                            size: 36,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                Text(subtitle)
                    .foregroundStyle(.secondary)

            }

            Spacer()

        }
        .padding(.horizontal)

    }

}