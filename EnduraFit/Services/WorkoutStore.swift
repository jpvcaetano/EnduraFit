import Foundation
import FirebaseFirestore

@MainActor
final class WorkoutStore: ObservableObject {
    @Published var savedPlans: [WorkoutPlan] = []
    @Published var selectedPlan: WorkoutPlan?
    
    private let db = Firestore.firestore()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        Task {
            await reloadPlans()
        }
    }
    
    func reloadPlans() async {
        do {
            let snapshot = try await db.collection("users").document(userId).collection("workoutPlans").getDocuments()
            savedPlans = snapshot.documents.compactMap { document in
                try? document.data(as: WorkoutPlan.self)
            }
        } catch {
            print("Error loading workout plans: \(error)")
        }
    }
    
    func addWorkoutPlan(_ plan: WorkoutPlan) {
        do {
            try db.collection("users").document(userId).collection("workoutPlans").document(plan.id).setData(from: plan)
            savedPlans.append(plan)
        } catch {
            print("Error saving workout plan: \(error)")
        }
    }
    
    func deletePlan(_ plan: WorkoutPlan) {
        db.collection("users").document(userId).collection("workoutPlans").document(plan.id).delete()
        savedPlans.removeAll { $0.id == plan.id }
    }
} 