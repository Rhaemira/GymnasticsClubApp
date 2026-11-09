//
//  CustomTabBar.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct CustomTabBar: View {

    @Binding
    var selectedTab: AppTab

    @Namespace
    private var animation

    var body: some View {

        HStack(spacing: 0) {

            ForEach(AppTab.allCases, id: \.self) { tab in

                Button {

                    withAnimation(.spring(response: 0.45,
                                          dampingFraction: 0.8)) {

                        selectedTab = tab

                    }

                } label: {

                    VStack(spacing: 6) {

                        ZStack {

                            if selectedTab == tab {

                                Circle()

                                    .fill(tab.color.opacity(0.18))

                                    .frame(width: 52, height: 52)

                                    .matchedGeometryEffect(
                                        id: "bubble",
                                        in: animation
                                    )

                            }

                            Image(systemName: tab.icon)

                                .font(.title3)

                                .foregroundStyle(
                                    selectedTab == tab
                                    ? tab.color
                                    : .secondary
                                )

                                .scaleEffect(
                                    selectedTab == tab
                                    ? 1.18
                                    : 1
                                )

                        }

                        Text(tab.title)

                            .font(.caption2)

                            .foregroundStyle(
                                selectedTab == tab
                                ? tab.color
                                : .secondary
                            )

                    }

                    .frame(maxWidth: .infinity)

                }

                .buttonStyle(.plain)

            }

        }

        .padding(.horizontal, 18)

        .padding(.top, 10)

        .padding(.bottom, 28)

        .background(.ultraThinMaterial)

        .clipShape(

            RoundedRectangle(
                cornerRadius: 30,
                style: .continuous
            )

        )

        .padding(.horizontal)

        .padding(.bottom, 10)

        .shadow(
            color: .black.opacity(0.08),
            radius: 20,
            y: 10
        )

    }

}

#Preview {

    CustomTabBar(
        selectedTab: .constant(.dashboard)
    )

}
