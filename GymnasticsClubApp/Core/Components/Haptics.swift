//
//  Haptics.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/19/26.
//


import UIKit

enum Haptics {

    static func success() {

        UINotificationFeedbackGenerator()

            .notificationOccurred(.success)

    }

    static func warning() {

        UINotificationFeedbackGenerator()

            .notificationOccurred(.warning)

    }

    static func impact() {

        UIImpactFeedbackGenerator(
            style: .soft
        ).impactOccurred()

    }

}