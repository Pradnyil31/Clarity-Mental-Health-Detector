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

    // Determine the best assessments based on goals
    final suggestions = _determineAssessments(state.selectedGoals);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Curved Header
                      SizedBox(
                        height: 320,
                        child: Stack(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                ),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      OnboardingProgressBar(
                                        currentStep: 3,
                                        totalSteps: 3,
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.assignment_ind_rounded,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Recommended for You',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Based on your goals, we found matches for you.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Suggestions List
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Select an Assessment',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (suggestions.isEmpty)
                               Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Text(
                                  "No specific suggestions based on your selection, but you can always explore our library.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                               ),
                            ...suggestions.map((suggestion) {
                              final assessmentKind = suggestion.key;
                              final reason = suggestion.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _AssessmentCard(
                                  assessmentKind: assessmentKind,
                                  reason: reason,
                                  onStart: () => _startAssessment(context, assessmentKind),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Skip Action
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: TextButton(
                  onPressed: () => _skip(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Skip for now',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.grey[700]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MapEntry<AssessmentKind, String>> _determineAssessments(List<String> goals) {
    final Set<MapEntry<AssessmentKind, String>> assessments = {};

    if (goals.contains('Depression')) {
      assessments.add(const MapEntry(
        AssessmentKind.phq9,
        'Helps understand your mood and depression symptoms.',
      ));
    }
    if (goals.contains('Anxiety') || goals.contains('Stress Management')) {
      assessments.add(const MapEntry(
        AssessmentKind.gad7,
        'A quick check for anxiety and stress levels.',
      ));
    }
    if (goals.contains('Sleep Issues')) {
      assessments.add(const MapEntry(
        AssessmentKind.sleep,
        'Understand your sleep habits and quality.',
      ));
    }
    if (goals.contains('Productivity') || goals.contains('General Wellness')) {
       if (goals.contains('Productivity')) {
          assessments.add(const MapEntry(
            AssessmentKind.selfEsteem,
            'Explore how you perceive your own worth and abilities.',
          ));
       }
       if (goals.contains('General Wellness')) {
          assessments.add(const MapEntry(
            AssessmentKind.happiness,
            'Check in on your overall happiness and satisfaction.',
          ));
       }
    }

    if (assessments.isEmpty) {
      assessments.add(const MapEntry(
        AssessmentKind.happiness,
        'A general wellness check-in to see how you are doing.',
      ));
    }

    return assessments.toList();
  }

  Future<void> _startAssessment(BuildContext context, AssessmentKind kind) async {
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

    final result = await Navigator.of(context).pushNamed(
      route,
      arguments: {'returnResult': true},
    );

    if (result is AssessmentResult && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssessmentResultScreen(result: result),
        ),
      );
    }

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding-complete');
    }
  }

  void _skip(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/onboarding-complete');
  }
}

class _AssessmentCard extends StatelessWidget {
  final AssessmentKind assessmentKind;
  final String reason;
  final VoidCallback onStart;

  const _AssessmentCard({
    required this.assessmentKind,
    required this.reason,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onStart,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Color(0xFF667eea),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assessmentKind.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${assessmentKind.questionCount} Questions  •  2-3 min',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

