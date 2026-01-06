import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

enum AppColorScheme { blue, purple, green, orange, pink }

class ThemeSettings {
  final AppThemeMode themeMode;
  final AppColorScheme colorScheme;
  final bool useSystemAccentColor;
  final double textScale;

  const ThemeSettings({
    this.themeMode = AppThemeMode.light,
    this.colorScheme = AppColorScheme.blue,
    this.useSystemAccentColor = false,
    this.textScale = 1.0,
  });

  ThemeSettings copyWith({
    AppThemeMode? themeMode,
    AppColorScheme? colorScheme,
    bool? useSystemAccentColor,
    double? textScale,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
      useSystemAccentColor: useSystemAccentColor ?? this.useSystemAccentColor,
      textScale: textScale ?? this.textScale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'colorScheme': colorScheme.name,
      'useSystemAccentColor': useSystemAccentColor,
      'textScale': textScale,
    };
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.light,
      ),
      colorScheme: AppColorScheme.values.firstWhere(
        (e) => e.name == json['colorScheme'],
        orElse: () => AppColorScheme.blue,
      ),
      useSystemAccentColor: json['useSystemAccentColor'] ?? false,
      textScale: (json['textScale'] ?? 1.0).toDouble(),
    );
  }
}

class ThemeNotifier extends Notifier<ThemeSettings> {
  static const String _prefsKey = 'theme_settings_v2';

  @override
  ThemeSettings build() {
    _loadSettings();
    return const ThemeSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null) {
        final json = Map<String, dynamic>.from(
          Uri.splitQueryString(jsonString),
        );
        // Convert string values back to proper types
        final settings = ThemeSettings(
          themeMode: AppThemeMode.values.firstWhere(
            (e) => e.name == json['themeMode'],
            orElse: () => AppThemeMode.light,
          ),
          colorScheme: AppColorScheme.values.firstWhere(
            (e) => e.name == json['colorScheme'],
            orElse: () => AppColorScheme.blue,
          ),
          useSystemAccentColor: json['useSystemAccentColor'] == 'true',
          textScale: double.tryParse(json['textScale'] ?? '1.0') ?? 1.0,
        );
        state = settings;
      }
    } catch (e) {
      // If loading fails, keep default settings
    }
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  Future<void> updateColorScheme(AppColorScheme colorScheme) async {
    state = state.copyWith(colorScheme: colorScheme);
    await _saveSettings();
  }

  Future<void> updateUseSystemAccentColor(bool useSystem) async {
    state = state.copyWith(useSystemAccentColor: useSystem);
    await _saveSettings();
  }

  Future<void> updateTextScale(double scale) async {
    state = state.copyWith(textScale: scale);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = {
        'themeMode': state.themeMode.name,
        'colorScheme': state.colorScheme.name,
        'useSystemAccentColor': state.useSystemAccentColor.toString(),
        'textScale': state.textScale.toString(),
      };
      final queryString = Uri(queryParameters: json).query;
      await prefs.setString(_prefsKey, queryString);
    } catch (e) {
      // Handle save error
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(
  ThemeNotifier.new,
);

// Helper to get ThemeData based on settings
extension ThemeSettingsExtension on ThemeSettings {
  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ColorScheme get lightColorScheme {
    switch (colorScheme) {
      case AppColorScheme.blue:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        );
      case AppColorScheme.purple:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          brightness: Brightness.light,
        );
      case AppColorScheme.green:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        );
      case AppColorScheme.orange:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9800),
          brightness: Brightness.light,
        );
      case AppColorScheme.pink:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        );
    }
  }

  ColorScheme get darkColorScheme {
    switch (colorScheme) {
      case AppColorScheme.blue:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.dark,
        );
      case AppColorScheme.purple:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          brightness: Brightness.dark,
        );
      case AppColorScheme.green:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        );
      case AppColorScheme.orange:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9800),
          brightness: Brightness.dark,
        );
      case AppColorScheme.pink:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.dark,
        );
    }
  }
}
