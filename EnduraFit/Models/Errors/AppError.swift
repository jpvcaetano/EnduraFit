import Foundation

protocol AppError: LocalizedError {
    var title: String { get }
    var code: Int { get }
}

// Base implementation for app errors
struct BaseError: AppError {
    let title: String
    let code: Int
    let errorDescription: String?
    
    init(title: String = "Error", description: String, code: Int) {
        self.title = title
        self.errorDescription = description
        self.code = code
    }
}

// Network related errors
enum NetworkError: AppError {
    case noInternet
    case timeout
    case invalidResponse
    case serverError(String)
    
    var title: String {
        switch self {
        case .noInternet: return "No Internet Connection"
        case .timeout: return "Request Timeout"
        case .invalidResponse: return "Invalid Response"
        case .serverError: return "Server Error"
        }
    }
    
    var code: Int {
        switch self {
        case .noInternet: return 100
        case .timeout: return 101
        case .invalidResponse: return 102
        case .serverError: return 103
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Please check your internet connection and try again."
        case .timeout:
            return "The request timed out. Please try again."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .serverError(let message):
            return message
        }
    }
}

// Domain specific errors
enum WorkoutError: AppError {
    case invalidPlan
    case generationFailed(String)
    case saveFailed
    case loadFailed
    case deleteFailed
    
    var title: String {
        switch self {
        case .invalidPlan: return "Invalid Workout Plan"
        case .generationFailed: return "Generation Failed"
        case .saveFailed: return "Save Failed"
        case .loadFailed: return "Load Failed"
        case .deleteFailed: return "Delete Failed"
        }
    }
    
    var code: Int {
        switch self {
        case .invalidPlan: return 200
        case .generationFailed: return 201
        case .saveFailed: return 202
        case .loadFailed: return 203
        case .deleteFailed: return 204
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidPlan:
            return "The workout plan is invalid. Please check your inputs."
        case .generationFailed(let reason):
            return "Failed to generate workout plan: \(reason)"
        case .saveFailed:
            return "Failed to save the workout plan. Please try again."
        case .loadFailed:
            return "Failed to load workout plans. Please try again."
        case .deleteFailed:
            return "Failed to delete the workout plan. Please try again."
        }
    }
}

// Authentication errors with improved messages
enum AuthError: AppError {
    case signUpFailed(String)
    case signInFailed(String)
    case signOutFailed(String)
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case emptyFields
    case networkError
    case emailNotVerified
    
    var title: String {
        switch self {
        case .signUpFailed: return "Sign Up Failed"
        case .signInFailed: return "Sign In Failed"
        case .signOutFailed: return "Sign Out Failed"
        case .invalidEmail: return "Invalid Email"
        case .weakPassword: return "Weak Password"
        case .emailAlreadyInUse: return "Email In Use"
        case .userNotFound: return "User Not Found"
        case .wrongPassword: return "Wrong Password"
        case .emptyFields: return "Empty Fields"
        case .networkError: return "Network Error"
        case .emailNotVerified: return "Email Not Verified"
        }
    }
    
    var code: Int {
        switch self {
        case .signUpFailed: return 300
        case .signInFailed: return 301
        case .signOutFailed: return 302
        case .invalidEmail: return 303
        case .weakPassword: return 304
        case .emailAlreadyInUse: return 305
        case .userNotFound: return 306
        case .wrongPassword: return 307
        case .emptyFields: return 308
        case .networkError: return 309
        case .emailNotVerified: return 310
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .signUpFailed(let message),
             .signInFailed(let message),
             .signOutFailed(let message):
            return message
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 6 characters long"
        case .emailAlreadyInUse:
            return "An account with this email already exists"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .emptyFields:
            return "Please fill in all fields"
        case .networkError:
            return "Network error. Please check your connection"
        case .emailNotVerified:
            return "Please verify your email address before signing in"
        }
    }
} 