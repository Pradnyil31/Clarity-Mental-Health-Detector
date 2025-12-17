import 'package:flutter/material.dart';

/// Centralized color constants for the Clarity app.
/// Eliminates hardcoded colors and ensures consistent theming.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary palette
  static const primary = Color(0xFF667eea);
  static const primaryLight = Color(0xFF8e9af5);
  static const primaryDark = Color(0xFF4d5dc4);
  
  static const secondary = Color(0xFF764ba2);
  static const secondaryLight = Color(0xFF9d6bc8);
  static const secondaryDark = Color(0xFF5a3680);
  
  // Semantic colors
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFF66BB6A);
  static const warning = Color(0xFFFF9F43);
  static const danger = Color(0xFFE17055);
  static const info = Color(0xFF2196F3);
  static const infoLight = Color(0xFF42A5F5);
  
  // Mood/emotion colors (0-100 scale, higher = better)
  static const moodExcellent = Color(0xFF4CAF50);  // 80-100
  static const moodGood = Color(0xFF8BC34A);       // 60-79
  static const moodOkay = Color(0xFFFFEB3B);       // 40-59
  static const moodPoor = Color(0xFFFF9800);       // 20-39
  static const moodSevere = Color(0xFFF44336);     // 0-19
  
  // Feature-specific colors (from home_screen.dart)
  static const moodTracking = Color(0xFF6C5CE7);
  static const panicRelief = Color(0xFF00B894);
  static const safetyPlan = Color(0xFFE17055);
  static const journaling = Color(0xFF0984E3);
  static const exercise = Color(0xFFFD79A8);
  static const insights = Color(0xFF636E72);
  static const cbt = Color(0xFF2D3436);
  
  // Assessment colors
  static const phq9 = Color(0xFFFF6B6B);           // Depression - Red
  static const gad7 = Color(0xFF4ECDC4);           // Anxiety - Teal
  static const happiness = Color(0xFFFECA57);      // Happiness - Yellow
  static const selfEsteem = Color(0xFF54A0FF);     // Self-esteem - Blue
  static const pss10 = Color(0xFFFF9F43);          // Stress - Orange
  static const sleep = Color(0xFF5F27CD);          // Sleep - Purple
  
  // Gradient definitions for common use cases
  static const List<Color> primaryGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];
  
  static const List<Color> primaryGradientExtended = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
    Color(0xFFf093fb),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF66BB6A),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFFF9F43),
    Color(0xFFFF7043),
  ];
  
  static const List<Color> infoGradient = [
    Color(0xFF2196F3),
    Color(0xFF42A5F5),
  ];
  
  static const List<Color> purpleGradient = [
    Color(0xFF9C27B0),
    Color(0xFFAB47BC),
  ];
  
  // Dark mode specific colors
  static const darkSurface = Color(0xFF0F0F0F);
  static const darkSurfaceVariant = Color(0xFF1A1A2E);
  static const darkBackground = Color(0xFF16213E);
  static const darkBackgroundAlt = Color(0xFF0F3460);
  
  // Light mode specific colors
  static const lightSurface = Color(0xFFFAFAFA);
  static const lightSurfaceVariant = Color(0xFFF5F7FA);
  static const lightBackground = Color(0xFFFFFFFF);
  
  // Utility method to get mood color by score (0-100)
  static Color getMoodColor(int score) {
    if (score >= 80) return moodExcellent;
    if (score >= 60) return moodGood;
    if (score >= 40) return moodOkay;
    if (score >= 20) return moodPoor;
    return moodSevere;
  }
  
  // Utility method to get gradient for mood score
  static List<Color> getMoodGradient(int score) {
    final color = getMoodColor(score);
    return [
      color,
      color.withOpacity(0.8),
    ];
  }
}
