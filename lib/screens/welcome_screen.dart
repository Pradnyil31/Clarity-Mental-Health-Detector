import 'package:flutter/material.dart';
import '../services/onboarding_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E), // Deep dark blue
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFE3F2FD), // Very light blue
                    const Color(0xFFE1F5FE), // Light blue
                    const Color(0xFFF3E5F5), // Light purple hint
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Animated Logo Container
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          size: 80,
                          color: scheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                // Title and Tagline
                FadeTransition(
                  opacity: const AlwaysStoppedAnimation(1.0),
                  child: Column(
                    children: [
                      Text(
                        'Clarity',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your daily mental health companion',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track moods, journal thoughts, and\nbuild better habits together.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      // Navigate to Carousel first, then Signup
                      onPressed: () => Navigator.of(context).pushNamed('/onboarding-carousel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(
                          color: scheme.primary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'I have an account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                // Debug Reset Button
                Center(
                  child: TextButton(
                    onPressed: () async {
                      // Reset to first launch
                      await OnboardingService.reset();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Onboarding Reset! Restarting app...')),
                        );
                        // Delay to show snackbar
                        await Future.delayed(const Duration(seconds: 1));
                        
                        // Navigate to Splash to restart flow
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
                        }
                      }
                    }, 
                    child: const Text(
                      'Debug: Reset Onboarding',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
