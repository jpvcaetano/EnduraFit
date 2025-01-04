import Foundation

struct Workout: Identifiable, Codable {
    let id: String
    let name: String
    let exercises: [Exercise]
    let createdAt: Date
    var completedAt: Date?
    let day: WorkoutPreferences.Weekday
    
    struct Exercise: Identifiable, Codable {
        let id: String
        let name: String
        let sets: Int
        let reps: Int
        let restTime: TimeInterval
        let description: String
    }
} 
