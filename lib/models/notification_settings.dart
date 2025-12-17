import 'package:flutter/material.dart';

enum NotificationType {
  moodReminder,
  journalReminder,
  exerciseReminder,
  assessmentReminder,
  motivationalQuote,
  checkIn,
}

enum NotificationFrequency {
  never,
  daily,
  twiceDaily,
  threeTimesDaily,
  weekly,
  custom,
}

class NotificationSettings {
  final bool enabled;
  final Map<NotificationType, bool> typeSettings;
  final Map<NotificationType, NotificationFrequency> frequencies;
  final Map<NotificationType, TimeOfDay> scheduledTimes;
  final Map<NotificationType, List<TimeOfDay>> customTimes;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showOnLockScreen;
  final String selectedTone;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final bool weekendDifferentSchedule;
  final Map<NotificationType, List<TimeOfDay>> weekendTimes;

  const NotificationSettings({
    this.enabled = true,
    this.typeSettings = const {
      NotificationType.moodReminder: true,
      NotificationType.journalReminder: true,
      NotificationType.exerciseReminder: false,
      NotificationType.assessmentReminder: true,
      NotificationType.motivationalQuote: true,
      NotificationType.checkIn: false,
    },
    this.frequencies = const {
      NotificationType.moodReminder: NotificationFrequency.daily,
      NotificationType.journalReminder: NotificationFrequency.daily,
      NotificationType.exerciseReminder: NotificationFrequency.never,
      NotificationType.assessmentReminder: NotificationFrequency.weekly,
      NotificationType.motivationalQuote: NotificationFrequency.daily,
      NotificationType.checkIn: NotificationFrequency.never,
    },
    this.scheduledTimes = const {
      NotificationType.moodReminder: TimeOfDay(hour: 9, minute: 0),
      NotificationType.journalReminder: TimeOfDay(hour: 21, minute: 0),
      NotificationType.exerciseReminder: TimeOfDay(hour: 7, minute: 0),
      NotificationType.assessmentReminder: TimeOfDay(hour: 10, minute: 0),
      NotificationType.motivationalQuote: TimeOfDay(hour: 8, minute: 0),
      NotificationType.checkIn: TimeOfDay(hour: 12, minute: 0),
    },
    this.customTimes = const {},
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showOnLockScreen = true,
    this.selectedTone = 'default',
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
    this.weekendDifferentSchedule = false,
    this.weekendTimes = const {},
  });

