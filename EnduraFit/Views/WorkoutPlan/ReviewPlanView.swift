import SwiftUI

struct ReviewPlanView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review Your Preferences")
                .font(.title2)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 16) {
                    PreferenceSection(title: "Fitness Goals") {
                        ForEach(Array(viewModel.selectedGoals), id: \.self) { goal in
                            Text(goal.rawValue.capitalized)
                        }
                    }
                    
                    PreferenceSection(title: "Workout Location") {
                        if let location = viewModel.selectedLocation {
                            Text(location.rawValue.capitalized)
                        }
                    }
                    
                    PreferenceSection(title: "Availability") {
                        ForEach(Array(viewModel.selectedDays), id: \.self) { day in
                            Text(day.rawValue.capitalized)
                        }
                        Text("Duration: \(viewModel.desiredDuration.description)")
                            .padding(.top, 4)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.currentStep = .availability
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    Task {
                        try? await viewModel.generateWorkoutPlan()
                        dismiss()
                    }
                }) {
                    Text("Generate Plan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct PreferenceSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                content()
            }
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
} 