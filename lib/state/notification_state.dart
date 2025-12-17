import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

class NotificationNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    // Initialize with current settings from service
    final service = NotificationService.instance;

    // Listen to service changes
    service.addListener(_onServiceChanged);

    return service.settings;
  }

  void _onServiceChanged() {
    state = NotificationService.instance.settings;
  }

  Future<void> toggleNotifications(bool enabled) async {
    await NotificationService.instance.toggleNotifications(enabled);
  }

  Future<void> toggleNotificationType(
    NotificationType type,
    bool enabled,
  ) async {
    await NotificationService.instance.toggleNotificationType(type, enabled);
  }

  Future<void> updateNotificationFrequency(
    NotificationType type,
    NotificationFrequency frequency,
  ) async {
    await NotificationService.instance.updateNotificationFrequency(
      type,
      frequency,
    );
  }

  Future<void> updateNotificationTime(
    NotificationType type,
    TimeOfDay time,
  ) async {
    await NotificationService.instance.updateNotificationTime(type, time);
  }

  Future<void> updateCustomTimes(
    NotificationType type,
    List<TimeOfDay> times,
  ) async {
    await NotificationService.instance.updateCustomTimes(type, times);
  }

  Future<void> toggleSound(bool enabled) async {
    await NotificationService.instance.toggleSound(enabled);
  }

  Future<void> toggleVibration(bool enabled) async {
    await NotificationService.instance.toggleVibration(enabled);
  }

  Future<void> toggleShowOnLockScreen(bool enabled) async {
    await NotificationService.instance.toggleShowOnLockScreen(enabled);
  }

  Future<void> updateSelectedTone(String tone) async {
    await NotificationService.instance.updateSelectedTone(tone);
  }

  Future<void> toggleQuietHours(bool enabled) async {
    await NotificationService.instance.toggleQuietHours(enabled);
  }

  Future<void> updateQuietHours(TimeOfDay start, TimeOfDay end) async {
    await NotificationService.instance.updateQuietHours(start, end);
  }

  Future<void> toggleWeekendSchedule(bool enabled) async {
    await NotificationService.instance.toggleWeekendSchedule(enabled);
  }

  Future<void> updateWeekendTimes(
    NotificationType type,
    List<TimeOfDay> times,
  ) async {
    await NotificationService.instance.updateWeekendTimes(type, times);
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationSettings>(
      NotificationNotifier.new,
    );

// Helper providers for specific notification data
final notificationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).enabled;
});

final moodReminderEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationProvider);
  return settings.enabled &&
      (settings.typeSettings[NotificationType.moodReminder] ?? false);
});

final journalReminderEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationProvider);
  return settings.enabled &&
      (settings.typeSettings[NotificationType.journalReminder] ?? false);
});

final exerciseReminderEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationProvider);
  return settings.enabled &&
      (settings.typeSettings[NotificationType.exerciseReminder] ?? false);
});

final assessmentReminderEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationProvider);
  return settings.enabled &&
      (settings.typeSettings[NotificationType.assessmentReminder] ?? false);
});

final motivationalQuoteEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationProvider);
  return settings.enabled &&
      (settings.typeSettings[NotificationType.motivationalQuote] ?? false);
});

final checkInEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationProvider);
  return settings.enabled &&
      (settings.typeSettings[NotificationType.checkIn] ?? false);
});

// Provider for getting notification summary text
final notificationSummaryProvider = Provider<String>((ref) {
  final settings = ref.watch(notificationProvider);

  if (!settings.enabled) {
    return 'All notifications disabled';
  }

  final enabledTypes = settings.typeSettings.entries
      .where((entry) => entry.value)
      .length;

  if (enabledTypes == 0) {
    return 'No notification types enabled';
  } else if (enabledTypes == 1) {
    return '1 notification type enabled';
  } else {
    return '$enabledTypes notification types enabled';
  }
});
