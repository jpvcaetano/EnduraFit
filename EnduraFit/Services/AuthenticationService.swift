import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isInitializing = true
    @Published var needsProfileCompletion = false
    
    private let db = Firestore.firestore()
    private let errorHandler: ErrorHandler
    private var stateListener: AuthStateDidChangeListenerHandle?
    private var temporaryGoogleUser: (id: String, name: String, email: String)?
    
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
                    do {
                        self.currentUser = try await self.fetchUserProfile(userId: user.uid)
                    } catch {
                        await self.errorHandler.handle(error)
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
            
            // Always check email verification
            guard result.user.isEmailVerified else {
                // Optionally resend verification email
                try await result.user.sendEmailVerification()
                throw AuthError.emailNotVerified
            }
            
            // Only fetch and set user profile if email is verified
            currentUser = try await fetchUserProfile(userId: result.user.uid)
            
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
    
    func resendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        try await user.sendEmailVerification()
    }
    
    func refreshEmailVerificationStatus() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        try await user.reload()
        if user.isEmailVerified {
            // Just fetch and set the user profile if verified
            currentUser = try await fetchUserProfile(userId: user.uid)
        }
    }
    
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.signInFailed("Failed to configure authentication")
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.signInFailed("Failed to present sign in")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.signInFailed("Invalid credentials")
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        let firebaseUser = authResult.user
        
        // Try to fetch existing user profile
        do {
            currentUser = try await fetchUserProfile(userId: firebaseUser.uid)
            // If we successfully fetched the profile, don't show profile completion
            needsProfileCompletion = false
            temporaryGoogleUser = nil
        } catch {
            // If user profile doesn't exist, store temporary user info and set needsProfileCompletion flag
            temporaryGoogleUser = (
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? "",
                email: firebaseUser.email ?? ""
            )
            needsProfileCompletion = true
        }
    }
    
    func completeGoogleProfile(birthDate: Date, gender: User.Gender) async throws {
        guard let tempUser = temporaryGoogleUser else {
            throw AuthError.signInFailed("Invalid authentication state")
        }
        
        let user = User(
            id: tempUser.id,
            name: tempUser.name,
            email: tempUser.email,
            birthDate: birthDate,
            gender: gender
        )
        
        // Save to Firestore
        try await saveUserProfile(user)
        
        // Update current user and clear temporary data
        self.currentUser = user
        self.temporaryGoogleUser = nil
        self.needsProfileCompletion = false
    }
    
    private func createOrUpdateUserProfile(userId: String, name: String, email: String) async throws {
        // This method is now only used for updating existing profiles
        let userRef = db.collection("users").document(userId)
        try await userRef.setData([
            "name": name,
            "email": email,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        
        // Fetch and update the current user to get all fields
        self.currentUser = try await fetchUserProfile(userId: userId)
    }
}

// Helper extension for JSON conversion
extension Data {
    func jsonObject() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: self) as? [String: Any] ?? [:]
    }
} 
