//
//  AppBackground.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct AppBackground: View {

    var color: Color = .blue

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    color.opacity(0.28),
                    color.opacity(0.12),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()

                .fill(color.opacity(0.15))

                .frame(width: 340)

                .blur(radius: 90)

                .offset(x: -170, y: -260)

            Circle()

                .fill(color.opacity(0.10))

                .frame(width: 280)

                .blur(radius: 80)

                .offset(x: 180, y: 350)

        }

        .ignoresSafeArea()

    }

}
