import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/onboarding_progress_bar.dart';

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
      backgroundColor: Colors.white,
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
                        height: MediaQuery.of(context).size.height * 0.4,
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
                                      // Progress Bar
                                      OnboardingProgressBar(
                                        currentStep: state.personalizationStep + 1,
                                        totalSteps: 3,
                                      ),
                                      const Spacer(),
                                      // Title section
                                      if (state.personalizationStep == 0) ...[
                                        const Text(
                                          'What should we\ncall you?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2, // Fix for "half cut" text line height
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'This helps us personalize your experience.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ] else if (state.personalizationStep == 1) ...[
                                        const Text(
                                          'What brings you\nhere?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Select as many as apply.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content Body
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.personalizationStep == 0) ...[
                              // Name Input
                              Form(
                                key: _formKey,
                                child: CustomTextFormField(
                                  controller: _nameController,
                                  labelText: 'Your Name',
                                  prefixIcon: Icons.person_rounded,
                                  onChanged: (value) {
                                    ref
                                        .read(onboardingProvider.notifier)
                                        .updateName(value);
                                  },
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
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87, // High contrast
                                ),
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
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? const Color(0xFF667eea).withValues(alpha: 0.1) 
                                            : Colors.grey.withValues(alpha: 0.05),
                                        shape: BoxShape.circle,
                                        border: isSelected 
                                            ? Border.all(color: const Color(0xFF667eea), width: 2) 
                                            : Border.all(color: Colors.transparent, width: 2),
                                      ),
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ] else if (state.personalizationStep == 1) ...[
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.1, // Slightly wider than tall
                                ),
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  final goals = [
                                    'Stress Management',
                                    'Anxiety',
                                    'Depression',
                                    'Sleep Issues',
                                    'General Wellness',
                                    'Productivity',
                                  ];
                                  final goal = goals[index];
                                  final isSelected = state.selectedGoals.contains(goal);
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      ref.read(onboardingProvider.notifier).toggleGoal(goal);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? const Color(0xFF667eea).withValues(alpha: 0.1) 
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected 
                                              ? const Color(0xFF667eea) 
                                              : Colors.grey.withValues(alpha: 0.2),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected 
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF667eea).withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                )
                                              ] 
                                            : [],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getGoalIcon(goal),
                                            size: 32,
                                            color: isSelected ? const Color(0xFF667eea) : Colors.grey[600],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            goal,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                              color: isSelected ? const Color(0xFF667eea) : Colors.grey[800],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 100), // Spacing for fab/bottom buttons
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Actions (Sticky or at bottom of column)
              // We'll keep them outside the SingleChildScrollView so they are always visible
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (state.personalizationStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF667eea)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Back', style: TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    if (state.personalizationStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          state.personalizationStep == 1
                              ? 'Continue'
                              : 'Next',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }

  // Helper widget for cleaner text fields inside this file or move to separate widget
  Widget CustomTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      onChanged: onChanged,
      // Fixed: Explicit black color for input text so it's not grey
      style: const TextStyle(
        fontWeight: FontWeight.bold, 
        color: Colors.black87, 
        fontSize: 16
      ),
      cursorColor: const Color(0xFF667eea), // Match brand color
      decoration: InputDecoration(
        labelText: labelText,
        // Fixed: Ensure label is readable grey, not too light
        labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.normal),
        floatingLabelStyle: const TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.bold),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF667eea)),
        fillColor: Colors.grey[100], // Slightly darker fill for better contrast against white bg
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
      ),
      validator: validator,
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
