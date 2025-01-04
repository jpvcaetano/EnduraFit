# EnduraFit

EnduraFit is an iOS fitness application that generates personalized workout plans using AI technology. The app creates custom workout routines based on user preferences, fitness goals, and available equipment.

## Features

- **AI-Powered Workout Generation**: Uses OpenAI's GPT-4 to create personalized workout plans
- **User Authentication**: Secure email-based authentication with email verification
- **Customizable Workout Plans**:
  - Multiple fitness goals (strength, endurance, flexibility, weight loss)
  - Location-based workouts (gym, home, calisthenics park)
  - Flexible workout duration (15-90 minutes)
  - Weekly schedule customization
- **Workout Management**: Save, view, and delete workout plans
- **Profile Management**: User profile with personal information and preferences

## Technical Stack

- **Framework**: SwiftUI
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **AI Integration**: OpenAI GPT-4 API
- **Minimum iOS Version**: iOS 16.0+

## Project Structure

```
EnduraFit/
├── Config/               # Configuration files
├── Models/              # Data models
├── Resources/           # Assets and resources
├── Services/           # Core services
│   ├── AuthenticationService.swift
│   ├── OpenAIService.swift
│   └── WorkoutStore.swift
├── ViewModels/         # View models
└── Views/              # UI components
    ├── Auth/           # Authentication views
    ├── Core/           # Main navigation views
    ├── WorkoutPlan/    # Workout plan views
    └── Workouts/       # Workout detail views
```

## Setup

1. Clone the repository
2. Install dependencies using Swift Package Manager
3. Create a `Config.swift` file based on `Config.template.swift`
4. Add your OpenAI API key to `Config.swift`
5. Set up a Firebase project and add the `GoogleService-Info.plist`
6. Build and run the project

## Requirements

- Xcode 14.0+
- iOS 16.0+
- Swift 5.7+
- OpenAI API key
- Firebase project

## Dependencies

- Firebase Authentication
- Cloud Firestore
- OpenAI API 