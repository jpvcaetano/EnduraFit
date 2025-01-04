import Foundation

struct WorkoutPlan: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let workouts: [Workout]
    let createdAt: Date
    let goals: Set<WorkoutPreferences.FitnessGoal>
    let location: WorkoutPreferences.WorkoutLocation
    let duration: WorkoutPreferences.Duration
    let selectedDays: Set<WorkoutPreferences.Weekday>
    
    // Implement hash(into:) to satisfy Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement == to satisfy Hashable
    static func == (lhs: WorkoutPlan, rhs: WorkoutPlan) -> Bool {
        lhs.id == rhs.id
    }
} 