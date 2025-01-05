import SwiftUI

struct ProfileCompletionView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var birthDate = Date()
    @State private var gender: User.Gender = .preferNotToSay
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Complete Your Profile") {
                    DatePicker("Birth Date",
                             selection: $birthDate,
                             in: ...Date(),
                             displayedComponents: .date)
                        .datePickerStyle(.compact)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(User.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue.capitalized)
                                .tag(gender)
                        }
                    }
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: completeProfile) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Complete Profile")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Welcome!")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func completeProfile() {
        Task {
            isLoading = true
            do {
                try await authService.completeGoogleProfile(
                    birthDate: birthDate,
                    gender: gender
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
} 