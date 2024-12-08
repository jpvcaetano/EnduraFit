import SwiftUI

struct LocationSelectionView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    let locations: [WorkoutPreferences.WorkoutLocation] = [
        .gym, .home, .calisthenicspark
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Where will you work out?")
                .font(.title2)
                .padding(.horizontal)
            
            Text("Choose your preferred location")
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(locations, id: \.self) { location in
                        LocationSelectionCard(
                            location: location,
                            isSelected: viewModel.selectedLocation == location,
                            action: {
                                viewModel.selectedLocation = location
                            }
                        )
                    }
                }
                .padding()
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.currentStep = .goals
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
                    viewModel.currentStep = .availability
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedLocation == nil ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(viewModel.selectedLocation == nil)
            }
            .padding()
        }
    }
}

struct LocationSelectionCard: View {
    let location: WorkoutPreferences.WorkoutLocation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: locationIcon(for: location))
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(location.rawValue.capitalized)
                        .font(.headline)
                    Text(locationDescription(for: location))
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
    
    private func locationIcon(for location: WorkoutPreferences.WorkoutLocation) -> String {
        switch location {
        case .gym: return "dumbbell.fill"
        case .home: return "house.fill"
        case .calisthenicspark: return "figure.strengthtraining.functional"
        }
    }
    
    private func locationDescription(for location: WorkoutPreferences.WorkoutLocation) -> String {
        switch location {
        case .gym: return "Access to full equipment"
        case .home: return "Minimal equipment needed"
        case .calisthenicspark: return "Bars and bodyweight exercises"
        }
    }
} 