  NotificationSettings copyWith({
    bool? enabled,
    Map<NotificationType, bool>? typeSettings,
    Map<NotificationType, NotificationFrequency>? frequencies,
    Map<NotificationType, TimeOfDay>? scheduledTimes,
    Map<NotificationType, List<TimeOfDay>>? customTimes,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showOnLockScreen,
    String? selectedTone,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? weekendDifferentSchedule,
    Map<NotificationType, List<TimeOfDay>>? weekendTimes,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      typeSettings: typeSettings ?? this.typeSettings,
      frequencies: frequencies ?? this.frequencies,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      customTimes: customTimes ?? this.customTimes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      selectedTone: selectedTone ?? this.selectedTone,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      weekendDifferentSchedule:
          weekendDifferentSchedule ?? this.weekendDifferentSchedule,
      weekendTimes: weekendTimes ?? this.weekendTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'typeSettings': typeSettings.map((k, v) => MapEntry(k.name, v)),
      'frequencies': frequencies.map((k, v) => MapEntry(k.name, v.name)),
      'scheduledTimes': scheduledTimes.map(
        (k, v) => MapEntry(k.name, {'hour': v.hour, 'minute': v.minute}),
      ),
      'customTimes': customTimes.map(
        (k, v) => MapEntry(
          k.name,
          v.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
        ),
      ),
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showOnLockScreen': showOnLockScreen,
      'selectedTone': selectedTone,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': {
        'hour': quietHoursStart.hour,
        'minute': quietHoursStart.minute,
      },
      'quietHoursEnd': {
        'hour': quietHoursEnd.hour,
        'minute': quietHoursEnd.minute,
      },
      'weekendDifferentSchedule': weekendDifferentSchedule,
      'weekendTimes': weekendTimes.map(
        (k, v) => MapEntry(
          k.name,
          v.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
        ),
      ),
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      typeSettings:
          (json['typeSettings'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              NotificationType.values.firstWhere((e) => e.name == k),
              v as bool,
            ),
          ) ??
          const {
            NotificationType.moodReminder: true,
            NotificationType.journalReminder: true,
            NotificationType.exerciseReminder: false,
            NotificationType.assessmentReminder: true,
            NotificationType.motivationalQuote: true,
            NotificationType.checkIn: false,
          },
      frequencies:
          (json['frequencies'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              NotificationType.values.firstWhere((e) => e.name == k),
              NotificationFrequency.values.firstWhere((e) => e.name == v),
            ),
          ) ??
          const {
            NotificationType.moodReminder: NotificationFrequency.daily,
            NotificationType.journalReminder: NotificationFrequency.daily,
            NotificationType.exerciseReminder: NotificationFrequency.never,
            NotificationType.assessmentReminder: NotificationFrequency.weekly,
            NotificationType.motivationalQuote: NotificationFrequency.daily,
            NotificationType.checkIn: NotificationFrequency.never,
          },
      scheduledTimes:
          (json['scheduledTimes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              NotificationType.values.firstWhere((e) => e.name == k),
              TimeOfDay(hour: v['hour'], minute: v['minute']),
            ),
          ) ??
          const {
            NotificationType.moodReminder: TimeOfDay(hour: 9, minute: 0),
            NotificationType.journalReminder: TimeOfDay(hour: 21, minute: 0),
            NotificationType.exerciseReminder: TimeOfDay(hour: 7, minute: 0),
            NotificationType.assessmentReminder: TimeOfDay(hour: 10, minute: 0),
            NotificationType.motivationalQuote: TimeOfDay(hour: 8, minute: 0),
            NotificationType.checkIn: TimeOfDay(hour: 12, minute: 0),
          },
      customTimes:
          (json['customTimes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              NotificationType.values.firstWhere((e) => e.name == k),
              (v as List)
                  .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
                  .toList(),
            ),
          ) ??
          const {},
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      showOnLockScreen: json['showOnLockScreen'] ?? true,
      selectedTone: json['selectedTone'] ?? 'default',
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      quietHoursStart: json['quietHoursStart'] != null
          ? TimeOfDay(
              hour: json['quietHoursStart']['hour'],
              minute: json['quietHoursStart']['minute'],
            )
          : const TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: json['quietHoursEnd'] != null
          ? TimeOfDay(
              hour: json['quietHoursEnd']['hour'],
              minute: json['quietHoursEnd']['minute'],
            )
          : const TimeOfDay(hour: 7, minute: 0),
      weekendDifferentSchedule: json['weekendDifferentSchedule'] ?? false,
      weekendTimes:
          (json['weekendTimes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              NotificationType.values.firstWhere((e) => e.name == k),
              (v as List)
                  .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
                  .toList(),
            ),
          ) ??
          const {},
    );
  }
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.moodReminder:
        return 'Mood Check-ins';
      case NotificationType.journalReminder:
        return 'Journal Reminders';
      case NotificationType.exerciseReminder:
        return 'Exercise Reminders';
      case NotificationType.assessmentReminder:
        return 'Assessment Reminders';
      case NotificationType.motivationalQuote:
        return 'Daily Motivation';
      case NotificationType.checkIn:
        return 'Wellness Check-ins';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.moodReminder:
        return 'Get reminded to track your mood';
      case NotificationType.journalReminder:
        return 'Remember to write in your journal';
      case NotificationType.exerciseReminder:
        return 'Stay active with exercise reminders';
      case NotificationType.assessmentReminder:
        return 'Complete your wellness assessments';
      case NotificationType.motivationalQuote:
        return 'Receive daily motivational quotes';
      case NotificationType.checkIn:
        return 'Regular wellness check-ins';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.moodReminder:
        return Icons.mood_rounded;
      case NotificationType.journalReminder:
        return Icons.book_rounded;
      case NotificationType.exerciseReminder:
        return Icons.fitness_center_rounded;
      case NotificationType.assessmentReminder:
        return Icons.assignment_rounded;
      case NotificationType.motivationalQuote:
        return Icons.format_quote_rounded;
      case NotificationType.checkIn:
        return Icons.favorite_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.moodReminder:
        return Colors.blue;
      case NotificationType.journalReminder:
        return Colors.green;
      case NotificationType.exerciseReminder:
        return Colors.orange;
      case NotificationType.assessmentReminder:
        return Colors.purple;
      case NotificationType.motivationalQuote:
        return Colors.pink;
      case NotificationType.checkIn:
        return Colors.red;
    }
  }
}

extension NotificationFrequencyExtension on NotificationFrequency {
  String get displayName {
    switch (this) {
      case NotificationFrequency.never:
        return 'Never';
      case NotificationFrequency.daily:
        return 'Daily';
      case NotificationFrequency.twiceDaily:
        return 'Twice Daily';
      case NotificationFrequency.threeTimesDaily:
        return 'Three Times Daily';
      case NotificationFrequency.weekly:
        return 'Weekly';
      case NotificationFrequency.custom:
        return 'Custom';
    }
  }
}
