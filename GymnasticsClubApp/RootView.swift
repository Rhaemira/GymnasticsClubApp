//
//  RootView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import SwiftUI

struct RootView: View {

    var body: some View {

        TabView {

            DashboardView()
                .tabItem {

                    Label(
                        "Home",
                        systemImage: "house.fill"
                    )

                }

            AthletesView()
                .tabItem {

                    Label(
                        "Athletes",
                        systemImage: "figure.gymnastics"
                    )

                }

            CoachesView()
                .tabItem {

                    Label(
                        "Coaches",
                        systemImage: "person.3.fill"
                    )

                }

            ClassesView()
                .tabItem {

                    Label(
                        "Classes",
                        systemImage: "calendar"
                    )

                }

            AttendanceView()
                .tabItem {

                    Label(
                        "Attendance",
                        systemImage: "checklist"

                    )

                }

        }

    }

}

#Preview {

    RootView()

}
