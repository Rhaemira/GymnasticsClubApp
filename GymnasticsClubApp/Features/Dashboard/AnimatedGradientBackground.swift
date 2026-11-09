//
//  AnimatedGradientBackground.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct AnimatedGradientBackground: View {

    @State
    private var move = false

    var body: some View {

        LinearGradient(

            colors: [

                Color.blue.opacity(0.20),

                Color.cyan.opacity(0.12),

                Color.purple.opacity(0.15),

                Color.indigo.opacity(0.20)

            ],

            startPoint: move ? .topLeading : .bottomTrailing,

            endPoint: move ? .bottomTrailing : .topLeading

        )

        .ignoresSafeArea()

        .hueRotation(

            .degrees(

                move ? 18 : -18

            )

        )

        .animation(

            .easeInOut(duration: 12)

                .repeatForever(

                    autoreverses: true

                ),

            value: move

        )

        .onAppear {

            move.toggle()

        }

    }

}
