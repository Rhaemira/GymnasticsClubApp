//
//  ActivityRow.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct ActivityRow: View {

    let icon: String
    let title: String
    let subtitle: String

    var body: some View {

        HStack(spacing: 18) {

            Image(systemName: icon)

                .font(.title3)

                .frame(width: 44, height: 44)

                .background(.blue.opacity(0.12))

                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }

            Spacer()

        }
        .padding(.vertical, 8)

    }

}
