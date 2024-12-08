import SwiftUI

struct ProfileView: View {
    @State private var isSignedIn = false
    
    var body: some View {
        NavigationView {
            if isSignedIn {
                List {
                    Section("Personal Information") {
                        Text("Name: Not Set")
                        Text("Birthday: Not Set")
                        Text("Gender: Not Set")
                    }
                    
                    Section("Preferences") {
                        Text("Fitness Goals: Not Set")
                        Text("Preferred Location: Not Set")
                    }
                    
                    Section {
                        Button("Sign Out", role: .destructive) {
                            // Sign out action
                        }
                    }
                }
                .navigationTitle("Profile")
            } else {
                VStack(spacing: 20) {
                    Text("Sign In")
                        .font(.title)
                        .padding()
                    
                    Button(action: {
                        // Apple Sign In
                    }) {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Sign in with Apple")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Google Sign In
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Sign in with Google")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding()
                .navigationTitle("Profile")
            }
        }
    }
} 