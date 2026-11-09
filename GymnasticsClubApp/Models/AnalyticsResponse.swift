//
//  AnalyticsResponse.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import Foundation

struct AnalyticsResponse: Codable {

    let overview: Overview

    let athleteLevels: [AthleteLevel]

    let coachWorkload: [CoachWorkload]

    let classUtilization: [ClassUtilization]

}

struct Overview: Codable {

    let athletes: Int
    let coaches: Int
    let classes: Int
    let enrollments: Int
    let attendance: Int

}

struct AthleteLevel: Codable, Identifiable {

    var id: String { level }

    let level: String
    let count: Int

}

struct CoachWorkload: Codable, Identifiable {

    var id: String { coach }

    let coach: String
    let classes: Int

}

struct ClassUtilization: Codable, Identifiable {

    var id: String { className }

    let className: String
    let enrolled: Int
    let capacity: Int

}