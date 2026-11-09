//
//  AddButton.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct AddButton: View {

    let color: Color

    let action: () -> Void

    @State
    private var pressed = false

    @State
    private var glow = false

    var body: some View {

        Button {

            withAnimation(.spring(response: 0.25)) {

                pressed = true

            }

            DispatchQueue.main.asyncAfter(deadline: .now()+0.15) {

                pressed = false

            }

            action()

        } label: {

            Image(systemName: "plus")

                .font(.title.bold())

                .foregroundStyle(.white)

                .rotationEffect(

                    .degrees(

                        pressed ? 90 : 0

                    )

                )

                .frame(width: 64, height: 64)

                .background(

                    Circle()

                        .fill(color.gradient)

                )

                .overlay(

                    Circle()

                        .stroke(.white.opacity(0.3))

                )

                .shadow(

                    color: color.opacity(0.45),

                    radius: glow ? 22 : 12

                )

                .scaleEffect(

                    pressed ? 0.9 : 1

                )

        }

        .buttonStyle(.plain)

        .animation(.spring(), value: pressed)

        .onAppear {

            withAnimation(

                .easeInOut(duration: 2)

                    .repeatForever(autoreverses: true)

            ) {

                glow = true

            }

        }

    }

}
