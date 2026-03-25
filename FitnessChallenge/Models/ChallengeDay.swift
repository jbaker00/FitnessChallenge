import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - Exercise

struct Exercise: Codable, Identifiable {
    var id: String { name }
    let name: String
    let sets: Int
    let reps: Int
    let durationSeconds: Int
    let notes: String

    /// Returns a human-readable summary of the exercise volume.
    var volumeSummary: String {
        if durationSeconds > 0 {
            let minutes = durationSeconds / 60
            let seconds = durationSeconds % 60
            if minutes > 0 {
                return "\(minutes)m \(seconds > 0 ? "\(seconds)s" : "")"
            } else {
                return "\(seconds)s"
            }
        } else {
            return "\(sets) × \(reps)"
        }
    }
}

// MARK: - ChallengeDay

struct ChallengeDay: Identifiable, Codable {
    @DocumentID var id: String?
    let dayNumber: Int
    let challengeType: String          // "7day" or "30day"
    let title: String
    let workoutTitle: String
    let workoutDescription: String
    let exercises: [Exercise]
    let nutritionTip: String
    let habitGoal: String
    let motivationalQuote: String
    let difficulty: String             // "Beginner", "Intermediate", "Advanced"
    let durationMinutes: Int
    let caloriesBurn: Int

    /// A compact summary line shown in list/card contexts.
    var exerciseSummary: String {
        let count = exercises.count
        let plural = count == 1 ? "exercise" : "exercises"
        return "\(count) \(plural) · \(durationMinutes) min"
    }

    /// Colour name used for the difficulty badge.
    var difficultyColor: String {
        switch difficulty.lowercased() {
        case "beginner":    return "limeGreen"
        case "intermediate": return "electricBlue"
        case "advanced":    return "red"
        default:            return "electricBlue"
        }
    }
}
