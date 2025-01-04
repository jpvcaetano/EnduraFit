import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.horizontal)
                
                // Exercise List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Exercises")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(workout.exercises) { exercise in
                            ExerciseCard(exercise: exercise)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct ExerciseCard: View {
    let exercise: Workout.Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.name)
                .font(.title3)
                .bold()
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                // Stats Grid
                Grid(alignment: .leading, horizontalSpacing: 16) {
                    GridRow {
                        HStack(spacing: 4) {
                            Image(systemName: "number.square.fill")
                            Text("\(exercise.sets) sets")
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "figure.run")
                            Text("\(exercise.reps) reps")
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                            Text("\(Int(exercise.restTime))s rest")
                        }
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Text(exercise.description)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
