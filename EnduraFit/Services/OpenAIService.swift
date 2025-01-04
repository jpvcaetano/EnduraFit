import Foundation

@MainActor
class OpenAIService {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let session: URLSession
    private let errorHandler: ErrorHandler
    
    init(apiKey: String, errorHandler: ErrorHandler) {
        self.apiKey = apiKey
        self.errorHandler = errorHandler
        
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
        
        do {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await session.data(for: request)
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let content = openAIResponse.choices.first?.message.content else {
                throw WorkoutError.generationFailed("No content in response")
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
                throw WorkoutError.generationFailed("Failed to parse workout plan data")
            }
            
            let workouts: [Workout] = try workoutsData.map { workoutData in
                guard let exercisesData = workoutData["exercises"] as? [[String: Any]] else {
                    throw WorkoutError.generationFailed("Invalid exercises data")
                }
                
                let exercises = try exercisesData.map { exerciseData in
                    guard let name = exerciseData["name"] as? String,
                          let sets = exerciseData["sets"] as? Int,
                          let reps = exerciseData["reps"] as? Int,
                          let restTime = exerciseData["restTime"] as? Int,
                          let description = exerciseData["description"] as? String else {
                        throw WorkoutError.generationFailed("Invalid exercise data")
                    }
                    
                    return Workout.Exercise(
                        id: UUID().uuidString,
                        name: name,
                        sets: sets,
                        reps: reps,
                        restTime: TimeInterval(restTime),
                        description: description
                    )
                }
                
                // Parse the day string to Weekday enum
                guard let dayString = workoutData["day"] as? String,
                      let day = WorkoutPreferences.Weekday(rawValue: dayString.lowercased()) else {
                    throw WorkoutError.generationFailed("Invalid workout day")
                }
                
                return Workout(
                    id: UUID().uuidString,
                    name: workoutData["name"] as? String ?? "",
                    exercises: exercises,
                    createdAt: Date(),
                    day: day
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
            
        } catch let error as NetworkError {
            await errorHandler.handle(error)
            throw error
        } catch let error as WorkoutError {
            await errorHandler.handle(error)
            throw error
        } catch {
            let wrappedError = WorkoutError.generationFailed(error.localizedDescription)
            await errorHandler.handle(wrappedError)
            throw wrappedError
        }
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
