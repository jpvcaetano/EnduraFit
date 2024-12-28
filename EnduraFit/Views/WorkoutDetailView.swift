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
                    
                    ForEach(workout.exercises) { exercise in
                        ExerciseCard(exercise: exercise)
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
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 20) {
                    Label("\(exercise.sets) sets", systemImage: "number.square.fill")
                    Label("\(exercise.reps) reps", systemImage: "figure.run")
                    Label("\(Int(exercise.restTime))s rest", systemImage: "timer")
                }
                .foregroundColor(.secondary)
                
                Text(exercise.description)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    WorkoutDetailView(workout: Workout(
        id: UUID(),
        name: "Full Body Workout",
        exercises: [
            .init(
                id: UUID(),
                name: "Push-ups",
                sets: 3,
                reps: 12,
                restTime: 60,
                description: "Start in a plank position and lower your body until your chest nearly touches the ground."
            ),
            .init(
                id: UUID(),
                name: "Squats",
                sets: 4,
                reps: 15,
                restTime: 90,
                description: "Stand with feet shoulder-width apart, lower your body as if sitting back into a chair."
            )
        ],
        createdAt: Date()
    ))
} 