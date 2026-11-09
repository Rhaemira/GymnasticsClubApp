//
//  Athlete.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 6/15/26.
//


import Foundation

struct Athlete: Identifiable, Codable, Hashable {

    let id: UUID

    let fullName: String

    let age: Int

    let level: String
}
