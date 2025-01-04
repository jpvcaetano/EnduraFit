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
    
    private let openAIService: OpenAIService
    
    init(openAIService: OpenAIService) {
        self.openAIService = openAIService
    }
    
    func generateWorkoutPlan() async throws {
        isGeneratingPlan = true
        defer { isGeneratingPlan = false }
        
        guard let location = selectedLocation else { return }
        
        // Generate the complete plan
        generatedPlan = try await openAIService.generateWorkoutPlan(
            goals: selectedGoals,
            location: location,
            duration: desiredDuration,
            days: selectedDays
        )
        
        // Update generated workouts
        generatedWorkouts = generatedPlan?.workouts ?? []
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