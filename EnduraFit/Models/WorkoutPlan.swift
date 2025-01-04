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

// Helper for weekday ordering
extension Set where Element == WorkoutPreferences.Weekday {
    var orderedWeekdays: [WorkoutPreferences.Weekday] {
        let weekdayOrder: [WorkoutPreferences.Weekday] = [
            .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
        ]
        
        return Array(self).sorted { day1, day2 in
            guard let index1 = weekdayOrder.firstIndex(of: day1),
                  let index2 = weekdayOrder.firstIndex(of: day2) else {
                return false
            }
            return index1 < index2
        }
    }
} 