//
//  EnduraFitApp.swift
//  EnduraFit
//
//  Created by João Valdeira Caetano on 08/12/2024.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct EnduraFitApp: App {
    // Initialize error handler first
    private let errorHandler: ErrorHandler
    private let openAIService: OpenAIService
    @StateObject private var authService: AuthenticationService
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Create error handler
        let errorHandler = ErrorHandler()
        self.errorHandler = errorHandler
        
        // Create OpenAI service
        self.openAIService = OpenAIService(
            apiKey: Config.openAIApiKey,
            errorHandler: errorHandler
        )
        
        // Create auth service
        let auth = AuthenticationService(errorHandler: errorHandler)
        _authService = StateObject(wrappedValue: auth)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.needsProfileCompletion {
                    ProfileCompletionView()
                        .environmentObject(authService)
                        .environmentObject(errorHandler)
                        .handleErrors(errorHandler)
                } else if let user = authService.currentUser {
                    MainView(openAIService: openAIService)
                        .environmentObject(authService)
                        .environmentObject(WorkoutStore(userId: user.id, errorHandler: errorHandler))
                        .environmentObject(errorHandler)
                        .handleErrors(errorHandler)
                } else {
                    AuthView()
                        .environmentObject(authService)
                        .environmentObject(errorHandler)
                        .handleErrors(errorHandler)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
