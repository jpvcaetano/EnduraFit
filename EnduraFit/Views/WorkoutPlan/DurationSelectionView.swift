import SwiftUI

struct DurationSelectionView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How long do you want to work out?")
                .font(.title2)
                .padding(.horizontal)
            
            Text("Choose your preferred workout duration")
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(WorkoutPreferences.Duration.allCases, id: \.self) { duration in
                        DurationCard(
                            duration: duration,
                            isSelected: viewModel.desiredDuration == duration,
                            action: {
                                viewModel.desiredDuration = duration
                            }
                        )
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
                    viewModel.currentStep = .review
                }) {
                    Text("Next")
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

struct DurationCard: View {
    let duration: WorkoutPreferences.Duration
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(duration.description)
                        .font(.headline)
                    Text(durationDescription(for: duration))
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
    
    private func durationDescription(for duration: WorkoutPreferences.Duration) -> String {
        switch duration {
        case .fifteen: return "Quick workout"
        case .thirty: return "Standard session"
        case .fortyfive: return "Extended workout"
        case .sixty: return "Full session"
        case .ninety: return "Intensive training"
        }
    }
} 