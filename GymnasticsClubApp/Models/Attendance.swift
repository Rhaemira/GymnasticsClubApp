//
//  Attendance.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//

import Foundation

struct Attendance: Identifiable, Codable {

    let id: UUID

    let athlete: AttendanceAthlete

    let gymClass: AttendanceClass

    let attendedOn: Date

}

struct AttendanceAthlete: Codable {

    let id: UUID

    let fullName: String

}

struct AttendanceClass: Codable {

    let id: UUID

    let name: String

}
