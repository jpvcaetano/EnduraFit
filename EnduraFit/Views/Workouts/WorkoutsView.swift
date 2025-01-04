import SwiftUI

struct WorkoutsView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    
    var body: some View {
        NavigationStack {
            List {
                if workoutStore.savedPlans.isEmpty {
                    Text("No workout plans yet")
                        .foregroundColor(.gray)
                } else {
                    ForEach(workoutStore.savedPlans) { plan in
                        NavigationLink(destination: WorkoutPlanView(plan: plan)) {
                            WorkoutPlanRow(plan: plan)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            workoutStore.deletePlan(workoutStore.savedPlans[index])
                        }
                    }
                }
            }
            .navigationTitle("My Workout Plans")
            .toolbar {
                EditButton()
                    .disabled(workoutStore.savedPlans.isEmpty)
            }
            .navigationDestination(item: $workoutStore.selectedPlan) { plan in
                WorkoutPlanView(plan: plan)
            }
        }
    }
}

struct WorkoutPlanRow: View {
    let plan: WorkoutPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(plan.name)
                .font(.headline)
            Text("\(plan.selectedDays.orderedWeekdays.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Goals: \(plan.goals.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 