import Foundation
import FirebaseFirestore

@MainActor
final class WorkoutStore: ObservableObject {
    @Published var savedPlans: [WorkoutPlan] = []
    @Published var selectedPlan: WorkoutPlan?
    
    private let db = Firestore.firestore()
    private let userId: String
    private let errorHandler: ErrorHandler
    
    init(userId: String, errorHandler: ErrorHandler) {
        self.userId = userId
        self.errorHandler = errorHandler
        Task {
            await reloadPlans()
        }
    }
    
    func reloadPlans() async {
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workoutPlans")
                .getDocuments()
            
            var plans: [WorkoutPlan] = []
            var hasErrors = false
            
            for document in snapshot.documents {
                if let plan = try? document.data(as: WorkoutPlan.self) {
                    plans.append(plan)
                } else {
                    hasErrors = true
                }
            }
            
            // Only show error if no plans were loaded at all
            if plans.isEmpty && hasErrors {
                await errorHandler.handle(WorkoutError.loadFailed)
            }
            
            savedPlans = plans
            
        } catch {
            // Only show error if we have no existing plans
            if savedPlans.isEmpty {
                await errorHandler.handle(WorkoutError.loadFailed)
            }
        }
    }
    
    func addWorkoutPlan(_ plan: WorkoutPlan) async throws {
        do {
            let docRef = db.collection("users")
                .document(userId)
                .collection("workoutPlans")
                .document(plan.id)
            
            try docRef.setData(from: plan)
            savedPlans.append(plan)
        } catch {
            await errorHandler.handle(WorkoutError.saveFailed)
            throw WorkoutError.saveFailed
        }
    }
    
    func deletePlan(_ plan: WorkoutPlan) {
        db.collection("users")
            .document(userId)
            .collection("workoutPlans")
            .document(plan.id)
            .delete()
        
        savedPlans.removeAll { $0.id == plan.id }
    }
} 