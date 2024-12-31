import Foundation

@MainActor
class WorkoutPlanViewModel: ObservableObject {
    @Published var currentStep = WorkoutPlanStep.goals
    @Published var selectedGoals: Set<WorkoutPreferences.FitnessGoal> = []
    @Published var selectedLocation: WorkoutPreferences.WorkoutLocation?
    @Published var selectedDays: Set<WorkoutPreferences.Weekday> = []
    @Published var desiredDuration: WorkoutPreferences.Duration = .thirty
    @Published var isGeneratingPlan = false
    @Published var generatedWorkouts: [Workout] = []
    @Published var generatedPlan: WorkoutPlan?
    
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
        
        // Clear previous workouts
        generatedWorkouts.removeAll()
        
        // Generate a workout for each selected day
        for day in selectedDays.sorted(by: { $0.rawValue < $1.rawValue }) {
            // TODO: Implement OpenAI API call with day-specific variations
            // For now, return mock data with day in the name
            let workout = Workout(
                id: UUID().uuidString,
                name: "\(day.rawValue.capitalized) Workout",
                exercises: [
                    .init(
                        id: UUID().uuidString,
                        name: "Push-ups",
                        sets: 3,
                        reps: 12,
                        restTime: 60,
                        description: "Start in a plank position and lower your body until your chest nearly touches the ground."
                    ),
                    .init(
                        id: UUID().uuidString,
                        name: "Pull-ups",
                        sets: 3,
                        reps: 12,
                        restTime: 60,
                        description: "Start in a plank position and lower your body until your chest nearly touches the ground."
                    )
                ],
                createdAt: Date()
            )
            generatedWorkouts.append(workout)
        }
        
        // Create the workout plan
        generatedPlan = WorkoutPlan(
            id: UUID().uuidString,
            name: "Weekly Workout Plan",
            workouts: generatedWorkouts,
            createdAt: Date(),
            goals: selectedGoals,
            location: selectedLocation ?? .home,
            duration: desiredDuration
        )
    }
    
    func reset() {
        currentStep = .goals
        selectedGoals.removeAll()
        selectedLocation = nil
        selectedDays.removeAll()
        desiredDuration = .thirty
        generatedWorkouts.removeAll()
        isGeneratingPlan = false
        generatedPlan = nil
    }
} 