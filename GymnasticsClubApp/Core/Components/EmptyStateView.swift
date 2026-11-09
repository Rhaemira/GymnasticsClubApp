//
//  EmptyStateView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct EmptyStateView: View {

    let title: String

    let systemImage: String

    let description: String

    let buttonTitle: String?

    let action: (() -> Void)?

    init(
        title: String,
        systemImage: String,
        description: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {

        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.buttonTitle = buttonTitle
        self.action = action

    }

    var body: some View {

        ContentUnavailableView {

            Label(title, systemImage: systemImage)

        } description: {

            Text(description)

        } actions: {

            if let buttonTitle,
               let action {

                Button(buttonTitle) {

                    action()

                }

            }

        }

    }

}
