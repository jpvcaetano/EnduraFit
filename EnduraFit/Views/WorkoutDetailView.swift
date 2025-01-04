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
                    
                    Text("Created \(workout.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.secondary)
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
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 20) {
                    Label("\(exercise.sets) sets", systemImage: "number.square.fill")
                        .frame(minWidth: 80, alignment: .leading)
                    Label("\(exercise.reps) reps", systemImage: "figure.run")
                        .frame(minWidth: 80, alignment: .leading)
                    Label("\(Int(exercise.restTime))s rest", systemImage: "timer")
                        .frame(minWidth: 80, alignment: .leading)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Text(exercise.description)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
