//
//  DashboardDonutChart.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI
import Charts

struct DashboardDonutChart: View {

    let stats: DashboardStats

    struct Slice: Identifiable {

        let id = UUID()

        let title: String

        let value: Double

    }

    private var slices: [Slice] {

        [

            Slice(
                title: "Attendance",
                value: Double(stats.totalAttendanceRecords)
            ),

            Slice(
                title: "Enrollments",
                value: Double(stats.totalEnrollments)
            )

        ]

    }

    var body: some View {

        VStack(alignment: .leading) {

            Text("Attendance Distribution")
                .font(.title2.bold())

            Chart(slices) { slice in

                SectorMark(

                    angle: .value(
                        slice.title,
                        slice.value
                    ),

                    innerRadius: .ratio(0.60),

                    angularInset: 2

                )

                .cornerRadius(6)

            }

            .frame(height: 280)

        }

        .padding()

        .background(.regularMaterial)

        .clipShape(

            RoundedRectangle(

                cornerRadius: 24,

                style: .continuous

            )

        )

        .padding(.horizontal)

    }

}

#Preview {

    DashboardDonutChart(

        stats: DashboardStats(

            totalAthletes: 20,

            totalCoaches: 4,

            totalClasses: 7,

            totalEnrollments: 30,

            totalAttendanceRecords: 18

        )

    )

}