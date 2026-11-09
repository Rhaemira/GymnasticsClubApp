//
//  AppTheme.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

enum AppTheme {

    enum Colors {

        static let accent = Color.blue

        static let destructive = Color.red

        static let cardBackground = Color(.secondarySystemBackground)

    }

    enum Typography {

        static let hero = Font.system(
            size: 38,
            weight: .bold,
            design: .rounded
        )

        static let largeTitle = Font.largeTitle.bold()

        static let title = Font.title.bold()

        static let headline = Font.headline

        static let body = Font.body

        static let caption = Font.caption

    }

    enum Spacing {

        static let xSmall: CGFloat = 4

        static let small: CGFloat = 8

        static let medium: CGFloat = 16

        static let large: CGFloat = 24

        static let xLarge: CGFloat = 32

        static let xxLarge: CGFloat = 48

    }

    enum Radius {

        static let small: CGFloat = 12

        static let medium: CGFloat = 20

        static let large: CGFloat = 28

        static let pill: CGFloat = 999

    }

    enum Shadow {

        static let card: CGFloat = 10

        static let floatingButton: CGFloat = 16

    }

}