import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/onboarding_state.dart';
import '../../models/assessment.dart';
import '../../widgets/onboarding_progress_bar.dart';
import '../../screens/assessment_result_screen.dart';

class AssessmentSuggestionScreen extends ConsumerWidget {
  const AssessmentSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine the best assessment based on goals
    final suggestion = _determineAssessment(state.selectedGoals);
    final assessmentKind = suggestion.key;
    final reason = suggestion.value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: OnboardingProgressBar(
                currentStep: 3, // Final step
                totalSteps: 3, 
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.assignment_ind_rounded,
                      size: 64,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recommended for You',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on your goals, we recommend starting with a quick check-in.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 48),

                    // Suggestion Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            assessmentKind.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            reason,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 16, color: scheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Takes about 2-3 mins',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startAssessment(context, assessmentKind),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                      child: const Text('Start Assessment'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _skip(context),
                    child: Text(
                      'Skip for now',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MapEntry<AssessmentKind, String> _determineAssessment(List<String> goals) {
    // Priority-based matching
    if (goals.contains('Depression')) {
      return const MapEntry(
        AssessmentKind.phq9,
        'Since you mentioned feeling down, the PHQ-9 helps understand your mood better.',
      );
    }
    if (goals.contains('Anxiety') || goals.contains('Stress Management')) {
      return const MapEntry(
        AssessmentKind.gad7,
        'To help with anxiety, the GAD-7 assessment is a great starting point.',
      );
    }
    if (goals.contains('Sleep Issues')) {
      return const MapEntry(
        AssessmentKind.sleep,
        'Getting better sleep starts with understanding your habits.',
      );
    }
    if (goals.contains('Productivity') || goals.contains('Self-Esteem')) {
      return const MapEntry(
        AssessmentKind.selfEsteem,
        'Understanding your self-perception can unlock your potential.',
      );
    }
    
    // Default fallback
    return const MapEntry(
      AssessmentKind.happiness,
      'Let\'s start by checking in on your overall wellbeing.',
    );
  }

  Future<void> _startAssessment(BuildContext context, AssessmentKind kind) async {
    // Navigate to assessment screen
    // We expect the assessment screen to pop when finished or cancelled
    // If finished (results saved), we should probably move to completion
    // But AssessmentScreen currently just shows results dialog then might stay there or pop.
    // We will push it, and rely on the user to "Got it" (pop) back here.
    // Ideally we want to detect if they completed it.
    
    // For now, let's navigate to the specific route based on kind
    String route;
    switch (kind) {
      case AssessmentKind.phq9: route = '/phq9'; break;
      case AssessmentKind.gad7: route = '/gad7'; break;
      case AssessmentKind.sleep: route = '/sleep'; break;
      case AssessmentKind.pss10: route = '/pss10'; break;
      case AssessmentKind.happiness: route = '/happiness'; break;
      case AssessmentKind.selfEsteem: route = '/self-esteem'; break;
      default: route = '/happiness';
    }

    // Navigate to assessment screen with returnResult = true
    final result = await Navigator.of(context).pushNamed(
      route,
      arguments: {'returnResult': true},
    );
    
    // Check if we got a result
    if (result is AssessmentResult && context.mounted) {
       // Show the result screen and wait for it to be popped
       await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssessmentResultScreen(result: result),
        ),
      );
    }
    
    // After returning from assessment (and result screen), automatically go to completion
    if (context.mounted) {
       Navigator.of(context).pushReplacementNamed('/onboarding-complete');
    }
  }

  void _skip(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/onboarding-complete');
  }
}
