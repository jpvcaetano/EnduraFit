import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            List {
                Section("Personal Information") {
                    Text("Email: \(authService.currentUser?.email ?? "")")
                    Text("Name: \(authService.currentUser?.name ?? "Not Set")")
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
                }
            }
            .navigationTitle("Profile")
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
} 