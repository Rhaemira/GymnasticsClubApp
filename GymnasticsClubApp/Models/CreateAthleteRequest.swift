//
//  CreateAthleteRequest.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import Foundation

struct CreateAthleteRequest: Codable {

    let fullName: String
    let age: Int
    let level: String

}