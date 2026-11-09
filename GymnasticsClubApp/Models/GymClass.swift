//
//  GymClass.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 6/15/26.
//


import Foundation

struct GymClass: Identifiable, Codable, Hashable {

    let id: UUID

    let name: String

    let capacity: Int

    let coach: CoachReference

}

struct CoachReference: Codable, Hashable {

    let id: UUID
    let fullName: String

}
