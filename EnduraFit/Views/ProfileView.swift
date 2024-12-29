import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            if let user = authService.currentUser {
                List {
                    Section("Personal Information") {
                        Text("Email: \(user.email)")
                        Text("Name: \(user.name ?? "Not Set")")
                    }
                    
                    Section {
                        Button("Sign Out", role: .destructive) {
                            do {
                                try authService.signOut()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
                .alert("Error", isPresented: .constant(errorMessage != nil)) {
                    Button("OK") { errorMessage = nil }
                } message: {
                    Text(errorMessage ?? "")
                }
            } else {
                VStack(spacing: 20) {
                    Text("Sign In")
                        .font(.title)
                        .padding()
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: signIn) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    
                    Button(action: signUp) {
                        Text("Create Account")
                    }
                    .disabled(isLoading)
                }
                .padding()
                .navigationTitle("Profile")
            }
        }
    }
    
    private func signIn() {
        Task {
            isLoading = true
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func signUp() {
        Task {
            isLoading = true
            do {
                try await authService.signUp(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
} 