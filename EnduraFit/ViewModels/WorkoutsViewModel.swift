import Foundation

@MainActor
class WorkoutsViewModel: ObservableObject {
    @Published var savedWorkouts: [Workout] = []
    
    func addWorkout(_ workout: Workout) {
        savedWorkouts.append(workout)
    }
} 