//
//  Card.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct Card<Content: View>: View {

    @ViewBuilder
    let content: Content

    var body: some View {

        VStack(alignment: .leading) {

            content

        }
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
        .shadow(radius: AppShadow.card)

    }

}