//
//  CoachDTO.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 6/15/26.
//


import Foundation

struct Coach: Identifiable, Codable, Hashable {

    let id: UUID

    let fullName: String

    let specialty: String

}
