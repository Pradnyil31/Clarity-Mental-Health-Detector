import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/root_shell.dart';
import 'screens/assessment_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/cbt_screen.dart';
import 'screens/profile_screen.dart';
import 'models/assessment.dart';

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Updated vibrant seed for a friendly, trustworthy palette
    final seed = const Color(0xFF5B8CFF);

    // Light
    final lightScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
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

    // Dark
    final darkScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
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

    return MaterialApp(
      title: 'Clarity',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: light,
      darkTheme: dark,
      home: RootShell(bodyBuilder: (context) => const HomeScreen()),
      builder: (context, child) {
        // Wrap pages to ensure a back button appears when possible
        return Navigator.canPop(context)
            ? Theme(
                data: Theme.of(context),
                child: PopScope(
                  canPop: true,
                  onPopInvoked: (_) {},
                  child: child ?? const SizedBox.shrink(),
                ),
              )
            : child ?? const SizedBox.shrink();
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          return MaterialPageRoute(builder: (_) => const ChatScreen());
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
        if (settings.name == '/journal') {
          return MaterialPageRoute(builder: (_) => const JournalScreen());
        }
        if (settings.name == '/mood') {
          return MaterialPageRoute(builder: (_) => const MoodTrackerScreen());
        }
        if (settings.name == '/insights') {
          return MaterialPageRoute(builder: (_) => const InsightsScreen());
        }
        if (settings.name == '/cbt') {
          return MaterialPageRoute(builder: (_) => const CbtScreen());
        }
        if (settings.name == '/profile') {
          return MaterialPageRoute(builder: (_) => const ProfileScreen());
        }
        if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder: (_) => const _PlaceholderScreen(title: 'Settings'),
          );
        }
        if (settings.name == '/about') {
          return MaterialPageRoute(
            builder: (_) => const _PlaceholderScreen(title: 'About'),
          );
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
