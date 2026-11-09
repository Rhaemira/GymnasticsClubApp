//
//  StatisticCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct StatisticCard: View {

    let title: String

    let value: Int

    let systemImage: String

    var body: some View {

        HStack(spacing: 16) {

            Image(systemName: systemImage)
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.accentColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.headline)

                Text("\(value)")
                    .font(.title)
                    .fontWeight(.bold)

            }

            Spacer()

        }
        .padding()

        .background(.regularMaterial)

        .clipShape(RoundedRectangle(cornerRadius: 20))

    }

}