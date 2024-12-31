import Foundation
import FirebaseFirestore

@MainActor
class WorkoutStore: ObservableObject {
    @Published var savedWorkouts: [Workout] = []
    @Published var savedPlans: [WorkoutPlan] = []
    private let db = Firestore.firestore()
    private let authService: AuthenticationService
    
    init(authService: AuthenticationService) {
        self.authService = authService
        Task {
            await loadWorkouts()
            await loadPlans()
        }
    }
    
    private func loadWorkouts() async {
        guard let userId = authService.currentUser?.id else { return }
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workouts")
                .getDocuments()
            
            self.savedWorkouts = snapshot.documents.compactMap { document in
                try? JSONDecoder().decode(Workout.self, from: JSONSerialization.data(withJSONObject: document.data()))
            }
        } catch {
            print("Error loading workouts: \(error.localizedDescription)")
        }
    }
    
    private func loadPlans() async {
        guard let userId = authService.currentUser?.id else { return }
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workoutPlans")
                .getDocuments()
            
            self.savedPlans = snapshot.documents.compactMap { document in
                try? JSONDecoder().decode(WorkoutPlan.self, from: JSONSerialization.data(withJSONObject: document.data()))
            }
        } catch {
            print("Error loading workout plans: \(error.localizedDescription)")
        }
    }
    
    func addWorkout(_ workout: Workout) {
        guard let userId = authService.currentUser?.id else { return }
        
        Task {
            do {
                let workoutData = try JSONEncoder().encode(workout).jsonObject()
                try await db.collection("users")
                    .document(userId)
                    .collection("workouts")
                    .document(workout.id)
                    .setData(workoutData)
                
                savedWorkouts.append(workout)
            } catch {
                print("Error saving workout: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteWorkout(at indexSet: IndexSet) {
        guard let userId = authService.currentUser?.id else { return }
        
        Task {
            for index in indexSet {
                let workout = savedWorkouts[index]
                do {
                    try await db.collection("users")
                        .document(userId)
                        .collection("workouts")
                        .document(workout.id)
                        .delete()
                    
                    savedWorkouts.remove(at: index)
                } catch {
                    print("Error deleting workout: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addWorkoutPlan(_ plan: WorkoutPlan) {
        guard let userId = authService.currentUser?.id else { return }
        
        Task {
            do {
                let planData = try JSONEncoder().encode(plan).jsonObject()
                try await db.collection("users")
                    .document(userId)
                    .collection("workoutPlans")
                    .document(plan.id)
                    .setData(planData)
                
                // Add all workouts from the plan
                for workout in plan.workouts {
                    try await addWorkout(workout)
                }
                
                savedPlans.append(plan)
            } catch {
                print("Error saving workout plan: \(error.localizedDescription)")
            }
        }
    }
    
    func deletePlan(_ plan: WorkoutPlan) {
        guard let userId = authService.currentUser?.id else { return }
        
        Task {
            do {
                // Delete the plan
                try await db.collection("users")
                    .document(userId)
                    .collection("workoutPlans")
                    .document(plan.id)
                    .delete()
                
                // Delete all workouts in the plan
                for workout in plan.workouts {
                    try await db.collection("users")
                        .document(userId)
                        .collection("workouts")
                        .document(workout.id)
                        .delete()
                }
                
                // Update local state
                savedPlans.removeAll { $0.id == plan.id }
                savedWorkouts.removeAll { workout in
                    plan.workouts.contains { $0.id == workout.id }
                }
            } catch {
                print("Error deleting workout plan: \(error.localizedDescription)")
            }
        }
    }
    
    func reloadPlans() {
        Task {
            await loadPlans()
        }
    }
} 