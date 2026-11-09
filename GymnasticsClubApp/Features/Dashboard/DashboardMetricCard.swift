//
//  DashboardMetricCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//

import SwiftUI

struct DashboardMetricCard: View {

    let title: String
    let value: Int
    let symbol: String
    let color: Color
    let delay: Double

    @State
    private var displayedValue = 0

    @State
    private var appeared = false
    
    @State
    private var pressed = false

    var body: some View {

        VStack(alignment: .leading, spacing: 18) {

            Image(systemName: symbol)
                .font(.system(size: 30))
                .foregroundStyle(color.gradient)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce.byLayer, value: displayedValue)
                .font(.system(size: 30))
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(
                    .bounce.byLayer,
                    value: displayedValue
                )
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)

            Spacer()

            Text("\(displayedValue)")
                .font(
                    .system(
                        size: 38,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .contentTransition(.numericText())

            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
        .scaleEffect(

            pressed

            ? 0.97

            : 1

        )
        .onLongPressGesture(

            minimumDuration: 0,

            pressing: {

                pressed = $0

            }

        ) {

        }
        .padding(24)
        .background(

            LinearGradient(

                colors: [

                    color.opacity(0.18),

                    color.opacity(0.05)

                ],

                startPoint: .topLeading,

                endPoint: .bottomTrailing

            )

        )        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .shadow(
            color: color.opacity(0.25),
            radius: 14,
            y: 8
        )
        .scaleEffect(appeared ? 1 : 0.90)
        .opacity(appeared ? 1 : 0)
        .animation(
            .spring(
                response: 0.6,
                dampingFraction: 0.8
            ),
            value: appeared
        )
        .onAppear {

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                appeared = true

                animateValue()

            }

        }
        .onChange(of: value) {

            animateValue()

        }

    }

    private func animateValue() {

        displayedValue = 0

        let target = value

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in

            if displayedValue >= target {

                timer.invalidate()

            } else {

                displayedValue += max(1, target / 25)

                if displayedValue > target {

                    displayedValue = target

                }

            }

        }

    }

}

#Preview {

    DashboardMetricCard(
        title: "Athletes",
        value: 128,
        symbol: "figure.gymnastics",
        color: .blue,
        delay: 0
    )

}
