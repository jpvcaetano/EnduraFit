import SwiftUI

struct WorkoutPlanView: View {
    let plan: WorkoutPlan
    
    var body: some View {
        List {
            PlanInfoSection(plan: plan)
            WorkoutScheduleSection(plan: plan)
        }
        .navigationTitle(plan.name)
        .listStyle(.insetGrouped)
    }
}

// Plan Info Section
private struct PlanInfoSection: View {
    let plan: WorkoutPlan
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goals: \(plan.goals.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                    Text("Location: \(plan.location.rawValue.capitalized)")
                    Text("Workout Duration: \(plan.duration.description)")
                    Text("Days: \(plan.selectedDays.orderedWeekdays.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                }
                .foregroundColor(.secondary)
                
                Text("Created \(plan.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Workout Schedule Section
private struct WorkoutScheduleSection: View {
    let plan: WorkoutPlan
    
    var body: some View {
        Section("Weekly Schedule") {
            ForEach(plan.selectedDays.orderedWeekdays, id: \.self) { day in
                WorkoutDayGroup(workouts: workoutsForDay(day), day: day)
            }
        }
    }
    
    private func workoutsForDay(_ day: WorkoutPreferences.Weekday) -> [Workout] {
        plan.workouts.filter { $0.day == day }
    }
}

// Workout Day Group
private struct WorkoutDayGroup: View {
    let workouts: [Workout]
    let day: WorkoutPreferences.Weekday
    
    var body: some View {
        ForEach(workouts) { workout in
            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                WorkoutRow(workout: workout, day: day)
            }
        }
    }
}

// Workout Row
private struct WorkoutRow: View {
    let workout: Workout
    let day: WorkoutPreferences.Weekday
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(day.rawValue.capitalized)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(workout.name)
                .font(.headline)
            Text("\(workout.exercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
} 
