import Foundation
import FirebaseAuth

enum AuthError: Error {
    case signUpFailed(String)
    case signInFailed(String)
    case signOutFailed(String)
}

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    
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
        } catch {
            throw AuthError.signUpFailed(error.localizedDescription)
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
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
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
