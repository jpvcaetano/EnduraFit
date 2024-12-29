import Foundation

struct User: Codable {
    var id: String
    var name: String?
    var email: String
    var birthDate: Date?
    var gender: Gender?
    var preferences: WorkoutPreferences?
    
    enum Gender: String, Codable, CaseIterable {
        case male
        case female
        case other
        case preferNotToSay = "prefer not to say"
    }
}

struct WorkoutPreferences: Codable {
    var fitnessGoals: Set<FitnessGoal>
    var workoutLocation: WorkoutLocation
    var availability: [Weekday]
    var desiredDuration: Duration // in minutes
    
    enum Duration: Int, Codable, CaseIterable {
        case fifteen = 15
        case thirty = 30
        case fortyfive = 45
        case sixty = 60
        case ninety = 90
        
        var description: String {
            "\(rawValue) minutes"
        }
    }
    
    enum FitnessGoal: String, Codable {
        case strength
        case endurance
        case flexibility
        case weightLoss
    }
    
    enum WorkoutLocation: String, Codable {
        case gym
        case home
        case calisthenicspark = "calisthenics park"
    }
    
    enum Weekday: String, Codable {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
}

struct TimeSlot: Codable {
    var startTime: Date
    var duration: TimeInterval
} 
