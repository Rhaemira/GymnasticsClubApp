//
//  DashboardBarChart.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI
import Charts

struct DashboardBarChart: View {

    let stats: DashboardStats

    @State
    private var animate = false

    struct Item: Identifiable {

        let id = UUID()

        let title: String
        let value: Double
        let color: Color

    }

    private var data: [Item] {

        [

            Item(
                title: "Athletes",
                value: Double(stats.totalAthletes),
                color: .blue
            ),

            Item(
                title: "Coaches",
                value: Double(stats.totalCoaches),
                color: .green
            ),

            Item(
                title: "Classes",
                value: Double(stats.totalClasses),
                color: .orange
            ),

            Item(
                title: "Attendance",
                value: Double(stats.totalAttendanceRecords),
                color: .purple
            )

        ]

    }

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack {

                Text("Club Overview")
                    .font(.title2.bold())

                Spacer()

                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.secondary)

            }

            Chart(data) { item in

                BarMark(

                    x: .value(
                        "Category",
                        item.title
                    ),

                    y: .value(
                        "Count",
                        animate ? item.value : 0
                    )

                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            item.color,
                            item.color.opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)

                PointMark(

                    x: .value(
                        "Category",
                        item.title
                    ),

                    y: .value(
                        "Count",
                        animate ? item.value : 0
                    )

                )
                .symbolSize(60)
                .foregroundStyle(item.color)

            }

            .frame(height: 260)

            .chartYAxis {

                AxisMarks(position: .leading)

            }

            .chartXAxis {

                AxisMarks { value in

                    AxisGridLine()

                    AxisTick()

                    AxisValueLabel()

                }

            }

            .animation(
                .spring(
                    response: 0.7,
                    dampingFraction: 0.75
                ),
                value: animate
            )

        }
        .padding()

        .background(.regularMaterial)

        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )

        .shadow(
            color: .black.opacity(0.08),
            radius: 10,
            y: 6
        )

        .padding(.horizontal)

        .onAppear {

            animate = true

        }
        .onChange(of: stats.totalAthletes) { animateChart() }
        .onChange(of: stats.totalCoaches) { animateChart() }
        .onChange(of: stats.totalClasses) { animateChart() }
        .onChange(of: stats.totalAttendanceRecords) { animateChart() }

    }

    private func animateChart() {

        animate = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {

            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {

                animate = true

            }

        }

    }

}

#Preview {

    DashboardBarChart(

        stats: DashboardStats(

            totalAthletes: 18,
            totalCoaches: 5,
            totalClasses: 9,
            totalEnrollments: 32,
            totalAttendanceRecords: 14

        )

    )

}
