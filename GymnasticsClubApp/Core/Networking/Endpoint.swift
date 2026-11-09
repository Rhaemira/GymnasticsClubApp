//
//  Endpoint.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//

import Foundation

enum Endpoint {

    case athletes
    case coaches
    case classes
    case attendance
    case reports
    case analytics

    var path: String {
        switch self {
        case .athletes:    return "athletes"
        case .coaches:     return "coaches"
        case .classes:     return "classes"
        case .attendance:  return "attendance"
        case .reports:     return "reports"
        case .analytics:   return "analytics"
        }
    }

}
