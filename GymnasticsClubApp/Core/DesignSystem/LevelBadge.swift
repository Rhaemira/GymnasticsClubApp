//
//  LevelBadge.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct LevelBadge: View {

    let level: String

    private var color: Color {

        switch level.lowercased() {

        case "beginner":

            return .green

        case "intermediate":

            return .orange

        case "advanced":

            return .red
            
        case "elite":
            
            return.purple

        default:

            return .gray

        }

    }

    var body: some View {

        Text(level)

            .font(.caption.bold())

            .padding(.horizontal,10)

            .padding(.vertical,6)

            .background(

                Capsule()

                    .fill(color.opacity(0.15))

            )

            .foregroundStyle(color)

    }

}
