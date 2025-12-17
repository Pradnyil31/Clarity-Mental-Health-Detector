import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/enhanced_chat_screen.dart';
import 'screens/root_shell.dart';
import 'screens/assessment_screen.dart';
import 'screens/happiness_screen.dart';
import 'screens/self_esteem_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/cbt_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/data_management_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/safety_plan_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/about_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_carousel_screen.dart';
import 'screens/onboarding/personalization_screen.dart';
import 'screens/onboarding/assessment_suggestion_screen.dart';
import 'screens/onboarding/first_breathing_screen.dart';
import 'screens/onboarding/onboarding_completion_screen.dart';

import 'models/assessment.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'state/user_state.dart';
import 'state/theme_state.dart';

class ClarityApp extends ConsumerWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme settings
    final themeSettings = ref.watch(themeProvider);

    // Get color schemes from theme settings
    final lightScheme = themeSettings.lightColorScheme;
    final darkScheme = themeSettings.darkColorScheme;

    // Build light theme
    final lightBase = ThemeData(colorScheme: lightScheme, useMaterial3: true);
    final light = lightBase.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: lightScheme.surface,
        foregroundColor: lightScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lightScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: lightBase.textTheme.copyWith(
        headlineSmall: lightBase.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleMedium: lightBase.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),
    );

    // Build dark theme
    final darkBase = ThemeData(colorScheme: darkScheme, useMaterial3: true);
    final dark = darkBase.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: darkBase.textTheme.copyWith(
        headlineSmall: darkBase.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleMedium: darkBase.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkScheme.primary,
        foregroundColor: darkScheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),
    );

    // Watch authentication state and user state
    final authState = ref.watch(authStateProvider);
    final userState = ref.watch(userStateProvider);

    return MaterialApp(
      title: 'Clarity',
      debugShowCheckedModeBanner: false,
      themeMode: themeSettings.materialThemeMode,
      theme: light,
      darkTheme: dark,
      home: authState.when(
        data: (user) {
          if (user == null) {
            // Check if it's the first launch
            if (OnboardingService.isFirstLaunchSync) {
              return const SplashScreen();
            }
            return const WelcomeScreen();
          }

          // User is authenticated, check if profile is loaded
          if (userState.isLoading) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading your profile...'),
                  ],
                ),
              ),
            );
          }

          if (userState.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${userState.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(userStateProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // User authenticated and profile loaded
          // Check if onboarding is complete
          final profile = userState.profile;
          if (profile != null && !profile.hasCompletedOnboarding) {
            // Onboarding not complete - redirect to personalization
            return const PersonalizationScreen();
          }

          return RootShell(
            currentIndex: 0,
            bodyBuilder: (context) => const HomeScreen(),
          );
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(authStateProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      builder: (context, child) {
        // Apply text scaling from theme settings
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(themeSettings.textScale)),
          child: Navigator.canPop(context)
              ? Theme(
                  data: Theme.of(context),
                  child: PopScope(
                    canPop: true,
                    onPopInvokedWithResult: (didPop, result) {},
                    child: child ?? const SizedBox.shrink(),
                  ),
                )
              : child ?? const SizedBox.shrink(),
        );
      },
      onGenerateRoute: (settings) {

        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        if (settings.name == '/signup') {
          return MaterialPageRoute(builder: (_) => const SignupScreen());
        }
        if (settings.name == '/chat') {
          return MaterialPageRoute(builder: (_) => const ChatScreen());
        }
        if (settings.name == '/enhanced-chat') {
          return MaterialPageRoute(builder: (_) => const EnhancedChatScreen());
        }
        if (settings.name == '/phq9') {
          return MaterialPageRoute(
            builder: (_) => const AssessmentScreen(kind: AssessmentKind.phq9),
          );
        }
        if (settings.name == '/gad7') {
          return MaterialPageRoute(
            builder: (_) => const AssessmentScreen(kind: AssessmentKind.gad7),
          );
        }
        if (settings.name == '/happiness') {
          return MaterialPageRoute(builder: (_) => const HappinessScreen());
        }
        if (settings.name == '/self-esteem') {
          return MaterialPageRoute(builder: (_) => const SelfEsteemScreen());
        }
        if (settings.name == '/pss10') {
          return MaterialPageRoute(
            builder: (_) => const AssessmentScreen(kind: AssessmentKind.pss10),
          );
        }
        if (settings.name == '/sleep') {
          return MaterialPageRoute(
            builder: (_) => const AssessmentScreen(kind: AssessmentKind.sleep),
          );
        }
        if (settings.name == '/journal') {
          return MaterialPageRoute(
            builder: (_) => RootShell(
              currentIndex: 3,
              bodyBuilder: (context) => const JournalScreen(),
            ),
          );
        }
        if (settings.name == '/mood') {
          return MaterialPageRoute(builder: (_) => const MoodTrackerScreen());
        }
        if (settings.name == '/insights') {
          return MaterialPageRoute(
            builder: (_) => RootShell(
              currentIndex: 1,
              bodyBuilder: (context) => const InsightsScreen(),
            ),
          );
        }
        if (settings.name == '/cbt') {
          return MaterialPageRoute(builder: (_) => const CbtScreen());
        }
        if (settings.name == '/profile') {
          return MaterialPageRoute(
            builder: (_) => RootShell(
              currentIndex: 4,
              bodyBuilder: (context) => const ProfileScreen(),
            ),
          );
        }
        if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder: (_) => const _PlaceholderScreen(title: 'Settings'),
          );
        }
        if (settings.name == '/about') {
          return MaterialPageRoute(builder: (_) => const AboutScreen());
        }
        if (settings.name == '/data-management') {
          return MaterialPageRoute(
            builder: (_) => const DataManagementScreen(),
          );
        }
        if (settings.name == '/help') {
          return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
        }
        if (settings.name == '/breathing') {
          return MaterialPageRoute(builder: (_) => const BreathingScreen());
        }
        if (settings.name == '/exercise') {
          return MaterialPageRoute(builder: (_) => const ExerciseScreen());
        }
        if (settings.name == '/safety-plan') {
          return MaterialPageRoute(builder: (_) => const SafetyPlanScreen());
        }
        if (settings.name == '/splash') {
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
        if (settings.name == '/onboarding-carousel') {
          return MaterialPageRoute(builder: (_) => const OnboardingCarouselScreen());
        }
        if (settings.name == '/personalization') {
          return MaterialPageRoute(builder: (_) => const PersonalizationScreen());
        }
        if (settings.name == '/assessment-suggestion') {
          return MaterialPageRoute(builder: (_) => const AssessmentSuggestionScreen());
        }
        if (settings.name == '/first-breathing') {
          return MaterialPageRoute(builder: (_) => const FirstBreathingScreen());
        }
        if (settings.name == '/onboarding-complete') {
          return MaterialPageRoute(builder: (_) => const OnboardingCompletionScreen());
        }
        return null;
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title screen coming soon')),
    );
  }
}
