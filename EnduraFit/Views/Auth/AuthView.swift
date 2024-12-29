import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isRegistering = false
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isValidPassword: Bool {
        return password.count >= 6
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isRegistering ? "Create Account" : "Welcome Back")
                    .font(.title)
                    .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) { _ in
                            errorMessage = nil
                        }
                    
                    if !email.isEmpty && !isValidEmail {
                        Text("Please enter a valid email")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(isRegistering ? .newPassword : .password)
                        .onChange(of: password) { _ in
                            errorMessage = nil
                        }
                    
                    if isRegistering && !password.isEmpty && !isValidPassword {
                        Text("Password must be at least 6 characters")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }
                
                Button(action: handleAuth) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(isRegistering ? "Sign Up" : "Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || !isValidEmail || (isRegistering && !isValidPassword))
                
                Button(action: { isRegistering.toggle() }) {
                    Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                .disabled(isLoading)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func handleAuth() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = AuthError.emptyFields.errorDescription
            return
        }
        
        guard isValidEmail else {
            errorMessage = AuthError.invalidEmail.errorDescription
            return
        }
        
        if isRegistering && !isValidPassword {
            errorMessage = AuthError.weakPassword.errorDescription
            return
        }
        
        Task {
            isLoading = true
            do {
                if isRegistering {
                    try await authService.signUp(email: email, password: password)
                } else {
                    try await authService.signIn(email: email, password: password)
                }
            } catch {
                if let authError = error as? AuthError {
                    errorMessage = authError.errorDescription
                } else {
                    errorMessage = error.localizedDescription
                }
            }
            isLoading = false
        }
    }
} 