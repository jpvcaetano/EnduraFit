import SwiftUI

struct WorkoutsView: View {
    var body: some View {
        NavigationView {
            List {
                Text("No saved workouts yet")
                    .foregroundColor(.gray)
            }
            .navigationTitle("My Workouts")
        }
    }
} 