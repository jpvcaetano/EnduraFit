import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var errorMessage: String?
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var navigateToAuth = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Personal Information") {
                    Text("Name: \(authService.currentUser?.name ?? "Not Set")")
                    Text("Email: \(authService.currentUser?.email ?? "")")
                    if let birthDate = authService.currentUser?.birthDate {
                        Text("Birth Date: \(birthDate.formatted(date: .long, time: .omitted))")
                    }
                    if let gender = authService.currentUser?.gender {
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
                    
                    Button("Delete Account", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        isDeleting = true
                        do {
                            try await authService.deleteAccount()
                            navigateToAuth = true
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                        isDeleting = false
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .disabled(isDeleting)
            .fullScreenCover(isPresented: $navigateToAuth) {
                AuthView()
            }
        }
    }
} 
