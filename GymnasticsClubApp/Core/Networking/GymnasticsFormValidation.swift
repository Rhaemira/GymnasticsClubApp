import Foundation

/// Client-side form rules intentionally mirror the backend's RequestValidation.
/// The API remains authoritative; these checks provide immediate, consistent feedback.
enum GymnasticsFormValidation {
    static func athlete(fullName: String, age: Int) -> String? {
        if let message = name(fullName, field: "Athlete name") {
            return message
        }
        guard (1...120).contains(age) else {
            return "Athlete age must be between 1 and 120."
        }
        return nil
    }

    static func coach(fullName: String, specialty: String) -> String? {
        if let message = name(fullName, field: "Coach name") {
            return message
        }
        return name(specialty, field: "Coach specialty")
    }

    static func gymClass(name: String, capacity: Int, hasCoach: Bool) -> String? {
        if let message = self.name(name, field: "Class name") {
            return message
        }
        guard (1...500).contains(capacity) else {
            return "Class capacity must be between 1 and 500."
        }
        guard hasCoach else {
            return "Choose a coach for this class."
        }
        return nil
    }

    static func attendance(
        hasAthlete: Bool,
        hasClass: Bool,
        attendedOn: Date,
        now: Date = .now
    ) -> String? {
        guard hasAthlete, hasClass else {
            return "Choose both an athlete and a class."
        }
        guard attendedOn <= now.addingTimeInterval(300) else {
            return "Attendance date cannot be more than five minutes in the future."
        }
        return nil
    }

    private static func name(_ value: String, field: String) -> String? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (2...100).contains(cleaned.count) else {
            return "(field) must contain between 2 and 100 non-whitespace characters."
        }
        return nil
    }
}
