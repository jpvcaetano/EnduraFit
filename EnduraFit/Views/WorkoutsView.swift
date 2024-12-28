import SwiftUI

struct WorkoutsView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    
    var body: some View {
        NavigationView {
            List {
                if workoutStore.savedWorkouts.isEmpty {
                    Text("No saved workouts yet")
                        .foregroundColor(.gray)
                } else {
                    ForEach(workoutStore.savedWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutRow(workout: workout)
                        }
                    }
                    .onDelete(perform: workoutStore.deleteWorkout)
                }
            }
            .navigationTitle("My Workouts")
            .toolbar {
                EditButton()
                    .disabled(workoutStore.savedWorkouts.isEmpty)
            }
        }
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name)
                .font(.headline)
            Text("\(workout.exercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(workout.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 