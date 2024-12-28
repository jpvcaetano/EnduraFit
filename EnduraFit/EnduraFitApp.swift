//
//  EnduraFitApp.swift
//  EnduraFit
//
//  Created by João Valdeira Caetano on 08/12/2024.
//

import SwiftUI

@main
struct EnduraFitApp: App {
    @StateObject private var workoutStore = WorkoutStore()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(workoutStore)
        }
    }
}
