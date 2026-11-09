//
//  CreateAttendanceRequest.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import Foundation

struct CreateAttendanceRequest: Codable {

    let athleteID: UUID

    let classID: UUID

    let attendedOn: Date

}