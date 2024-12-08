import SwiftUI

struct GoalsSelectionView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    let goals: [WorkoutPreferences.FitnessGoal] = [
        .strength, .endurance, .flexibility, .weightLoss
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What are your fitness goals?")
                .font(.title2)
                .padding(.horizontal)
            
            Text("Select all that apply")
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(goals, id: \.self) { goal in
                        GoalSelectionCard(
                            goal: goal,
                            isSelected: viewModel.selectedGoals.contains(goal),
                            action: {
                                if viewModel.selectedGoals.contains(goal) {
                                    viewModel.selectedGoals.remove(goal)
                                } else {
                                    viewModel.selectedGoals.insert(goal)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            
            Spacer()
            
            Button(action: {
                viewModel.currentStep = .location
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedGoals.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(viewModel.selectedGoals.isEmpty)
            .padding()
        }
    }
}

struct GoalSelectionCard: View {
    let goal: WorkoutPreferences.FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(goal.rawValue.capitalized)
                        .font(.headline)
                    Text(goalDescription(for: goal))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func goalDescription(for goal: WorkoutPreferences.FitnessGoal) -> String {
        switch goal {
        case .strength:
            return "Build muscle and increase strength"
        case .endurance:
            return "Improve stamina and cardiovascular fitness"
        case .flexibility:
            return "Enhance mobility and reduce stiffness"
        case .weightLoss:
            return "Burn fat and improve body composition"
        }
    }
} 