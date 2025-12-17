# Clarity Mental Health App

A comprehensive Flutter mental health application with Firebase backend integration for secure data storage and synchronization.

## Features

### 🔐 Authentication & User Management
- Email/password authentication
- Google Sign-In integration
- Secure user profile management
- Real-time authentication state management

### 📊 Data Storage & Synchronization
- **Firebase Firestore Integration**: All user data is securely stored in Firebase Firestore
- **Real-time Synchronization**: Data syncs automatically across devices
- **Offline Support**: App works offline with automatic sync when connection is restored
- **Data Backup & Restore**: Complete backup and restore functionality

### 📝 Journal Management
- Create and manage journal entries
- Sentiment analysis for entries
- Real-time data synchronization
- Export/import journal data

### 🎯 Mood Tracking
- Daily mood tracking with scoring
- Historical mood data visualization
- Trend analysis and insights
- Streak tracking for consistent logging

### 🧠 Mental Health Assessments
- PHQ-9 Depression Assessment
- GAD-7 Anxiety Assessment
- Happiness Assessment
- Self-Esteem Assessment
- Assessment history and progress tracking

### 📈 Insights & Analytics
- Comprehensive data visualization
- Mood trends over time
- Assessment progress tracking
- Journal sentiment analysis
- Progress summaries and recommendations

### 🔄 Data Management
- **Export Data**: Download complete backup of all user data
- **Import Data**: Restore data from backup files
- **Anonymized Export**: Export data with personal information removed
- **Cloud Backup**: Secure cloud backup functionality
- **Data Synchronization**: Manual and automatic sync options

## Firebase Integration

### Database Structure
```
users/{userId}/
├── profile (user profile data)
├── journal/{entryId} (journal entries)
├── moods/{entryId} (mood tracking data)
└── assessments/{resultId} (assessment results)

backups/{userId} (user data backups)
```

### Security Rules
The app uses Firebase Security Rules to ensure:
- Users can only access their own data
- Authenticated users only
- Data validation and sanitization

### Real-time Features
- Live data synchronization across devices
- Automatic offline/online state management
- Conflict resolution for concurrent edits
- Background sync when app is not active

## Data Privacy & Security

### Privacy Features
- All data is encrypted in transit and at rest
- User data is isolated per user account
- Anonymized data export option
- Local data clearing capabilities
- Secure authentication with Firebase Auth

### Data Export/Import
- **JSON Format**: All data exports use standardized JSON format
- **Complete Backup**: Includes all user data (profile, journal, mood, assessments)
- **Selective Import**: Import specific data types
- **Data Validation**: Imported data is validated before processing

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project setup
- Android Studio / VS Code
- Git

### Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication (Email/Password and Google Sign-In)
3. Create Firestore database
4. Add your app to Firebase project
5. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
6. Follow the Firebase setup guide in `FIREBASE_SETUP.md`

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd clarity_mental_health
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase (see FIREBASE_SETUP.md)

4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

### State Management
- **Riverpod**: For state management and dependency injection
- **Repository Pattern**: Clean separation of data access logic
- **Provider Architecture**: Reactive state updates

### Data Layer
```
Presentation Layer (Screens/Widgets)
    ↓
State Management (Riverpod Providers)
    ↓
Repository Layer (Data Access)
    ↓
Firebase Services (Firestore, Auth)
```

### Key Components
- **Services**: Firebase integration, data sync, export/import
- **Repositories**: Data access abstraction layer
- **State Providers**: Reactive state management
- **Models**: Data models with JSON serialization

## Data Models

### User Profile
```dart
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;
}
```

### Journal Entry
```dart
class JournalEntry {
  final String id;
  final String text;
  final int sentimentScore;
  final DateTime timestamp;
}
```

### Mood Entry
```dart
class MoodEntry {
  final String id;
  final DateTime date;
  final int score; // 0-27 normalized score (higher = better mood)
}
```

### Assessment Result
```dart
class AssessmentResult {
  final String id;
  final AssessmentKind kind;
  final int totalScore;
  final String severity;
  final DateTime completedAt;
  final List<int> answers;
}
```

## API Documentation

### Data Sync Service
- `syncAllUserData(userId)`: Sync all user data
- `backupUserData(userId)`: Create cloud backup
- `restoreUserData(userId)`: Restore from backup

### Data Export Service
- `exportUserData(userId)`: Export all user data
- `exportToFile(userId)`: Export to downloadable file
- `importUserData(userId, data)`: Import data from backup
- `exportAnonymizedData(userId)`: Export without personal info

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Disclaimer

This app does not provide medical advice. If you are in crisis or considering self-harm, contact local emergency services or a crisis hotline immediately. This application is for wellness and reflection purposes only and is NOT a medical device or diagnosis tool.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact: support@clarityapp.com

## Changelog

### Version 1.0.0
- Initial release with Firebase integration
- Complete data management system
- Real-time synchronization
- Comprehensive backup/restore functionality
- Advanced insights and analytics
