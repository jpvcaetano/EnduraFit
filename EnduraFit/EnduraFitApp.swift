//
//  EnduraFitApp.swift
//  EnduraFit
//
//  Created by João Valdeira Caetano on 08/12/2024.
//

import SwiftUI
import Firebase

@main
struct EnduraFitApp: App {
    @StateObject private var authService = AuthenticationService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if let user = authService.currentUser {
                MainView()
                    .environmentObject(authService)
                    .environmentObject(WorkoutStore(userId: user.id))
            } else {
                AuthView()
                    .environmentObject(authService)
            }
        }
    }
}
