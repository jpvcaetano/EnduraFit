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
    @StateObject private var authService = AuthenticationService()
    
    init() {
        FirebaseConfig.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isInitializing {
                    ProgressView("Loading...")
                } else {
                    MainView()
                        .environmentObject(workoutStore)
                        .environmentObject(authService)
                }
            }
        }
    }
}
