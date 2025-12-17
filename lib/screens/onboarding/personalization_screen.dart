import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/onboarding_progress_bar.dart';
import '../../widgets/goal_selection_chip.dart';
import '../../widgets/goal_selection_chip.dart';
import '../../state/onboarding_state.dart';
import '../../state/user_state.dart';

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() =>
      _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final onboarding = ref.read(onboardingProvider.notifier);
    final state = ref.read(onboardingProvider);
    final step = state.personalizationStep;

    if (step == 0) {
      if (_formKey.currentState!.validate()) {
        onboarding.setPersonalizationStep(1);
      }
    } else if (step == 1) {
      if (state.selectedGoals.isNotEmpty) {
        _saveAndContinue();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one goal')),
        );
      }
    }
  }

  void _prevStep() {
    final onboarding = ref.read(onboardingProvider.notifier);
    final state = ref.read(onboardingProvider);
    if (state.personalizationStep > 0) {
      onboarding.setPersonalizationStep(state.personalizationStep - 1);
    }
  }

  Future<void> _saveAndContinue() async {
    final state = ref.read(onboardingProvider);
    final userNotifier = ref.read(userStateProvider.notifier);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser != null) {
      final updatedProfile = currentUser.copyWith(
        displayName: state.userName, // Update display name from input
        goals: state.selectedGoals,
        experienceLevel: state.experienceLevel,
        avatarId: state.selectedAvatar,
      );

      await userNotifier.updateProfile(updatedProfile);
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/assessment-suggestion');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Progress
            Padding(
              padding: const EdgeInsets.all(24),
              child: OnboardingProgressBar(
                currentStep: state.personalizationStep + 1,
                totalSteps: 3,
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.personalizationStep == 0) ...[
                      Text(
                        'What should we call you?',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This helps us personalize your experience.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            ref
                                .read(onboardingProvider.notifier)
                                .updateName(value);
                          },
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 2) {
                              return 'Please enter a valid name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Avatar Selection
                      Text(
                        'Choose an Avatar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          '🦊', '🐼', '🐯', '🦁', '🐷', '🦄', '🐙', '🦋'
                        ].map((emoji) {
                           final isSelected = state.selectedAvatar == emoji;
                           
                           return GestureDetector(
                             onTap: () {
                               ref.read(onboardingProvider.notifier).setAvatar(emoji);
                             },
                             child: Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                 shape: BoxShape.circle,
                                 border: isSelected ? Border.all(color: scheme.primary, width: 2) : null,
                               ),
                               child: Text(
                                 emoji,
                                 style: const TextStyle(fontSize: 40),
                               ),
                             ),
                           );
                        }).toList(),
                      ),

                    ] else if (state.personalizationStep == 1) ...[
                      Text(
                        'What brings you here?',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select as many as apply.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          'Stress Management',
                          'Anxiety',
                          'Depression',
                          'Sleep Issues',
                          'General Wellness',
                          'Productivity',
                          'Other'
                        ].map((goal) {
                          return GoalSelectionChip(
                            label: goal,
                            icon: _getGoalIcon(goal),
                            isSelected: state.selectedGoals.contains(goal),
                            onTap: () {
                              ref
                                  .read(onboardingProvider.notifier)
                                  .toggleGoal(goal);
                            },
                          );
                        }).toList(),
                      ),
                    ] else ...[
                       // Experience Step Removed
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (state.personalizationStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (state.personalizationStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        state.personalizationStep == 1
                            ? 'Continue'
                            : 'Next',
                      ),
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

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Stress Management':
        return Icons.spa;
      case 'Anxiety':
        return Icons.healing;
      case 'Depression':
        return Icons.mood_bad;
      case 'Sleep Issues':
        return Icons.bedtime;
      case 'General Wellness':
        return Icons.favorite;
      case 'Productivity':
        return Icons.work;
      default:
        return Icons.star;
    }
  }
}
