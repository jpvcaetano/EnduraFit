# EnduraFit

EnduraFit is an iOS fitness application that generates personalized workout plans based on user preferences and goals.

## Features

- **Personalized Workout Plans**: Generate custom workout plans based on:
  - Fitness goals (strength, endurance, flexibility, weight loss)
  - Preferred workout location (gym, home, calisthenics park)
  - Available workout duration
  - Weekly availability

- **Workout Management**:
  - View generated workout plans
  - Track completed workouts
  - Detailed exercise instructions

- **User Profile**:
  - Personal information management
  - Workout preferences
  - Progress tracking

## Technical Stack

- SwiftUI for the user interface
- MVVM architecture
- Async/await for asynchronous operations
- Codable for data serialization

## Project Structure 

EnduraFit/
├── Models/
│ ├── User.swift
│ └── Workout.swift
├── Views/
│ ├── HomeView.swift
│ ├── WorkoutsView.swift
│ ├── ProfileView.swift
│ └── WorkoutPlan/
│ ├── WorkoutPlanGeneratorView.swift
│ ├── GoalsSelectionView.swift
│ ├── LocationSelectionView.swift
│ ├── DurationSelectionView.swift
│ ├── AvailabilitySelectionView.swift
│ └── ReviewPlanView.swift
└── ViewModels/
└── WorkoutPlanViewModel.swift

## Setup

1. Clone the repository
2. Open EnduraFit.xcodeproj in Xcode
3. Build and run the project

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Future Enhancements

- Integration with OpenAI for intelligent workout generation
- Firebase authentication and data persistence
- Social features for sharing workouts
- Progress tracking and analytics
- Integration with HealthKit

## License

[Your chosen license]

## Contributing

[Contributing guidelines if you want to accept contributions]