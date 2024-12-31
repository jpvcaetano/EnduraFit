import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = WorkoutPlanViewModel()
    @State private var showingPlanGenerator = false
    @EnvironmentObject var workoutStore: WorkoutStore
    
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
                workoutStore.reloadPlans()
            }) {
                WorkoutPlanGeneratorView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    HomeView()
}

