import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isInitializing = true
    
    private let db = Firestore.firestore()
    private let errorHandler: ErrorHandler
    private var stateListener: AuthStateDidChangeListenerHandle?
    
    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        
        currentUser = Auth.auth().currentUser.flatMap { user in
            guard user.isEmailVerified else { return nil }
            return User(
                id: user.uid,
                name: user.displayName,
                email: user.email ?? ""
            )
        }
        
        stateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            Task {
                if let user = user {
                    if user.isEmailVerified {
                        do {
                            self.currentUser = try await self.fetchUserProfile(userId: user.uid)
                        } catch {
                            await self.errorHandler.handle(error)
                            self.currentUser = nil
                        }
                    } else {
                        self.currentUser = nil
                    }
                } else {
                    self.currentUser = nil
                }
                self.isInitializing = false
            }
        }
    }
    
    deinit {
        if let listener = stateListener {
            Auth.auth().removeStateDidChangeListener(listener)
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
            
            // 2. Send verification email
            try await result.user.sendEmailVerification()
            
            // 3. Create user profile
            let user = User(
                id: result.user.uid,
                name: name,
                email: email,
                birthDate: birthDate,
                gender: gender
            )
            
            // 4. Save to Firestore
            try await saveUserProfile(user)
            
            // 5. Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // Don't set currentUser here - user needs to verify email first
            currentUser = nil
            
        } catch let error as NSError {
            let authError: AuthError
            switch error.code {
            case AuthErrorCode.invalidEmail.rawValue:
                authError = .invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                authError = .weakPassword
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                authError = .emailAlreadyInUse
            case AuthErrorCode.networkError.rawValue:
                authError = .networkError
            default:
                authError = .signUpFailed(error.localizedDescription)
            }
            await errorHandler.handle(authError)
            throw authError
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
            
            // Always check email verification
            guard result.user.isEmailVerified else {
                // Optionally resend verification email
                try await result.user.sendEmailVerification()
                let error = AuthError.emailNotVerified
                await errorHandler.handle(error)
                throw error
            }
            
            // Only fetch and set user profile if email is verified
            currentUser = try await fetchUserProfile(userId: result.user.uid)
            
        } catch let error as NSError {
            let authError: AuthError
            switch error.code {
            case AuthErrorCode.invalidEmail.rawValue:
                authError = .invalidEmail
            case AuthErrorCode.wrongPassword.rawValue:
                authError = .wrongPassword
            case AuthErrorCode.userNotFound.rawValue:
                authError = .userNotFound
            case AuthErrorCode.networkError.rawValue:
                authError = .networkError
            default:
                authError = .signInFailed(error.localizedDescription)
            }
            await errorHandler.handle(authError)
            throw authError
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            let authError = AuthError.signOutFailed(error.localizedDescription)
            Task {
                await errorHandler.handle(authError)
            }
            throw authError
        }
    }
    
    func resendVerificationEmail() async throws {
        do {
            guard let user = Auth.auth().currentUser else {
                let error = AuthError.userNotFound
                await errorHandler.handle(error)
                throw error
            }
            try await user.sendEmailVerification()
        } catch {
            let authError = AuthError.signUpFailed(error.localizedDescription)
            await errorHandler.handle(authError)
            throw authError
        }
    }
    
    func refreshEmailVerificationStatus() async throws {
        guard let user = Auth.auth().currentUser else {
            let error = AuthError.userNotFound
            await errorHandler.handle(error)
            throw error
        }
        
        try await user.reload()
        if user.isEmailVerified {
            // Just fetch and set the user profile if verified
            currentUser = try await fetchUserProfile(userId: user.uid)
        }
    }
}

// Helper extension for JSON conversion
extension Data {
    func jsonObject() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: self) as? [String: Any] ?? [:]
    }
} 
