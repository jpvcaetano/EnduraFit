import Foundation

@MainActor
class WorkoutPlanViewModel: ObservableObject {
    @Published var currentStep = WorkoutPlanStep.goals
    @Published var selectedGoals: Set<WorkoutPreferences.FitnessGoal> = []
    @Published var selectedLocation: WorkoutPreferences.WorkoutLocation?
    @Published var selectedDays: Set<WorkoutPreferences.Weekday> = []
    @Published var desiredDuration: WorkoutPreferences.Duration = .thirty
    @Published var isGeneratingPlan = false
    @Published var generatedWorkout: Workout?
    
    enum WorkoutPlanStep {
        case goals
        case location
        case duration
        case availability
        case review
    }
    
    func generateWorkoutPlan() async throws {
        isGeneratingPlan = true
        defer { isGeneratingPlan = false }
        
        // TODO: Implement OpenAI API call
        // For now, return mock data
        generatedWorkout = Workout(
            id: UUID(),
            name: "Full Body Workout",
            exercises: [
                .init(
                    id: UUID(),
                    name: "Push-ups",
                    sets: 3,
                    reps: 12,
                    restTime: 60,
                    description: "Start in a plank position and lower your body until your chest nearly touches the ground."
                ),
                .init(
                    id: UUID(),
                    name: "Pull-ups",
                    sets: 3,
                    reps: 12,
                    restTime: 60,
                    description: "Start in a plank position and lower your body until your chest nearly touches the ground."
                )
            ],
            createdAt: Date()
        )
    }
    
    func reset() {
        currentStep = .goals
        selectedGoals.removeAll()
        selectedLocation = nil
        selectedDays.removeAll()
        desiredDuration = .thirty
        generatedWorkout = nil
        isGeneratingPlan = false
    }
} 