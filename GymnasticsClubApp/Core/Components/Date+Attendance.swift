//
//  Date+Attendance.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//

import Foundation

extension Date {

    var attendanceLabel: String {

        let calendar = Calendar.current

        if calendar.isDateInToday(self) {

            return "Today • \(formatted(date: .omitted, time: .shortened))"

        }

        if calendar.isDateInYesterday(self) {

            return "Yesterday"

        }

        if calendar.isDate(self, equalTo: .now, toGranularity: .weekOfYear) {

            return formatted(.dateTime.weekday(.wide))

        }

        return formatted(date: .abbreviated, time: .omitted)

    }

}
