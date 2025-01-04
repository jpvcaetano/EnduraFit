import SwiftUI

struct WorkoutPlanGeneratorView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.currentStep {
                case .goals:
                    GoalsSelectionView(viewModel: viewModel)
                case .location:
                    LocationSelectionView(viewModel: viewModel)
                case .duration:
                    DurationSelectionView(viewModel: viewModel)
                case .availability:
                    AvailabilitySelectionView(viewModel: viewModel)
                case .review:
                    ReviewPlanView(viewModel: viewModel, selectedTab: $selectedTab)
                }
            }
            .navigationTitle("Create Workout Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
} 