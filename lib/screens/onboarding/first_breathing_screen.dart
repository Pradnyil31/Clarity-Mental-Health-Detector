import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/onboarding_service.dart';
import '../../state/user_state.dart';

class FirstBreathingScreen extends ConsumerStatefulWidget {
  const FirstBreathingScreen({super.key});

  @override
  ConsumerState<FirstBreathingScreen> createState() =>
      _FirstBreathingScreenState();
}

class _FirstBreathingScreenState extends ConsumerState<FirstBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes
  bool _isPlaying = false;
  String _currentPhase = 'Get Ready';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Base breathing cycle
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
        setState(() => _currentPhase = 'Breathe Out');
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
        setState(() => _currentPhase = 'Breathe In');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isPlaying = true;
      _currentPhase = 'Breathe In';
    });
    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _finishSession();
      }
    });
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _isPlaying = false;
      _currentPhase = 'Great Job!';
    });

    // Mark onboarding as complete in shared prefs
    await OnboardingService.markOnboardingComplete();
    
    // Update user profile in Firestore
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final notifier = ref.read(userStateProvider.notifier);
      await notifier.updateProfile(
        currentUser.copyWith(hasCompletedOnboarding: true),
      );
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding-complete');
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.3),
                  scheme.surface,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                if (!_isPlaying) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          'Just One Breath',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Before we begin, let\'s take 2 minutes to center yourself. Follow the circle.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],

                // Breathing Circle
                Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: 200 * _scaleAnimation.value,
                        height: 200 * _scaleAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary.withValues(alpha: 0.2),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 150 * _scaleAnimation.value,
                            height: 150 * _scaleAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.primary.withValues(alpha: 0.4),
                            ),
                            child: Center(
                              child: Text(
                                _currentPhase,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 48),

                // Timer or Start Button
                if (_isPlaying)
                  Text(
                    _formatTime(_secondsRemaining),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  )
                else
                  ElevatedButton(
                    onPressed: _startBreathing,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Start'),
                  ),
                
                // Allow skipping if needed
                if (_isPlaying)
                   Padding(
                     padding: const EdgeInsets.only(top: 24),
                     child: TextButton(
                      onPressed: _finishSession,
                      child: const Text('Skip'),
                     ),
                   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
