//
//  ContentView.swift
//  EnduraFit
//
//  Created by João Valdeira Caetano on 08/12/2024.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    let openAIService: OpenAIService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(openAIService: openAIService, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            WorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainView(openAIService: OpenAIService(apiKey: "preview-key", errorHandler: ErrorHandler()))
        .environmentObject(AuthenticationService(errorHandler: ErrorHandler()))
        .environmentObject(WorkoutStore(userId: "preview-id", errorHandler: ErrorHandler()))
        .environmentObject(ErrorHandler())
}

