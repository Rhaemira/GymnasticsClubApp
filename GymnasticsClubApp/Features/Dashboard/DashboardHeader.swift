//
//  DashboardHeader.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct DashboardHeader: View {

    private var greeting: String {

        let hour = Calendar.current.component(
            .hour,
            from: Date()
        )

        switch hour {

        case 5..<12:
            return "Good Morning"

        case 12..<17:
            return "Good Afternoon"

        default:
            return "Good Evening"

        }

    }

    private var dateString: String {

        Date.now.formatted(

            .dateTime

                .weekday(.wide)

                .month(.wide)

                .day()

        )

    }

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(greeting)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {

                Image(systemName: "figure.gymnastics")

                    .font(.largeTitle)

                    .foregroundStyle(
                        FeatureColors.dashboard.gradient
                    )

                VStack(alignment: .leading) {

                    Text("Gymnastics Club")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold,
                                design: .rounded
                            )
                        )

                    Text(dateString)
                        .foregroundStyle(.secondary)

                }

            }
                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .rounded
                    )
                )

            Text(dateString)
                .foregroundStyle(.secondary)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)

    }

}

#Preview {

    DashboardHeader()

}
