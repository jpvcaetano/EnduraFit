import SwiftUI

struct WorkoutPlanView: View {
    let plan: WorkoutPlan
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Created \(plan.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Goals: \(plan.goals.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                        Text("Location: \(plan.location.rawValue.capitalized)")
                        Text("Duration: \(plan.duration.description)")
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Section("Weekly Schedule") {
                ForEach(plan.workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name)
                                .font(.headline)
                            Text("\(workout.exercises.count) exercises")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(plan.name)
        .listStyle(.insetGrouped)
    }
} 