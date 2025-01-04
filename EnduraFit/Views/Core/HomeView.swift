import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: WorkoutPlanViewModel
    @State private var showingPlanGenerator = false
    @EnvironmentObject var workoutStore: WorkoutStore
    @Binding var selectedTab: Int
    
    init(openAIService: OpenAIService, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: WorkoutPlanViewModel(openAIService: openAIService))
        _selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to EnduraFit")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    viewModel.reset()
                    showingPlanGenerator = true
                }) {
                    Text("Create New Workout Plan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingPlanGenerator, onDismiss: {
                viewModel.reset()
                Task {
                    await workoutStore.reloadPlans()
                }
            }) {
                WorkoutPlanGeneratorView(viewModel: viewModel, selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    HomeView(openAIService: OpenAIService(apiKey: "preview-key"), selectedTab: .constant(0))
}

