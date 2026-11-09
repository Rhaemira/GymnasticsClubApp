//
//  DashboardContent.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//

import SwiftUI

struct DashboardContent: View {

    let stats: DashboardStats
    let attendance: [Attendance]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {

        ScrollView {

            LazyVGrid(columns: columns, spacing: 20) {

                DashboardMetricCard(
                    title: "Athletes",
                    value: stats.totalAthletes,
                    symbol: "figure.gymnastics",
                    color: FeatureColors.athletes,
                    delay: 0.0
                )

                DashboardMetricCard(
                    title: "Coaches",
                    value: stats.totalCoaches,
                    symbol: "person.2.fill",
                    color: FeatureColors.coaches,
                    delay: 0.10
                )

                DashboardMetricCard(
                    title: "Classes",
                    value: stats.totalClasses,
                    symbol: "calendar",
                    color: FeatureColors.classes,
                    delay: 0.20
                )

                DashboardMetricCard(
                    title: "Attendance",
                    value: stats.totalAttendanceRecords,
                    symbol: "checkmark.circle.fill",
                    color: FeatureColors.attendance,
                    delay: 0.30
                )

            }
            .padding()

            Spacer().frame(height: 10)

            DashboardBarChart(stats: stats)
                .dashboardAppear(delay: 0.35)

            Spacer().frame(height: 20)

            RecentActivityCard(attendance: attendance)
                .dashboardAppear(delay: 0.45)

            Spacer().frame(height: 20)

            AttendanceByClassChart(attendance: attendance)
                .dashboardAppear(delay: 0.55)

            Spacer().frame(height: 30)

        }
        .refreshable {}

    }

}

#Preview {
    DashboardContent(
        stats: DashboardStats(
            totalAthletes: 27,
            totalCoaches: 8,
            totalClasses: 12,
            totalEnrollments: 34,
            totalAttendanceRecords: 91
        ),
        attendance: []
    )
}
