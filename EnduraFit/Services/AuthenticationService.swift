import Foundation
import FirebaseAuth
import FirebaseFirestore

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
    
    private let db = Firestore.firestore()
    
    init() {
        currentUser = Auth.auth().currentUser.map { user in
            User(
                id: user.uid,
                name: user.displayName,
                email: user.email ?? ""
            )
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            Task {
                if let user = user {
                    self.currentUser = try? await self.fetchUserProfile(userId: user.uid)
                } else {
                    self.currentUser = nil
                }
                self.isInitializing = false
            }
        }
    }
    
    func signUp(
        email: String,
        password: String,
        name: String,
        birthDate: Date,
        gender: User.Gender
    ) async throws {
        do {
            // 1. Create authentication user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // 2. Create user profile
            let user = User(
                id: result.user.uid,
                name: name,
                email: email,
                birthDate: birthDate,
                gender: gender
            )
            
            // 3. Save to Firestore
            try await saveUserProfile(user)
            
            // 4. Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            currentUser = user
            
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
    
    private func saveUserProfile(_ user: User) async throws {
        try await db.collection("users")
            .document(user.id)
            .setData(try JSONEncoder().encode(user).jsonObject())
    }
    
    private func fetchUserProfile(userId: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        guard let data = snapshot.data() else {
            throw AuthError.signInFailed("User profile not found")
        }
        return try JSONDecoder().decode(User.self, from: JSONSerialization.data(withJSONObject: data))
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

// Helper extension for JSON conversion
extension Data {
    func jsonObject() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: self) as? [String: Any] ?? [:]
    }
} 
