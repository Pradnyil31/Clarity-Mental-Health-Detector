import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isFirstLaunchSync => _prefs?.getBool(_keyFirstLaunch) ?? true;
  static bool get hasCompletedOnboardingSync => _prefs?.getBool(_keyOnboardingComplete) ?? false;

  static Future<bool> isFirstLaunch() async {
    if (_prefs == null) await initialize();
    return _prefs?.getBool(_keyFirstLaunch) ?? true;
  }

  static Future<void> markNotFirstLaunch() async {
    if (_prefs == null) await initialize();
    await _prefs?.setBool(_keyFirstLaunch, false);
  }

  static Future<bool> hasCompletedOnboarding() async {
    if (_prefs == null) await initialize();
    return _prefs?.getBool(_keyOnboardingComplete) ?? false;
  }

  // Debug only
  static Future<void> reset() async {
    if (_prefs == null) await initialize();
    await _prefs?.clear();
  }

  static Future<void> markOnboardingComplete() async {
    if (_prefs == null) await initialize();
    await _prefs?.setBool(_keyOnboardingComplete, true);
  }

  static Future<void> resetOnboarding() async {
    if (_prefs == null) await initialize();
    await _prefs?.setBool(_keyOnboardingComplete, false);
    await _prefs?.setBool(_keyFirstLaunch, true);
  }
}
