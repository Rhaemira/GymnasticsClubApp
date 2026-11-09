import Foundation

enum Endpoint {
    case athletes, coaches, classes, attendance, reports, analytics, enrollments, currentUser
    var path: String {
        switch self {
        case .athletes: return "athletes"
        case .coaches: return "coaches"
        case .classes: return "classes"
        case .attendance: return "attendance"
        case .reports: return "reports"
        case .analytics: return "analytics"
        case .enrollments: return "enrollments"
        case .currentUser: return "auth/me"
        }
    }
}
