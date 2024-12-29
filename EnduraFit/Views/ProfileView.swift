import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAuth = false
    
    var body: some View {
        NavigationView {
            if let user = authService.currentUser {
                List {
                    Section("Personal Information") {
                        Text("Email: \(user.email)")
                        Text("Name: \(user.name ?? "Not Set")")
                        if let birthDate = user.birthDate {
                            Text("Birth Date: \(birthDate.formatted(date: .long, time: .omitted))")
                        }
                        if let gender = user.gender {
                            Text("Gender: \(gender.rawValue.capitalized)")
                        }
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
                    
                    Button(action: { showingAuth = true }) {
                        Text("Create Account")
                    }
                    .disabled(isLoading)
                }
                .padding()
                .navigationTitle("Profile")
                .fullScreenCover(isPresented: $showingAuth) {
                    AuthView()
                }
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
} 