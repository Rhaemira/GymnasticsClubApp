//
//  DashboardAppearModifier.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct DashboardAppearModifier: ViewModifier {

    let delay: Double

    @State
    private var visible = false

    func body(content: Content) -> some View {

        content

            .opacity(visible ? 1 : 0)

            .scaleEffect(visible ? 1 : 0.88)

            .offset(y: visible ? 0 : 30)

            .animation(

                .spring(
                    response: 0.7,
                    dampingFraction: 0.82
                )
                .delay(delay),

                value: visible

            )

            .onAppear {

                visible = true

            }

    }

}

extension View {

    func dashboardAppear(delay: Double) -> some View {

        modifier(
            DashboardAppearModifier(
                delay: delay
            )
        )

    }

}