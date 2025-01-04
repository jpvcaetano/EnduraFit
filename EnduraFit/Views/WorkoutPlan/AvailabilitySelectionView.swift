import SwiftUI

struct AvailabilitySelectionView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    let weekdays: [WorkoutPreferences.Weekday] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("When can you work out?")
                .font(.title2)
                .padding(.horizontal)
            
            Text("Select your available days")
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(weekdays, id: \.self) { day in
                        DaySelectionCard(
                            day: day,
                            isSelected: viewModel.selectedDays.contains(day),
                            action: {
                                if viewModel.selectedDays.contains(day) {
                                    viewModel.selectedDays.remove(day)
                                } else {
                                    viewModel.selectedDays.insert(day)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.currentStep = .location
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
                    viewModel.currentStep = .duration
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!viewModel.selectedDays.isEmpty ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(viewModel.selectedDays.isEmpty)
            }
            .padding()
        }
    }
}

struct DaySelectionCard: View {
    let day: WorkoutPreferences.Weekday
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(day.rawValue.capitalized)
                    .font(.headline)
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
} 