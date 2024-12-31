import Foundation

struct WorkoutPlan: Identifiable, Codable {
    let id: String
    let name: String
    let workouts: [Workout]
    let createdAt: Date
    let goals: Set<WorkoutPreferences.FitnessGoal>
    let location: WorkoutPreferences.WorkoutLocation
    let duration: WorkoutPreferences.Duration
} 