import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_settings.dart';

class NotificationService {
  static const String _prefsKey = 'notification_settings';
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final fln.FlutterLocalNotificationsPlugin _notificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  NotificationSettings _settings = const NotificationSettings();
  NotificationSettings get settings => _settings;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<void> initialize() async {
    await _loadSettings();
    tz.initializeTimeZones();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    final fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    if (_settings.enabled) {
      // Don't await these to avoid blocking startup
      _requestPermissions();
      _scheduleAllNotifications();
    }
  }

  Future<void> _requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    final iOSImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>();

    if (iOSImplementation != null) {
       await iOSImplementation.requestPermissions(
         alert: true,
         badge: true,
         sound: true,
       );
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _settings = NotificationSettings.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
    _notifyListeners();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_settings.toJson());
      await prefs.setString(_prefsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (enabled) {
      await _requestPermissions();
    } else {
      await _notificationsPlugin.cancelAll();
    }
    _settings = _settings.copyWith(enabled: enabled);
    await _saveSettings();
    _notifyListeners();
    if (enabled) await _scheduleAllNotifications();
  }

  Future<void> toggleNotificationType(
    NotificationType type,
    bool enabled,
  ) async {
    final newTypeSettings = Map<NotificationType, bool>.from(
      _settings.typeSettings,
    );
    newTypeSettings[type] = enabled;

    _settings = _settings.copyWith(typeSettings: newTypeSettings);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> updateNotificationFrequency(
    NotificationType type,
    NotificationFrequency frequency,
  ) async {
    final newFrequencies = Map<NotificationType, NotificationFrequency>.from(
      _settings.frequencies,
    );
    newFrequencies[type] = frequency;

    _settings = _settings.copyWith(frequencies: newFrequencies);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> updateNotificationTime(
    NotificationType type,
    TimeOfDay time,
  ) async {
    final newScheduledTimes = Map<NotificationType, TimeOfDay>.from(
      _settings.scheduledTimes,
    );
    newScheduledTimes[type] = time;

    _settings = _settings.copyWith(scheduledTimes: newScheduledTimes);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> updateCustomTimes(
    NotificationType type,
    List<TimeOfDay> times,
  ) async {
    final newCustomTimes = Map<NotificationType, List<TimeOfDay>>.from(
      _settings.customTimes,
    );
    newCustomTimes[type] = times;

    _settings = _settings.copyWith(customTimes: newCustomTimes);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> toggleSound(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    await _saveSettings();
    _notifyListeners();
  }

  Future<void> toggleVibration(bool enabled) async {
    _settings = _settings.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
    _notifyListeners();
  }

  Future<void> toggleShowOnLockScreen(bool enabled) async {
    _settings = _settings.copyWith(showOnLockScreen: enabled);
    await _saveSettings();
    _notifyListeners();
  }

  Future<void> updateSelectedTone(String tone) async {
    _settings = _settings.copyWith(selectedTone: tone);
    await _saveSettings();
    _notifyListeners();
  }

  Future<void> toggleQuietHours(bool enabled) async {
    _settings = _settings.copyWith(quietHoursEnabled: enabled);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> updateQuietHours(TimeOfDay start, TimeOfDay end) async {
    _settings = _settings.copyWith(quietHoursStart: start, quietHoursEnd: end);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> toggleWeekendSchedule(bool enabled) async {
    _settings = _settings.copyWith(weekendDifferentSchedule: enabled);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  Future<void> updateWeekendTimes(
    NotificationType type,
    List<TimeOfDay> times,
  ) async {
    final newWeekendTimes = Map<NotificationType, List<TimeOfDay>>.from(
      _settings.weekendTimes,
    );
    newWeekendTimes[type] = times;

    _settings = _settings.copyWith(weekendTimes: newWeekendTimes);
    await _saveSettings();
    _notifyListeners();
    await _scheduleAllNotifications();
  }

  // --- Scheduling Logic ---

  Future<void> _scheduleAllNotifications() async {
    await _notificationsPlugin.cancelAll();

    if (!_settings.enabled) return;

    for (final type in NotificationType.values) {
      if (!isNotificationTypeEnabled(type)) continue;

      final frequency = getNotificationFrequency(type);
      final time = getNotificationTime(type);
      final messages = _getMessagesForType(type);
      final message = messages.isNotEmpty ? messages[0] : 'Check in with Clarity';

      await _scheduleNotification(
        id: type.index,
        title: type.displayName,
        body: message, 
        time: time,
        frequency: frequency,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required NotificationFrequency frequency,
  }) async {
    final androidDetails = fln.AndroidNotificationDetails(
      'clarity_channel_id',
      'Clarity Notifications',
      channelDescription: 'Mental health reminders',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      playSound: _settings.soundEnabled,
      enableVibration: _settings.vibrationEnabled,
    );

    final iOSDetails = fln.DarwinNotificationDetails(
      presentSound: _settings.soundEnabled,
    );

    final details = fln.NotificationDetails(android: androidDetails, iOS: iOSDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (isInQuietHours(scheduledDate)) {
      return; 
    }

    if (frequency == NotificationFrequency.daily) {
       await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: fln.DateTimeComponents.time,
      );
    } 
  }

  List<String> _getMessagesForType(NotificationType type) {
    switch (type) {
      case NotificationType.moodReminder:
        return getMoodReminderMessages();
      case NotificationType.journalReminder:
        return getJournalReminderMessages();
      case NotificationType.exerciseReminder:
        return getExerciseReminderMessages();
      case NotificationType.assessmentReminder:
        return getAssessmentReminderMessages();
      case NotificationType.checkIn:
        return getCheckInMessages();
      case NotificationType.motivationalQuote:
        return getMotivationalMessages();
    }
  }


  // Helper methods for UI
  bool isNotificationTypeEnabled(NotificationType type) {
    return _settings.enabled && (_settings.typeSettings[type] ?? false);
  }

  NotificationFrequency getNotificationFrequency(NotificationType type) {
    return _settings.frequencies[type] ?? NotificationFrequency.never;
  }

  TimeOfDay getNotificationTime(NotificationType type) {
    return _settings.scheduledTimes[type] ??
        const TimeOfDay(hour: 9, minute: 0);
  }

  List<TimeOfDay> getCustomTimes(NotificationType type) {
    return _settings.customTimes[type] ?? [];
  }

  List<TimeOfDay> getWeekendTimes(NotificationType type) {
    return _settings.weekendTimes[type] ?? [];
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  bool isInQuietHours(dynamic dateTimeOrTimeOfDay) {
    if (!_settings.quietHoursEnabled) return false;
    
    TimeOfDay time;
    if (dateTimeOrTimeOfDay is DateTime) {
       time = TimeOfDay.fromDateTime(dateTimeOrTimeOfDay);  
    } else if (dateTimeOrTimeOfDay is TimeOfDay) {
       time = dateTimeOrTimeOfDay;
    } else if (dateTimeOrTimeOfDay is tz.TZDateTime) {
       time = TimeOfDay(hour: dateTimeOrTimeOfDay.hour, minute: dateTimeOrTimeOfDay.minute);
    } else {
      return false;
    }

    final start = _settings.quietHoursStart;
    final end = _settings.quietHoursEnd;

    if (start.hour > end.hour) {
      return time.hour >= start.hour ||
          time.hour < end.hour ||
          (time.hour == start.hour && time.minute >= start.minute) ||
          (time.hour == end.hour && time.minute < end.minute);
    } else {
      return (time.hour > start.hour ||
              (time.hour == start.hour && time.minute >= start.minute)) &&
          (time.hour < end.hour ||
              (time.hour == end.hour && time.minute < end.minute));
    }
  }

  List<String> getMoodReminderMessages() {
    return [
      "How are you feeling today? 😊",
      "Time for a quick mood check-in! 💙",
      "Let's track your mood - it only takes a moment! ✨",
      "Your mental health matters. How's your mood? 🌟",
      "Quick mood check! How are you doing? 💚",
    ];
  }

  List<String> getJournalReminderMessages() {
    return [
      "Time to reflect and write in your journal 📝",
      "Your thoughts matter - let's journal! ✍️",
      "End your day with some journaling 🌙",
      "Capture your thoughts and feelings today 📖",
      "A few minutes of journaling can make a difference 💭",
    ];
  }

  List<String> getMotivationalMessages() {
    return [
      "You are stronger than you think! 💪",
      "Every small step counts towards your wellbeing 🌱",
      "Today is a new opportunity to take care of yourself 🌅",
      "You've got this! One day at a time 🌟",
      "Your mental health journey is important and valid 💙",
      "Be kind to yourself today 🤗",
      "Progress, not perfection 🌈",
    ];
  }

  List<String> getExerciseReminderMessages() {
    return [
      "Time to move your body! 🏃‍♀️",
      "A little exercise can boost your mood! 💪",
      "Let's get those endorphins flowing! 🌟",
      "Your body and mind will thank you for moving! 🧘‍♀️",
      "Even a short walk can make a difference! 🚶‍♂️",
    ];
  }

  List<String> getAssessmentReminderMessages() {
    return [
      "Time for your wellness check-in! 📊",
      "Let's see how you're progressing! 📈",
      "Your assessment helps track your journey 🎯",
      "Quick wellness assessment available! ✅",
      "Check in with yourself - assessment ready! 🔍",
    ];
  }

  List<String> getCheckInMessages() {
    return [
      "How are you taking care of yourself today? 💚",
      "Remember to be gentle with yourself 🤗",
      "You matter, and your wellbeing is important 💙",
      "Taking a moment to check in with yourself? 🌸",
      "Your mental health is a priority 🌟",
    ];
  }
}
