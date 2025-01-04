import Foundation

class OpenAIService {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let session: URLSession
    
    init(apiKey: String) {
        self.apiKey = apiKey
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
    }
    
    func generateWorkoutPlan(
        goals: Set<WorkoutPreferences.FitnessGoal>,
        location: WorkoutPreferences.WorkoutLocation,
        duration: WorkoutPreferences.Duration,
        days: Set<WorkoutPreferences.Weekday>
    ) async throws -> WorkoutPlan {
        let prompt = """
        Generate a weekly workout plan with the following criteria:
        Goals: \(goals.map { $0.rawValue.capitalized }.joined(separator: ", "))
        Location: \(location.rawValue.capitalized)
        Duration per workout: \(duration.rawValue) minutes
        Training Days: \(days.map { $0.rawValue.capitalized }.joined(separator: ", "))
        
        Create a structured workout for each day, ensuring progression and rest between muscle groups.
        Format the response as JSON with the following structure:
        {
            "name": "string",
            "workouts": [
                {
                    "name": "string",
                    "day": "string (one of the specified days)",
                    "exercises": [
                        {
                            "name": "string",
                            "sets": number,
                            "reps": number,
                            "restTime": number,
                            "description": "string"
                        }
                    ]
                }
            ]
        }
        """
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": """
                You are a professional fitness trainer specializing in creating personalized workout plans.
                Consider exercise sequencing, muscle group targeting, and recovery time between workouts.
                Ensure exercises match the available equipment for the specified location.
            """],
            ["role": "user", "content": prompt]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "temperature": 0.2
        ]
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = response.choices.first?.message.content else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content in response"])
        }
        
        // Clean the content string by removing markdown code block formatting
        let cleanContent = content
            .replacingOccurrences(of: "```json\n", with: "")
            .replacingOccurrences(of: "\n```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanContent.data(using: .utf8),
              let planData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let planName = planData["name"] as? String,
              let workoutsData = planData["workouts"] as? [[String: Any]] else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse workout plan data"])
        }
        
        let workouts: [Workout] = workoutsData.map { workoutData in
            let exercisesData = workoutData["exercises"] as? [[String: Any]] ?? []
            let exercises = exercisesData.map { exerciseData in
                Workout.Exercise(
                    id: UUID().uuidString,
                    name: exerciseData["name"] as? String ?? "",
                    sets: exerciseData["sets"] as? Int ?? 0,
                    reps: exerciseData["reps"] as? Int ?? 0,
                    restTime: TimeInterval(exerciseData["restTime"] as? Int ?? 60),
                    description: exerciseData["description"] as? String ?? ""
                )
            }
            
            return Workout(
                id: UUID().uuidString,
                name: workoutData["name"] as? String ?? "",
                exercises: exercises,
                createdAt: Date()
            )
        }
        
        return WorkoutPlan(
            id: UUID().uuidString,
            name: planName,
            workouts: workouts,
            createdAt: Date(),
            goals: goals,
            location: location,
            duration: duration,
            selectedDays: days
        )
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
} 
