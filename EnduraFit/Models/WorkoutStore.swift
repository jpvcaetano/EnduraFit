import Foundation
import FirebaseFirestore

@MainActor
class WorkoutStore: ObservableObject {
    @Published var savedWorkouts: [Workout] = []
    private let db = Firestore.firestore()
    private let authService: AuthenticationService
    
    init(authService: AuthenticationService) {
        self.authService = authService
        Task {
            await loadWorkouts()
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
} 