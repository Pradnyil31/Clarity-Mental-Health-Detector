# Firebase Integration Setup Guide

This guide will help you complete the Firebase integration for your Clarity Mental Health app.

## Prerequisites

1. **Firebase Project**: You need a Firebase project set up at [Firebase Console](https://console.firebase.google.com/)
2. **Flutter SDK**: Ensure you have Flutter installed and configured
3. **Platform-specific requirements**:
   - Android: Android Studio with Android SDK
   - iOS: Xcode (macOS only)
   - Web: Modern web browser

## Step 1: Firebase Project Configuration

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `clarity-mental-health` (or your preferred name)
4. Enable Google Analytics (optional)
5. Create the project

### 1.2 Enable Authentication
1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable "Email/Password" authentication
3. Enable "Google" authentication
4. For Google Sign-In, add your app's SHA-1 fingerprint (Android) and configure OAuth consent screen

### 1.3 Enable Firestore Database
1. Go to "Firestore Database" → "Create database"
2. Choose "Start in test mode" (we'll add security rules later)
3. Select a location close to your users

## Step 2: Platform Configuration

### 2.1 Android Configuration

1. **Add Android App**:
   - In Firebase Console, click "Add app" → Android
   - Package name: `com.example.clarity_mental_health`
   - Download `google-services.json`
   - Replace the placeholder file at `android/app/google-services.json`

2. **Update SHA-1 Fingerprint**:
   ```bash
   # Debug SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release SHA-1 (when ready for production)
   keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
   ```
   - Add SHA-1 fingerprints in Firebase Console → Project Settings → Your Android App

3. **Update iOS URL Scheme**:
   - In `ios/Runner/Info.plist`, replace `YOUR_REVERSED_CLIENT_ID` with your actual reversed client ID from `GoogleService-Info.plist`

### 2.2 iOS Configuration

1. **Add iOS App**:
   - In Firebase Console, click "Add app" → iOS
   - Bundle ID: `com.example.clarityMentalHealth`
   - Download `GoogleService-Info.plist`
   - Replace the placeholder file at `ios/Runner/GoogleService-Info.plist`

2. **Update Bundle ID**:
   - Ensure your iOS bundle ID matches what you entered in Firebase Console

### 2.3 Web Configuration

1. **Add Web App**:
   - In Firebase Console, click "Add app" → Web
   - App nickname: `clarity-web`
   - Copy the Firebase config object

2. **Update Web Config**:
   - Replace the placeholder config in `web/firebase-config.js` with your actual Firebase config

## Step 3: Install Dependencies

Run the following command to install the new Firebase dependencies:

```bash
flutter pub get
```

## Step 4: Deploy Security Rules

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase in your project**:
   ```bash
   firebase init firestore
   ```
   - Select your Firebase project
   - Use the existing `firestore.rules` file
   - Use the existing `firestore.indexes.json` file (create if needed)

4. **Deploy Security Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

## Step 5: Test the Integration

### 5.1 Run the App
```bash
flutter run
```

### 5.2 Test Authentication
1. Try creating a new account with email/password
2. Test Google Sign-In (if configured)
3. Test password reset functionality

### 5.3 Test Data Storage
1. Create journal entries
2. Record mood data
3. Complete assessments
4. Use the chat feature

## Step 6: Production Considerations

### 6.1 Security Rules
The provided `firestore.rules` file includes:
- User-based access control (users can only access their own data)
- Proper validation for all data types
- Denial of unauthorized access

### 6.2 Data Structure
Your Firestore database will have this structure:
```
users/{userId}
├── email: string
├── displayName: string
├── createdAt: timestamp
├── lastLoginAt: timestamp
├── preferences: object
├── journal/{entryId}
│   ├── id: string
│   ├── text: string
│   ├── sentimentScore: number
│   └── timestamp: timestamp
├── moods/{moodId}
│   ├── id: string
│   ├── date: timestamp
│   └── score: number
├── assessments/{assessmentId}
│   ├── id: string
│   ├── kind: string
│   ├── totalScore: number
│   ├── severity: string
│   ├── completedAt: timestamp
│   └── answers: array
└── chats/{sessionId}
    ├── createdAt: timestamp
    ├── lastMessageAt: timestamp
    └── messages/{messageId}
        ├── id: string
        ├── text: string
        ├── isUser: boolean
        ├── timestamp: timestamp
        ├── emotionLabel: string
        ├── emotionScore: number
        └── sessionId: string
```

### 6.3 Offline Support
Firestore offline persistence is enabled, so users can:
- Use the app without internet connection
- Data syncs automatically when connection is restored
- No data loss during offline usage

## Troubleshooting

### Common Issues

1. **Firebase not initialized**:
   - Ensure `FirebaseService.initialize()` is called in `main.dart`
   - Check that all configuration files are properly placed

2. **Authentication not working**:
   - Verify SHA-1 fingerprints are added to Firebase Console
   - Check that Google Sign-In is properly configured
   - Ensure email/password authentication is enabled

3. **Permission denied errors**:
   - Verify security rules are deployed
   - Check that user is properly authenticated
   - Ensure user ID matches the document path

4. **Data not syncing**:
   - Check internet connection
   - Verify Firestore rules allow the operation
   - Check for errors in the console

### Getting Help

- Check Firebase Console for error logs
- Use Flutter's debugging tools
- Review Firebase documentation for specific issues
- Check the app's console output for detailed error messages

## Next Steps

1. **Customize the UI**: Modify the authentication screens to match your brand
2. **Add Analytics**: Implement Firebase Analytics for user behavior tracking
3. **Add Push Notifications**: Use Firebase Cloud Messaging for notifications
4. **Add Crashlytics**: Implement Firebase Crashlytics for crash reporting
5. **Optimize Performance**: Use Firebase Performance Monitoring

## Security Best Practices

1. **Never commit sensitive data**: Keep API keys and configuration files secure
2. **Use environment variables**: For production, use environment-specific configurations
3. **Regular security audits**: Review and update security rules regularly
4. **Monitor usage**: Use Firebase Console to monitor app usage and potential security issues
5. **Data encryption**: Consider additional encryption for sensitive mental health data

Your Firebase integration is now complete! The app will store all user data securely in Firestore with proper authentication and offline support.
