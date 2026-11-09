//
//  AppTab.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

enum AppTab: String, CaseIterable {

    case dashboard
    case athletes
    case coaches
    case classes
    case attendance

    var title: String {

        switch self {

        case .dashboard:
            return "Home"

        case .athletes:
            return "Athletes"

        case .coaches:
            return "Coaches"

        case .classes:
            return "Classes"

        case .attendance:
            return "Attendance"

        }

    }

    var icon: String {

        switch self {

        case .dashboard:
            return "house.fill"

        case .athletes:
            return "figure.gymnastics"

        case .coaches:
            return "person.3.fill"

        case .classes:
            return "calendar"

        case .attendance:
            return "checklist"

        }

    }

    var color: Color {

        switch self {

        case .dashboard:
            return FeatureColors.dashboard

        case .athletes:
            return FeatureColors.athletes

        case .coaches:
            return FeatureColors.coaches

        case .classes:
            return FeatureColors.classes

        case .attendance:
            return FeatureColors.attendance

        }

    }

}