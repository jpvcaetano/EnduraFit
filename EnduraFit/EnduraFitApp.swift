//
//  EnduraFitApp.swift
//  EnduraFit
//
//  Created by João Valdeira Caetano on 08/12/2024.
//

import SwiftUI

@main
struct EnduraFitApp: App {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var workoutStore: WorkoutStore
    
    init() {
        FirebaseConfig.configure()
        let authService = AuthenticationService()
        _authService = StateObject(wrappedValue: authService)
        _workoutStore = StateObject(wrappedValue: WorkoutStore(authService: authService))
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
