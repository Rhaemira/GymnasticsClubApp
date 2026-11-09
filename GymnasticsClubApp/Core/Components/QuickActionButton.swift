//
//  QuickActionButton.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct QuickActionButton: View {

    let title: String
    let icon: String

    let action: () -> Void

    var body: some View {

        Button(action: action) {

            VStack(spacing: 12) {

                Image(systemName: icon)
                    .font(.title2)

                Text(title)

            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )

        }

        .buttonStyle(.plain)

    }

}