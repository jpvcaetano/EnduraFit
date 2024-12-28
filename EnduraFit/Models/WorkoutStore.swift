import Foundation

@MainActor
class WorkoutStore: ObservableObject {
    @Published var savedWorkouts: [Workout] = []
    
    func addWorkout(_ workout: Workout) {
        savedWorkouts.append(workout)
    }
    
    func deleteWorkout(at indexSet: IndexSet) {
        savedWorkouts.remove(atOffsets: indexSet)
    }
} 