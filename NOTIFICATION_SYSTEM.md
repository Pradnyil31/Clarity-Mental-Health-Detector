# Notification System Documentation

## Overview

The Clarity Mental Health app now includes a comprehensive notification system designed to support users' mental wellness journey through gentle reminders and motivational messages.

## Features

### 🔔 Notification Types

1. **Mood Check-ins** - Reminders to track daily mood
2. **Journal Reminders** - Prompts to write in the journal
3. **Exercise Reminders** - Encouragement to stay active
4. **Assessment Reminders** - Prompts to complete wellness assessments
5. **Daily Motivation** - Inspirational quotes and messages
6. **Wellness Check-ins** - General mental health check-ins

### ⚙️ Customization Options

- **Master Toggle** - Enable/disable all notifications
- **Individual Type Control** - Toggle specific notification types
- **Frequency Settings** - Never, Daily, Twice Daily, Three Times Daily, Weekly, Custom
- **Time Scheduling** - Set specific times for each notification type
- **Sound & Vibration** - Control notification sounds and vibration
- **Lock Screen Display** - Choose whether to show on lock screen
- **Quiet Hours** - Set periods when notifications are disabled
- **Weekend Schedule** - Different notification times for weekends

### 🎨 Beautiful UI Design

- **Animated Interface** - Smooth transitions and fade effects
- **Color-coded Types** - Each notification type has its own color theme
- **Modern Cards** - Clean, card-based design with shadows and gradients
- **Responsive Layout** - Adapts to different screen sizes
- **Dark Mode Support** - Fully compatible with app's theme system

## Architecture

### Models
- `NotificationSettings` - Main settings model with all configuration options
- `NotificationType` - Enum defining different types of notifications
- `NotificationFrequency` - Enum for frequency options

### Services
- `NotificationService` - Core service handling settings persistence and management
- Integrates with `SharedPreferences` for data persistence
- Provides helper methods for time formatting and message generation

### State Management
- `NotificationNotifier` - Riverpod notifier for reactive state management
- Multiple providers for specific notification data
- Automatic UI updates when settings change

### UI Components
- `NotificationSettingsScreen` - Main settings screen with full configuration
- `NotificationStatusWidget` - Compact status display widget
- `NotificationQuickToggle` - Quick toggle buttons for notification types
- `NotificationReminder` - In-app reminder cards

## Usage

### Accessing Settings
Users can access notification settings through:
1. Profile Screen → Notifications
2. Direct navigation to `NotificationSettingsScreen`

### Integration Examples

#### Home Screen Integration
```dart
NotificationReminder(
  type: NotificationType.moodReminder,
  customMessage: "How are you feeling today?",
  onAction: () => Navigator.pushNamed('/mood'),
)
```

#### Quick Status Display
```dart
NotificationStatusWidget(
  showDetails: true,
  onTap: () => Navigator.push(NotificationSettingsScreen()),
)
```

#### Individual Type Toggle
```dart
NotificationQuickToggle(
  type: NotificationType.journalReminder,
  compact: true,
)
```

## Data Persistence

Settings are automatically saved to device storage using `SharedPreferences`:
- JSON serialization for complex data structures
- Automatic loading on app startup
- Reactive updates across the app

## Customization Messages

The system includes pre-defined message sets for each notification type:
- Mood reminders: Encouraging check-in messages
- Journal prompts: Reflective writing encouragement
- Exercise reminders: Activity motivation
- Assessment prompts: Progress tracking encouragement
- Motivational quotes: Daily inspiration
- Check-ins: General wellness support

## Future Enhancements

Potential improvements for future versions:
- Push notification integration
- Smart scheduling based on user behavior
- Personalized message customization
- Integration with device notification settings
- Analytics for notification effectiveness
- Snooze and reschedule options

## Technical Notes

- Built with Flutter and Riverpod for state management
- Follows Material Design 3 principles
- Fully accessible with proper semantic labels
- Optimized for performance with minimal rebuilds
- Compatible with existing app architecture

## Files Structure

```
lib/
├── models/
│   └── notification_settings.dart
├── services/
│   └── notification_service.dart
├── state/
│   └── notification_state.dart
├── screens/
│   └── notification_settings_screen.dart
└── widgets/
    └── notification_status_widget.dart
```

The notification system is designed to be non-intrusive while providing valuable support for users' mental wellness journey. All settings are user-controlled with sensible defaults that can be easily customized to individual preferences.