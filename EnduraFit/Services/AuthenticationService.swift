import Foundation
import FirebaseAuth

enum AuthError: LocalizedError {
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
        }
    }
}

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isInitializing = true
    
    init() {
        currentUser = Auth.auth().currentUser.map { user in
            User(
                id: user.uid,
                name: user.displayName,
                email: user.email ?? ""
            )
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user.map { user in
                User(
                    id: user.uid,
                    name: user.displayName,
                    email: user.email ?? ""
                )
            }
            self?.isInitializing = false
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = User(
                id: result.user.uid,
                name: result.user.displayName,
                email: result.user.email ?? ""
            )
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.invalidEmail.rawValue:
                throw AuthError.invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                throw AuthError.weakPassword
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw AuthError.emailAlreadyInUse
            case AuthErrorCode.networkError.rawValue:
                throw AuthError.networkError
            default:
                throw AuthError.signUpFailed(error.localizedDescription)
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = User(
                id: result.user.uid,
                name: result.user.displayName,
                email: result.user.email ?? ""
            )
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.invalidEmail.rawValue:
                throw AuthError.invalidEmail
            case AuthErrorCode.wrongPassword.rawValue:
                throw AuthError.wrongPassword
            case AuthErrorCode.userNotFound.rawValue:
                throw AuthError.userNotFound
            case AuthErrorCode.networkError.rawValue:
                throw AuthError.networkError
            default:
                throw AuthError.signInFailed(error.localizedDescription)
            }
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }
} 
